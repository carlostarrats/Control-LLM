Drop-in llama.cpp (Option A: prebuilt library)

1) Build llama.cpp for iOS (arm64) or macOS as needed and produce a static library:
   - Recommended minimal flags (CPU): use Accelerate/BLAS on Apple platforms
   - Outputs: libllama.a and headers (llama.h and deps)

2) Copy artifacts into this folder structure:
   - Headers: place `llama.h` (and any required headers) here alongside this README
   - Library: place `libllama.a` under `Control LLM/Control LLM/Vendor/llama/lib/ios/` (or `lib/macos/`)

3) Link the library in Xcode:
   - Add the lib path to Library Search Paths for the app target
   - Add `libllama.a` to Link With Binary Libraries

4) Build. The bridge will detect `llama.h` and use real calls; otherwise it falls back to placeholders.

Note: Models (`*.gguf`) are ignored by git by default and should be placed inside the app bundle (e.g., `Screens/Models`).


