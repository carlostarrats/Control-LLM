//
// LlamaCppBridge.mm
//
#import "LlamaCppBridge.h"
#import <Foundation/Foundation.h>
#include <string>

// If you vendor llama.cpp headers (e.g., llama.h) into Vendor/llama, include them here
// and link against a prebuilt static library (Option A). Otherwise fall back to placeholders.

#if __has_include("llama.h")
#include "llama.h"

// NOTE: These are simplified glue calls. Configure params as needed.
static struct llama_model* s_model = NULL;
static struct llama_context* s_ctx = NULL;
static bool s_backend_initialized = false;

static inline bool should_skip_token(const struct llama_vocab * vocab, llama_token id) {
    if (!vocab) return false;
    if (llama_vocab_is_control(vocab, id)) return true;
    if (id == llama_vocab_bos(vocab)) return true;
    if (id == llama_vocab_eos(vocab)) return true;
    if (id == llama_vocab_eot(vocab)) return true;
    if (id == llama_vocab_sep(vocab)) return true;
    if (id == llama_vocab_pad(vocab)) return true;
    if (id == llama_vocab_mask(vocab)) return true;
    return false;
}

static inline bool piece_looks_like_special(const char * piece, int32_t nbytes) {
    if (!piece || nbytes <= 0) return false;
    if (piece[0] == '<' && nbytes >= 3 && piece[1] == '|' && piece[nbytes-2] == '|' && piece[nbytes-1] == '>') {
        return true;
    }
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

void* llm_bridge_load_model(const char* model_path) {
    NSLog(@"LlamaCppBridge: Loading model (real) from %s", model_path);
    if (!s_backend_initialized) {
        llama_backend_init();
        llama_log_set(bridge_llama_log_callback, NULL);
        s_backend_initialized = true;
    }

    struct llama_model_params model_params = llama_model_default_params();
    // Keep memory usage lower for simulator/device defaults
    model_params.use_mmap = true;
    model_params.use_mlock = false;
    model_params.n_gpu_layers = 0; // CPU/Accelerate
    s_model = llama_model_load_from_file(model_path, model_params);
    return (void*)s_model;
}

void llm_bridge_free_model(void* model) {
    if (model) {
        llama_model_free((struct llama_model*)model);
    }
    s_model = NULL;
}

void* llm_bridge_create_context(void* model) {
    if (!model) return NULL;
    struct llama_context_params ctx_params = llama_context_default_params();
    // Conservative memory defaults to avoid stalls
    ctx_params.n_ctx = 256;
    s_ctx = llama_init_from_model((struct llama_model*)model, ctx_params);
    return (void*)s_ctx;
}

void llm_bridge_free_context(void* context) {
    if (context) {
        llama_free((struct llama_context*)context);
    }
    s_ctx = NULL;
}

int llm_bridge_generate_text(void* context, const char* prompt, char* output, int max_length) {
    if (!context || !prompt || !output || max_length <= 1) return 0;

    struct llama_context * ctx = (struct llama_context *) context;
    struct llama_model   * model = s_model;
    if (!model) return 0;

    const struct llama_vocab * vocab = llama_model_get_vocab(model);
    if (!vocab) return 0;

    // 1) Tokenize prompt
    const int32_t max_prompt_tokens = 1024;
    llama_token prompt_tokens[max_prompt_tokens];
    int32_t n_prompt = llama_tokenize(
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

    // Build sampler chain to strongly bias against special/control-like strings
    struct llama_sampler_chain_params sparams = llama_sampler_chain_default_params();
    struct llama_sampler * smpl = llama_sampler_chain_init(sparams);
    if (!smpl) return 0;
    // Stable sampling with small randomness to avoid loops; keep temp low
    llama_sampler_chain_add(smpl, llama_sampler_init_top_k(50));
    llama_sampler_chain_add(smpl, llama_sampler_init_top_p(0.95f, 1));
    llama_sampler_chain_add(smpl, llama_sampler_init_temp(0.7f));
    // chain MUST end with a selection sampler
    llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
    if (!smpl) return 0;

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
                /*special*/ false
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
void llm_bridge_generate_stream_block(void* context, const char* prompt, llm_piece_block callback, int max_new_tokens) {
    if (!context || !prompt || !callback) return;
    struct llama_context * ctx = (struct llama_context *) context;
    struct llama_model   * model = s_model;
    if (!model) return;

    const struct llama_vocab * vocab = llama_model_get_vocab(model);
    if (!vocab) return;

    // tokenize prompt
    const int32_t max_prompt_tokens = 1024;
    llama_token prompt_tokens[max_prompt_tokens];
    int32_t n_prompt = llama_tokenize(vocab, prompt, (int32_t)strlen(prompt), prompt_tokens, max_prompt_tokens, /*add_special*/ true, /*parse_special*/ true);
    if (n_prompt <= 0) return;

    struct llama_batch batch = llama_batch_get_one(prompt_tokens, n_prompt);
    if (batch.logits && n_prompt > 0) {
        memset(batch.logits, 0, (size_t)n_prompt);
        batch.logits[n_prompt - 1] = 1;
    }
    if (llama_decode(ctx, batch) != 0) return;

    struct llama_sampler_chain_params sparams = llama_sampler_chain_default_params();
    struct llama_sampler * smpl = llama_sampler_chain_init(sparams);
    if (!smpl) return;
    llama_sampler_chain_add(smpl, llama_sampler_init_top_k(50));
    llama_sampler_chain_add(smpl, llama_sampler_init_top_p(0.95f, 1));
    llama_sampler_chain_add(smpl, llama_sampler_init_temp(0.7f));
    // Ensure the chain ends with a selection sampler to avoid asserts
    llama_sampler_chain_add(smpl, llama_sampler_init_greedy());

    char piece_buf[256];
    std::string stream_buf; // accumulate to strip tags across piece boundaries
    for (int t = 0; t < max_new_tokens; ++t) {
        llama_token next_id = llama_sampler_sample(smpl, ctx, -1);
        if (next_id < 0) break;
        llama_sampler_accept(smpl, next_id);
        if (next_id == llama_vocab_eos(vocab) || next_id == llama_vocab_eot(vocab)) break;
        if (!should_skip_token(vocab, next_id)) {
            int32_t nbytes = llama_token_to_piece(vocab, next_id, piece_buf, (int32_t)sizeof(piece_buf), 0, false);
            if (nbytes > 0 && !piece_looks_like_special(piece_buf, nbytes)) {
                stream_buf.append(piece_buf, piece_buf + nbytes);

                // Drain stream_buf: remove <|...|> tags and emit clean text
                auto drain = [&]() {
                    for (;;) {
                        size_t s = stream_buf.find("<|");
                        if (s != std::string::npos) {
                            // emit clean prefix before tag
                            if (s > 0) {
                                std::string pre = stream_buf.substr(0, s);
                                if (!pre.empty()) callback(pre.c_str());
                            }
                            // if closing not present yet, keep partial
                            size_t e = stream_buf.find("|>", s + 2);
                            if (e == std::string::npos) {
                                // keep from tag start
                                stream_buf.erase(0, s);
                                break;
                            }
                            // drop entire tag
                            stream_buf.erase(0, e + 2);
                            // continue scanning for next tag
                            continue;
                        } else {
                            // No tag start present: emit up to a safe boundary
                            size_t len = stream_buf.size();
                            if (len >= 2 && stream_buf[len - 2] == '<' && stream_buf[len - 1] == '|') {
                                len -= 2; // keep trailing "<|" for next piece
                            } else if (len >= 1 && stream_buf[len - 1] == '<') {
                                len -= 1; // keep trailing '<' for next piece
                            }
                            if (len > 0) {
                                std::string out = stream_buf.substr(0, len);
                                if (!out.empty()) callback(out.c_str());
                                stream_buf.erase(0, len);
                            }
                            break;
                        }
                    }
                };
                drain();
            }
        }

        llama_token cur = next_id;
        struct llama_batch next_batch = llama_batch_get_one(&cur, 1);
        if (next_batch.logits) next_batch.logits[0] = 1;
        if (llama_decode(ctx, next_batch) != 0) break;
    }

    llama_sampler_free(smpl);
}

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

void llama_reset_context(void* context) {}
int llama_get_context_size(void* context) { return 1024; }

#endif
