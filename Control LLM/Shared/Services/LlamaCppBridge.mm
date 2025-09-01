//
// LlamaCppBridge.mm
//
#import "LlamaCppBridge.h"
#import <Foundation/Foundation.h>
#include <string>
#include <strings.h>
#include <vector>
#include <cmath>

// If you vendor llama.cpp headers (e.g., llama.h) into Vendor/llama, include them here
// and link against a prebuilt static library (Option A). Otherwise fall back to placeholders.

#if __has_include("llama.h")
#include "llama.h"

// NOTE: These are simplified glue calls. Configure params as needed.
static struct llama_model* s_model = NULL;
static struct llama_context* s_ctx = NULL;
static bool s_backend_initialized = false;

// CRASH FIX: Add mutex protection for static globals to prevent race conditions
static pthread_mutex_t s_bridge_mutex = PTHREAD_MUTEX_INITIALIZER;

// Cancellation support
static volatile bool s_generation_cancelled = false;

static inline bool should_skip_token(const struct llama_vocab * vocab, llama_token id) {
    if (!vocab) return false;
    if (llama_vocab_is_control(vocab, id)) return true;
    if (id == llama_vocab_bos(vocab)) return true;
    if (id == llama_vocab_eos(vocab)) return true;
    if (id == llama_vocab_eot(vocab)) return true;
    // Do not skip sep/pad/mask; some quantizations use them as regular pieces
    return false;
}

// Helper function to determine if a model is slow based on filename patterns
static bool isSlowModel(const char* model_path) {
    if (!model_path) return false;
    
    std::string path(model_path);
    std::string filename = path.substr(path.find_last_of("/") + 1);
    
    // Convert to lowercase for case-insensitive comparison
    std::transform(filename.begin(), filename.end(), filename.begin(), ::tolower);
    
    // Known slow models that need optimization
    return (filename.find("gemma-3n") != std::string::npos ||
            filename.find("phi-3") != std::string::npos ||
            filename.find("phi-4") != std::string::npos ||
            filename.find("qwen3") != std::string::npos);
}

static inline bool piece_looks_like_special(const char * piece, int32_t nbytes) {
    if (!piece || nbytes <= 0) return false;
    // Detect ASCII-style tags like <|...|>
    if (strstr(piece, "<|") != NULL && strstr(piece, "|>") != NULL) {
        return true;
    }
    // Remove only ASCII-style special tags, leave other text intact
    return false;
}

// Forward logging from llama.cpp into NSLog so we can see model load errors
static void bridge_llama_log_callback(enum ggml_log_level level, const char * text, void * user_data) {
    (void)user_data;
    // Trim trailing newlines to keep NSLog tidy
    if (text) {
        NSString * message = [NSString stringWithUTF8String:text];
        if (!message) return;
        message = [message stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSLog(@"llama[%d]: %@", (int)level, message);
    }
}

int llm_bridge_apply_chat_template(const char* system_msg, const char* user_msg, char* out_buf, int out_buf_len, bool add_assistant_start) {
    if (!s_model || !out_buf || out_buf_len <= 1) return 0;
    const struct llama_model * model = s_model;
    const char * tmpl = llama_model_chat_template(model, NULL);
    if (!tmpl) {
        return 0; // no template available
    }
    struct llama_chat_message msgs[2];
    size_t n = 0;
    if (system_msg && system_msg[0] != '\0') {
        msgs[n++] = { "system", system_msg };
    }
    if (user_msg && user_msg[0] != '\0') {
        msgs[n++] = { "user", user_msg };
    }
    int32_t written = llama_chat_apply_template(tmpl, msgs, n, add_assistant_start, out_buf, (int32_t)out_buf_len);
    return (int)written;
}

int llm_bridge_apply_chat_template_messages(const char* const* roles, const char* const* contents, int n_messages, bool add_assistant_start, char* out_buf, int out_buf_len) {
    if (!s_model || !out_buf || out_buf_len <= 1 || n_messages <= 0 || !roles || !contents) return 0;
    const struct llama_model * model = s_model;
    const char * tmpl = llama_model_chat_template(model, NULL);
    
    if (!tmpl) {
        NSLog(@"LlamaCppBridge: No chat template available for model, using fallback template.");
        // Fallback template for models without built-in templates
        // Note: This is a reference template, not used in the current implementation
        
        // Simple fallback implementation for models without templates
        int written = 0;
        for (int i = 0; i < n_messages; ++i) {
            const char* role = roles[i] ? roles[i] : "";
            const char* content = contents[i] ? contents[i] : "";
            
            if (strcmp(role, "system") == 0) {
                written += snprintf(out_buf + written, out_buf_len - written, "<|system|>\n%s\n", content);
            } else if (strcmp(role, "user") == 0) {
                written += snprintf(out_buf + written, out_buf_len - written, "<|user|>\n%s", content);
            }
        }
        
        if (add_assistant_start) {
            written += snprintf(out_buf + written, out_buf_len - written, "<|assistant|>\n");
        }
        
        return written;
    }
    
    NSLog(@"LlamaCppBridge: Using chat template: %s", tmpl);

    // Allocate a temporary vector of llama_chat_message
    std::vector<llama_chat_message> msgs;
    msgs.reserve((size_t)n_messages);
    for (int i = 0; i < n_messages; ++i) {
        const char * role = roles[i] ? roles[i] : "";
        const char * text = contents[i] ? contents[i] : "";
        msgs.push_back({ role, text });
    }

    int32_t written = llama_chat_apply_template(tmpl, msgs.data(), msgs.size(), add_assistant_start, out_buf, (int32_t)out_buf_len);
    return (int)written;
}

void* llm_bridge_load_model(const char* model_path) {
    NSLog(@"LlamaCppBridge: Loading model (real) from %s", model_path);
    
    // CRASH FIX: Thread-safe model loading with mutex protection
    pthread_mutex_lock(&s_bridge_mutex);
    
    // CRASH FIX: Free any existing model first to prevent memory leaks
    if (s_model) {
        NSLog(@"LlamaCppBridge: Freeing existing model before loading new one");
        llama_model_free(s_model);
        s_model = NULL;
    }
    
    // CRASH FIX: Free any existing context
    if (s_ctx) {
        NSLog(@"LlamaCppBridge: Freeing existing context before loading new model");
        llama_free(s_ctx);
        s_ctx = NULL;
    }
    
    if (!s_backend_initialized) {
        NSLog(@"LlamaCppBridge: Initializing llama backend");
        llama_backend_init();
        llama_log_set(bridge_llama_log_callback, NULL);
        s_backend_initialized = true;
        NSLog(@"LlamaCppBridge: Backend initialized successfully");
    }

    struct llama_model_params model_params = llama_model_default_params();
    // Keep memory usage lower for simulator/device defaults
    model_params.use_mmap = true;
    model_params.use_mlock = false;
    model_params.n_gpu_layers = 0; // CPU/Accelerate
    
    NSLog(@"LlamaCppBridge: Attempting to load model with params: mmap=%d, mlock=%d, gpu_layers=%d", 
          model_params.use_mmap, model_params.use_mlock, model_params.n_gpu_layers);
    
    s_model = llama_model_load_from_file(model_path, model_params);
    
    if (!s_model) {
        NSLog(@"LlamaCppBridge: Failed to load model from %s", model_path);
        pthread_mutex_unlock(&s_bridge_mutex);
        return NULL;
    }
    
    NSLog(@"LlamaCppBridge: Successfully loaded model from %s", model_path);
    struct llama_model* result = s_model;
    pthread_mutex_unlock(&s_bridge_mutex);
    return (void*)result;
}

void llm_bridge_free_model(void* model) {
    // CRASH FIX: Thread-safe model freeing with mutex protection
    pthread_mutex_lock(&s_bridge_mutex);
    
    NSLog(@"LlamaCppBridge: Freeing model");
    
    // CRASH FIX: Free context first if it exists
    if (s_ctx) {
        NSLog(@"LlamaCppBridge: Freeing context before freeing model");
        llama_free(s_ctx);
        s_ctx = NULL;
    }
    
    // CRASH FIX: Free model if provided or if s_model exists
    if (model && model != s_model) {
        NSLog(@"LlamaCppBridge: Freeing provided model pointer");
        llama_model_free((struct llama_model*)model);
    }
    
    if (s_model) {
        NSLog(@"LlamaCppBridge: Freeing static model pointer");
        llama_model_free(s_model);
        s_model = NULL;
    }
    
    NSLog(@"LlamaCppBridge: Model freed successfully");
    pthread_mutex_unlock(&s_bridge_mutex);
}

void* llm_bridge_create_context(void* model) {
    if (!model) {
        NSLog(@"LlamaCppBridge: Cannot create context - model is NULL");
        return NULL;
    }
    
    // CRASH FIX: Thread-safe context creation with mutex protection
    pthread_mutex_lock(&s_bridge_mutex);
    
    NSLog(@"LlamaCppBridge: Creating context for model");
    
    // CRASH FIX: Free any existing context first
    if (s_ctx) {
        NSLog(@"LlamaCppBridge: Freeing existing context before creating new one");
        llama_free(s_ctx);
        s_ctx = NULL;
    }
    
    struct llama_context_params ctx_params = llama_context_default_params();
    
    // Get model info to determine appropriate parameters
    struct llama_model* model_ptr = (struct llama_model*)model;
    uint32_t n_embd = llama_model_n_embd(model_ptr);
    uint32_t n_layer = llama_model_n_layer(model_ptr);
    
    // Determine if this is a large model based on parameters
    // Large models (4B+ params): Gemma 3N, Phi 4, etc.
    bool is_large_model = (n_embd >= 3072 || n_layer >= 32);
    
    if (is_large_model) {
        // Large models need larger context for good performance
        ctx_params.n_ctx = 2048; // Larger context for 4B+ models
        ctx_params.n_batch = 4096; // Larger batch size for efficiency
        ctx_params.n_threads = 6; // More threads for large models
        ctx_params.flash_attn = true; // Enable flash attention for large models (Phi-4, Gemma 3N)
        NSLog(@"LlamaCppBridge: Using large model parameters (ctx=2048, batch=4096, threads=6, flash_attn=true) for %dB model", n_embd * n_layer / 1000000);
    } else {
        // Small models (1-2B params): Gemma 3, Llama, Qwen 2.5, etc.
        ctx_params.n_ctx = 1024; // Smaller context for 1-2B models
        ctx_params.n_batch = 2048; // Smaller batch size
        ctx_params.n_threads = 4; // Fewer threads
        ctx_params.flash_attn = false; // Disable flash attention for small models (not needed)
        NSLog(@"LlamaCppBridge: Using small model parameters (ctx=1024, batch=2048, threads=4, flash_attn=false) for %dB model", n_embd * n_layer / 1000000);
    }
    
    s_ctx = llama_init_from_model((struct llama_model*)model, ctx_params);
    
    if (!s_ctx) {
        NSLog(@"LlamaCppBridge: Failed to create context");
        pthread_mutex_unlock(&s_bridge_mutex);
        return NULL;
    }
    
    NSLog(@"LlamaCppBridge: Successfully created context");
    struct llama_context* result = s_ctx;
    pthread_mutex_unlock(&s_bridge_mutex);
    return (void*)result;
}

void llm_bridge_free_context(void* context) {
    // CRASH FIX: Thread-safe context freeing with mutex protection
    pthread_mutex_lock(&s_bridge_mutex);
    
    if (context) {
        llama_free((struct llama_context*)context);
    }
    s_ctx = NULL;
    
    pthread_mutex_unlock(&s_bridge_mutex);
}

int llm_bridge_generate_text(void* context, const char* prompt, char* output, int max_length) {
    if (!context || !prompt || !output || max_length <= 1) return 0;

    struct llama_context * ctx = (struct llama_context *) context;
    struct llama_model   * model = s_model;
    if (!model) return 0;

    const struct llama_vocab * vocab = llama_model_get_vocab(model);
    if (!vocab) return 0;

    // Unified path for all models
    
    // 1) Tokenize prompt with model-specific parameters
            const int32_t max_prompt_tokens = 4096; // Increased from 1024 to handle larger prompts
        llama_token prompt_tokens[max_prompt_tokens];
    int32_t n_prompt;
    
    // Standard models: use normal special token handling
    n_prompt = llama_tokenize(
        vocab,
        prompt,
        (int32_t)strlen(prompt),
        prompt_tokens,
        max_prompt_tokens,
        /*add_special*/ true,
        /*parse_special*/ true
    );
    
    if (n_prompt <= 0) return 0;

    // 2) Build batch for prompt (compute logits for last token)
    struct llama_batch batch = llama_batch_get_one(prompt_tokens, n_prompt);
    if (batch.logits && n_prompt > 0) {
        memset(batch.logits, 0, (size_t)n_prompt);
        batch.logits[n_prompt - 1] = 1;
    }
    if (llama_decode(ctx, batch) != 0) {
        return 0;
    }

    // 3) Greedy sampler (robust vs chain asserts)
    const int max_new_tokens = 512; // allow full responses
    int out_len = 0;
    char piece_buf[256];
    std::string stream_buf; // accumulate to strip tags across piece boundaries

    // Build sampler chain with conservative decoding for stability on small R1-distill models
    struct llama_sampler_chain_params sparams = llama_sampler_chain_default_params();
    struct llama_sampler * smpl = llama_sampler_chain_init(sparams);
    if (!smpl) {
        NSLog(@"LlamaCppBridge: Failed to initialize streaming sampler chain");
        return 0;
    }
    
    // Tighter decoding for small DeepSeek-R1-distill models
    llama_sampler_chain_add(smpl, llama_sampler_init_top_k(20));
    llama_sampler_chain_add(smpl, llama_sampler_init_top_p(0.70f, 1));
    llama_sampler_chain_add(smpl, llama_sampler_init_min_p(0.05f, 1));
    llama_sampler_chain_add(smpl, llama_sampler_init_typical(0.70f, 1));
    llama_sampler_chain_add(smpl, llama_sampler_init_temp(0.20f));
    // chain MUST end with a selection sampler
    llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
    
    // Verify the chain has at least one sampler
    if (llama_sampler_chain_n(smpl) == 0) {
        NSLog(@"LlamaCppBridge: Streaming sampler chain is empty after initialization");
        llama_sampler_free(smpl);
        return 0;
    }

    for (int t = 0; t < max_new_tokens; ++t) {
        // Before sampling, fetch logits distribution for safety
        // llama.cpp sampler API computes internally; we just ensure it has prior decode
        llama_token next_id = llama_sampler_sample(smpl, ctx, /*idx*/ -1);
        // Guard against invalid selection
        if (next_id < 0) break;
        llama_sampler_accept(smpl, next_id);

        // stop on end tokens
        if (next_id == llama_vocab_eos(vocab) || next_id == llama_vocab_eot(vocab)) {
            break;
        }

        if (!should_skip_token(vocab, next_id)) {
            // detokenize piece and append to output
            int32_t nbytes = llama_token_to_piece(
                vocab,
                next_id,
                piece_buf,
                (int32_t)sizeof(piece_buf),
                /*lstrip*/ 0,
                /*special*/ true
            );
            if (nbytes > 0 && !piece_looks_like_special(piece_buf, nbytes)) {
                if (out_len + nbytes >= max_length - 1) {
                    nbytes = (max_length - 1) - out_len;
                }
                memcpy(output + out_len, piece_buf, (size_t)nbytes);
                out_len += nbytes;
                output[out_len] = '\0';
            }
        }

        // 4) Decode the sampled token to advance context
        llama_token cur = next_id;
        struct llama_batch next_batch = llama_batch_get_one(&cur, 1);
        if (next_batch.logits) {
            next_batch.logits[0] = 1;
        }
        if (llama_decode(ctx, next_batch) != 0) {
            break;
        }
    }

    llama_sampler_free(smpl);
    return out_len;
}

int llm_bridge_generate_token(void* context, char* token, int max_token_length) {
    // For real streaming, implement incremental sampling; placeholder for now.
    const char* dummy = "token";
    int len = (int)strlen(dummy);
    if (len >= max_token_length) len = max_token_length - 1;
    strncpy(token, dummy, len);
    token[len] = '\0';
    return len;
}

void llm_bridge_reset_context(void* context) {
    // Optionally reset KV cache if needed
}

int llm_bridge_get_context_size(void* context) {
    return 0;
}

// Streaming version using ObjC block
void llm_bridge_generate_stream_block(void* context, const char* model_name, const char* prompt, llm_piece_block callback, int max_new_tokens) {
    NSLog(@"LlamaCppBridge: Starting streaming generation with max_tokens=%d for model %s", max_new_tokens, model_name);
    
    if (!context || !prompt || !callback) {
        NSLog(@"LlamaCppBridge: Invalid parameters for streaming generation");
        callback(NULL);
        return;
    }
    
    // Reset cancellation flag at start of generation
    s_generation_cancelled = false;
    
    // CRASH FIX: Add mutex protection for streaming operations
    pthread_mutex_lock(&s_bridge_mutex);
    
    struct llama_context * ctx = (struct llama_context *) context;
    struct llama_model   * model = s_model;
    if (!model) {
        NSLog(@"LlamaCppBridge: No model available for streaming generation");
        pthread_mutex_unlock(&s_bridge_mutex);
        callback(NULL);
        return;
    }

    const struct llama_vocab * vocab = llama_model_get_vocab(model);
    if (!vocab) {
        NSLog(@"LlamaCppBridge: No vocabulary available for streaming generation");
        pthread_mutex_unlock(&s_bridge_mutex);
        callback(NULL);
        return;
    }
    
    // CRASH FIX: Verify context is still valid
    if (!ctx) {
        NSLog(@"LlamaCppBridge: Context is NULL during streaming generation");
        pthread_mutex_unlock(&s_bridge_mutex);
        callback(NULL);
        return;
    }
    
    // Unified path for all models

    NSLog(@"LlamaCppBridge: Prompt length: %zu characters", strlen(prompt));
    // Log first 200 chars of prompt for debugging
    const int preview_len = 200;
    if (strlen(prompt) > preview_len) {
        char preview[preview_len + 1];
        strncpy(preview, prompt, preview_len);
        preview[preview_len] = '\0';
        NSLog(@"LlamaCppBridge: Prompt preview: %s...", preview);
    } else {
        NSLog(@"LlamaCppBridge: Full prompt: %s", prompt);
    }

    // tokenize prompt
            const int32_t max_prompt_tokens = 2048; // Reduced to match context window
        llama_token prompt_tokens[max_prompt_tokens];
    int32_t n_prompt;

    NSLog(@"LlamaCppBridge: Using standard tokenization (add_special=true, parse_special=true)");
    n_prompt = llama_tokenize(vocab, prompt, (int32_t)strlen(prompt), prompt_tokens, max_prompt_tokens, /*add_special*/ true, /*parse_special*/ true);

    if (n_prompt <= 0) {
        NSLog(@"❌ CRITICAL ERROR: LlamaCppBridge: Tokenization failed for streaming generation (returned %d tokens)", n_prompt);
        NSLog(@"🔍 Tokenization failure details:");
        NSLog(@"   - Prompt length: %zu characters", strlen(prompt));
        NSLog(@"   - Max prompt tokens: %d", max_prompt_tokens);
        NSLog(@"   - Prompt preview: %.200s...", prompt);
        
        // Provide specific error information based on failure type
        if (n_prompt == 0) {
            NSLog(@"   - Error: Empty prompt or no valid tokens generated");
        } else if (n_prompt < 0) {
            NSLog(@"   - Error: Tokenization failed with error code %d", n_prompt);
            NSLog(@"   - This usually means the prompt is too long or contains invalid characters");
        }
        
        pthread_mutex_unlock(&s_bridge_mutex);
        callback(NULL);
        return;
    }
    
    NSLog(@"LlamaCppBridge: Tokenized prompt into %d tokens", n_prompt);

    struct llama_batch batch = llama_batch_get_one(prompt_tokens, n_prompt);
    if (batch.logits && n_prompt > 0) {
        memset(batch.logits, 0, (size_t)n_prompt);
        batch.logits[n_prompt - 1] = 1;
    }
    if (llama_decode(ctx, batch) != 0) {
        NSLog(@"LlamaCppBridge: Initial decode failed for streaming generation");
        
        // CRITICAL FIX: Try to reset context and retry once before giving up
        NSLog(@"LlamaCppBridge: Attempting to reset context and retry...");
        
        // Reset the context to clear accumulated memory
        llama_memory_clear(llama_get_memory(ctx), true);
        
        // Try decode again with fresh context
        if (llama_decode(ctx, batch) != 0) {
            NSLog(@"LlamaCppBridge: Retry decode failed - sending memory allocation error to Swift");
            callback("__MEMORY_ALLOCATION_FAILED__");
            pthread_mutex_unlock(&s_bridge_mutex);
            return;
        } else {
            NSLog(@"LlamaCppBridge: Context reset successful - continuing with generation");
        }
    }

    struct llama_sampler_chain_params sparams = llama_sampler_chain_default_params();
    struct llama_sampler * smpl = llama_sampler_chain_init(sparams);
    if (!smpl) {
        NSLog(@"LlamaCppBridge: Failed to initialize streaming sampler chain");
        // Call callback with NULL to indicate failure/completion
        callback(NULL);
        return;
    }

    // Add samplers BEFORE verifying the chain to avoid empty-chain failures
    // Decoding settings
    llama_sampler_chain_add(smpl, llama_sampler_init_top_k(20));
    llama_sampler_chain_add(smpl, llama_sampler_init_top_p(0.70f, 1));
    llama_sampler_chain_add(smpl, llama_sampler_init_min_p(0.05f, 1));
    llama_sampler_chain_add(smpl, llama_sampler_init_typical(0.70f, 1));
    llama_sampler_chain_add(smpl, llama_sampler_init_temp(0.20f));
    // Ensure the chain ends with a selection sampler
    llama_sampler_chain_add(smpl, llama_sampler_init_greedy());

    // Verify the chain has at least one sampler
    if (llama_sampler_chain_n(smpl) == 0) {
        NSLog(@"LlamaCppBridge: Streaming sampler chain is empty after initialization");
        llama_sampler_free(smpl);
        callback(NULL);
        return;
    }

    char piece_buf[256];
    
    NSLog(@"LlamaCppBridge: Starting generation loop for %d tokens", max_new_tokens);
    
    int tokens_generated = 0;
    bool hit_token_limit = false;
    int cancellation_check_counter = 0;
            const int cancellation_check_frequency = 1; // Check every token for immediate cancellation
    
    for (int t = 0; t < max_new_tokens; ++t) {
        // PHASE 4: Enhanced cancellation checking for faster response
        cancellation_check_counter++;
        if (cancellation_check_counter >= cancellation_check_frequency) {
            cancellation_check_counter = 0;
            if (s_generation_cancelled) {
                NSLog(@"LlamaCppBridge: PHASE 4 - Generation cancelled at token %d (enhanced checking)", t);
                break;
            }
        }
        
        llama_token next_id = llama_sampler_sample(smpl, ctx, -1);
        if (next_id < 0) {
            NSLog(@"LlamaCppBridge: Invalid token ID %d during streaming generation", next_id);
            break;
        }
        llama_sampler_accept(smpl, next_id);
        
        if (next_id == llama_vocab_eos(vocab) || next_id == llama_vocab_eot(vocab)) {
            NSLog(@"LlamaCppBridge: Hit end token at position %d", t);
            break;
        }
        
        // Check if we're about to hit the token limit
        if (t == max_new_tokens - 1) {
            NSLog(@"LlamaCppBridge: Reached maximum token limit (%d tokens)", max_new_tokens);
            hit_token_limit = true;
        }
        
        if (!should_skip_token(vocab, next_id)) {
            int32_t nbytes = llama_token_to_piece(vocab, next_id, piece_buf, (int32_t)sizeof(piece_buf), 0, true);
            if (nbytes > 0 && !piece_looks_like_special(piece_buf, nbytes)) {
                // Bounds checking for piece buffer
                if (nbytes >= (int32_t)sizeof(piece_buf)) {
                    NSLog(@"LlamaCppBridge: Token piece too long (%d bytes), truncating", nbytes);
                    nbytes = (int32_t)sizeof(piece_buf) - 1;
                }
                
                // STREAMING FIX: Emit tokens immediately instead of buffering
                // Convert piece to string and emit directly
                std::string piece_str(piece_buf, piece_buf + nbytes);
                
                // Remove any special tags from this piece before emitting
                std::string clean_piece = piece_str;
                
                // Remove common special tokens that might appear in pieces
                const std::string tag_start = "<|";
                const std::string tag_end = "|>";
                const std::string think_open = "<think>";
                const std::string think_close = "</think>";
                const std::string reasoning_open = "<reasoning>";
                const std::string reasoning_close = "</reasoning>";
                const std::string internal_open = "<internal>";
                const std::string internal_close = "</internal>";
                const std::string reflection_open = "<reflection>";
                const std::string reflection_close = "</reflection>";
                const std::string analysis_open = "<analysis>";
                const std::string analysis_close = "</analysis>";
                const std::string process_open = "<process>";
                const std::string process_close = "</process>";
                
                // Remove <|...|> tags
                size_t pos = 0;
                while ((pos = clean_piece.find(tag_start)) != std::string::npos) {
                    size_t end_pos = clean_piece.find(tag_end, pos);
                    if (end_pos != std::string::npos) {
                        clean_piece.erase(pos, end_pos + tag_end.length() - pos);
                    } else {
                        // Incomplete tag, remove from this point
                        clean_piece.erase(pos);
                        break;
                    }
                }
                
                // Remove <think> tags - improved handling for incomplete tags
                pos = 0;
                while ((pos = clean_piece.find(think_open)) != std::string::npos) {
                    size_t end_pos = clean_piece.find(think_close, pos);
                    if (end_pos != std::string::npos) {
                        // Complete thinking tag found, remove it
                        clean_piece.erase(pos, end_pos + think_close.length() - pos);
                    } else {
                        // Incomplete thinking tag - remove just the opening tag and continue
                        // This prevents getting stuck when models generate incomplete thinking content
                        clean_piece.erase(pos, think_open.length());
                        NSLog(@"LlamaCppBridge: Removed incomplete <think> tag, continuing generation");
                    }
                }
                
                // Remove <reasoning> tags (common in Qwen models)
                pos = 0;
                while ((pos = clean_piece.find(reasoning_open)) != std::string::npos) {
                    size_t end_pos = clean_piece.find(reasoning_close, pos);
                    if (end_pos != std::string::npos) {
                        clean_piece.erase(pos, end_pos + reasoning_close.length() - pos);
                    } else {
                        clean_piece.erase(pos, reasoning_open.length());
                        NSLog(@"LlamaCppBridge: Removed incomplete <reasoning> tag");
                    }
                }
                
                // Remove <internal> tags
                pos = 0;
                while ((pos = clean_piece.find(internal_open)) != std::string::npos) {
                    size_t end_pos = clean_piece.find(internal_close, pos);
                    if (end_pos != std::string::npos) {
                        clean_piece.erase(pos, end_pos + internal_close.length() - pos);
                    } else {
                        clean_piece.erase(pos, internal_open.length());
                        NSLog(@"LlamaCppBridge: Removed incomplete <internal> tag");
                    }
                }
                
                // Remove <reflection> tags
                pos = 0;
                while ((pos = clean_piece.find(reflection_open)) != std::string::npos) {
                    size_t end_pos = clean_piece.find(reflection_close, pos);
                    if (end_pos != std::string::npos) {
                        clean_piece.erase(pos, end_pos + reflection_close.length() - pos);
                    } else {
                        clean_piece.erase(pos, reflection_open.length());
                        NSLog(@"LlamaCppBridge: Removed incomplete <reflection> tag");
                    }
                }
                
                // Remove <analysis> tags
                pos = 0;
                while ((pos = clean_piece.find(analysis_open)) != std::string::npos) {
                    size_t end_pos = clean_piece.find(analysis_close, pos);
                    if (end_pos != std::string::npos) {
                        clean_piece.erase(pos, end_pos + analysis_close.length() - pos);
                    } else {
                        clean_piece.erase(pos, analysis_open.length());
                        NSLog(@"LlamaCppBridge: Removed incomplete <analysis> tag");
                    }
                }
                
                // Remove <process> tags
                pos = 0;
                while ((pos = clean_piece.find(process_open)) != std::string::npos) {
                    size_t end_pos = clean_piece.find(process_close, pos);
                    if (end_pos != std::string::npos) {
                        clean_piece.erase(pos, end_pos + process_close.length() - pos);
                    } else {
                        clean_piece.erase(pos, process_open.length());
                        NSLog(@"LlamaCppBridge: Removed incomplete <process> tag");
                    }
                }
                
                // Emit clean piece immediately if it contains text
                if (!clean_piece.empty()) {
                    callback(clean_piece.c_str());
                }
                
                tokens_generated++;
                
                if (tokens_generated <= 5) {
                    NSLog(@"LlamaCppBridge: Token %d: '%.*s' -> '%s'", tokens_generated, nbytes, piece_buf, clean_piece.c_str());
                }
            }
        }

        llama_token cur = next_id;
        struct llama_batch next_batch = llama_batch_get_one(&cur, 1);
        if (next_batch.logits) next_batch.logits[0] = 1;
        if (llama_decode(ctx, next_batch) != 0) {
            NSLog(@"LlamaCppBridge: Decode failed during streaming generation at token %d", t);
            break;
        }
    }

    NSLog(@"LlamaCppBridge: Generation loop completed. Generated %d tokens.", tokens_generated);
    
    llama_sampler_free(smpl);
    
    // No more buffering - all tokens are emitted immediately
    
    // Call completion callback with token limit indicator if applicable
    if (hit_token_limit) {
        // Send a special marker that Swift can interpret as token limit reached
        callback("__TOKEN_LIMIT_REACHED__");
    }
    
    // Call completion callback
    callback(NULL);
    
    // CRITICAL FIX: Reset context after each chunk to prevent memory accumulation
    NSLog(@"LlamaCppBridge: Resetting context after chunk completion to free memory");
    llama_memory_clear(llama_get_memory(ctx), true);
    
    NSLog(@"LlamaCppBridge: Streaming generation completed");
    pthread_mutex_unlock(&s_bridge_mutex);
}

// Cancellation support
void llm_bridge_cancel_generation(void) {
    NSLog(@"LlamaCppBridge: Cancelling generation");
    s_generation_cancelled = true;
}

// Voice recognition function removed

// Speech synthesis function removed

// Voice support check function removed

#else

// Placeholders if llama.h is not present yet
void* llama_load_model(const char* model_path) {
    NSLog(@"LlamaCppBridge: Loading model (placeholder) from %s", model_path);
    return (void*)0x12345678;
}

void llama_free_model(void* model) {
    NSLog(@"LlamaCppBridge: Freeing model (placeholder)");
}

void* llama_create_context(void* model) {
    NSLog(@"LlamaCppBridge: Creating context (placeholder)");
    return (void*)0x87654321;
}

void llama_free_context(void* context) {
    NSLog(@"LlamaCppBridge: Freeing context (placeholder)");
}

int llama_generate_text(void* context, const char* prompt, char* output, int max_length) {
    NSLog(@"LlamaCppBridge: Generating text (placeholder) for prompt: %s", prompt);
    const char* response = "This is a placeholder response from llama.cpp integration.";
    int response_len = (int)strlen(response);
    if (response_len >= max_length) response_len = max_length - 1;
    strncpy(output, response, response_len);
    output[response_len] = '\0';
    return response_len;
}

int llama_generate_token(void* context, char* token, int max_token_length) {
    const char* dummy_token = "token";
    int token_len = (int)strlen(dummy_token);
    if (token_len >= max_token_length) token_len = max_token_length - 1;
    strncpy(token, dummy_token, token_len);
    token[token_len] = '\0';
    return token_len;
}

void llama_reset_context(void* context) {
    if (context) {
        struct llama_context * ctx = (struct llama_context *) context;
        // Clear the memory to free accumulated memory
        llama_memory_clear(llama_get_memory(ctx), true);
        NSLog(@"LlamaCppBridge: Context reset - memory cleared");
    }
}

int llama_get_context_size(void* context) { 
    if (context) {
        struct llama_context * ctx = (struct llama_context *) context;
        return (int)llama_get_kv_cache_token_count(ctx);
    }
    return 0; 
}

void llm_bridge_cancel_generation(void) {
    NSLog(@"LlamaCppBridge: Cancel generation (placeholder)");
}

#endif
