#ifndef LlamaCppBridge_h
#define LlamaCppBridge_h

#include <Foundation/Foundation.h>

// Llama.cpp C API wrapper functions
#ifdef __cplusplus
extern "C" {
#endif

// Model loading and context management
void* llama_load_model(const char* model_path);
void llama_free_model(void* model);
void* llama_create_context(void* model);
void llama_free_context(void* context);

// Text generation
int llama_generate_text(void* context, const char* prompt, char* output, int max_length);
int llama_generate_token(void* context, char* token, int max_token_length);

// Context management
void llama_reset_context(void* context);
int llama_get_context_size(void* context);

#ifdef __cplusplus
}
#endif

#endif /* LlamaCppBridge_h */
