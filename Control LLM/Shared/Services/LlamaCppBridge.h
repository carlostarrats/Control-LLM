#ifndef LlamaCppBridge_h
#define LlamaCppBridge_h

#include <Foundation/Foundation.h>

// C-friendly wrapper functions to bridge Swift and llama.cpp without symbol/type conflicts
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

// Streaming callback API for Swift
typedef void (^llm_piece_block)(const char* piece);
void llm_bridge_generate_stream_block(void* context, const char* prompt, llm_piece_block callback, int max_new_tokens);

#ifdef __cplusplus
}
#endif

#endif /* LlamaCppBridge_h */
