#ifndef LLMEngineBridge_h
#define LLMEngineBridge_h

#include <Foundation/Foundation.h>

// C-friendly wrapper functions to bridge Swift and the LLM engine without symbol/type conflicts
#ifdef __cplusplus
extern "C" {
#endif

// Model loading and context management (opaque pointers on the boundary)
void* llm_bridge_load_model(const char* model_path);
void llm_bridge_free_model(void* model);
void* llm_bridge_create_context(void* model);
void llm_bridge_free_context(void* context);

// Text generation
int llm_bridge_generate_text(void* context, const char* prompt, char* output, int max_length);
int llm_bridge_generate_token(void* context, char* token, int max_token_length);

// Context management
void llm_bridge_reset_context(void* context);
int llm_bridge_get_context_size(void* context);

// Streaming generation using a callback block
typedef void (^llm_piece_block)(const char* piece);
void llm_bridge_generate_stream_block(void* context, const char* model_name, const char* prompt, llm_piece_block callback, int max_new_tokens);

// Cancellation support
void llm_bridge_cancel_generation(void);

// Metal shader compilation for first run setup
void llm_bridge_preload_metal_shaders(void);

// Apply the model's built-in chat template (if available). Returns number of bytes written to out_buf.
// If the buffer is too small, returns a negative number equal to the required size.
int llm_bridge_apply_chat_template(const char* system_msg, const char* user_msg, char* out_buf, int out_buf_len, bool add_assistant_start);

// Apply the model's built-in chat template with multiple messages.
// roles[i] should be one of: "system", "user", "assistant". contents[i] is the message text.
// Returns number of bytes written to out_buf, or negative required size if buffer too small, or 0 on failure.
int llm_bridge_apply_chat_template_messages(const char* const* roles, const char* const* contents, int n_messages, bool add_assistant_start, char* out_buf, int out_buf_len);

// Voice processing functions removed

#ifdef __cplusplus
}
#endif

#endif /* LLMEngineBridge_h */
