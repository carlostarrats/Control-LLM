import Foundation
import SwiftUI

final class LLMService: @unchecked Sendable {
    static let shared = LLMService()
    private var modelPath: String?
    private var currentModelFilename: String?
    private var llamaModel: UnsafeMutableRawPointer?
    private var llamaContext: UnsafeMutableRawPointer?
    private var isModelLoaded = false
    private var conversationCount = 0
    private let maxConversationsBeforeReset = 50  // Increased from 3 to prevent interference with model switching
    private var isModelOperationInProgress = false  // For model loading/unloading
    private var isChatOperationInProgress = false   // For chat generation
    private var lastOperationTime: Date = Date()  // Track when operations start
    
    /// Load the currently selected model from ModelManager
    func loadSelectedModel() async throws {
        // Safety mechanism: if the flag has been stuck for more than 5 minutes, reset it
        if isModelOperationInProgress {
            let timeSinceLastOperation = Date().timeIntervalSince(lastOperationTime)
            if timeSinceLastOperation > 300 { // 5 minutes
                print("⚠️ WARNING: isModelOperationInProgress flag stuck for \(Int(timeSinceLastOperation)) seconds, resetting")
                isModelOperationInProgress = false
            }
        }
        
        // Prevent concurrent model operations
        guard !isModelOperationInProgress else {
            throw NSError(domain: "LLMService", code: 11, userInfo: [NSLocalizedDescriptionKey: "Another model operation is in progress"])
        }
        
        isModelOperationInProgress = true
        lastOperationTime = Date()
        defer { 
            isModelOperationInProgress = false 
        }
        
        guard let modelFilename = ModelManager.shared.getSelectedModelFilename() else {
            throw NSError(domain: "LLMService",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "No model selected"])
        }
        
        // REMOVED: The optimization that was preventing model reloading
        // This was causing the caching issue where switching models didn't actually change the LLM
        
        print("🔍 LLMService: Loading model: \(modelFilename) (previous: \(currentModelFilename ?? "none"))")
        
        // Always reload the model to ensure clean state and prevent caching issues
        // The previous optimization was causing responses to be cached between model switches
        
        // Look for the model file in the bundle root (models are copied there during build)
        guard let modelURL = Bundle.main.url(forResource: modelFilename, withExtension: "gguf", subdirectory: nil) else {
            print("❌ LLMService: Model file not found in bundle root: \(modelFilename).gguf")
            throw NSError(domain: "LLMService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Model file not found in bundle root"])
        }
        
        // Clear previous model to free memory
        print("🔍 LLMService: Clearing previous model before loading new one...")
        unloadModel()
        
        // IMPROVEMENT: Reset conversation count when switching models
        conversationCount = 0
        print("🔍 LLMService: Reset conversation count for new model")
        
        self.modelPath = modelURL.path
        self.currentModelFilename = modelFilename
        print("🔍 LLMService: Set currentModelFilename to: \(currentModelFilename ?? "nil")")
        
        // Load the model using llama.cpp with a timeout to avoid UI stalls
        do {
            print("🔍 LLMService: Starting llama.cpp model loading...")
            try await withTimeout(seconds: 30) { [self] in
                try await self.loadModelWithLlamaCpp()
            }
        } catch {
            let reason = (error as NSError).localizedDescription
            print("❌ LLMService: loadModelWithLlamaCpp failed: \(reason)")
            throw error
        }
        
        print("✅ LLMService: Successfully loaded model \(modelFilename)")
        print("🔍 LLMService: Final state after loading:")
        print("     - currentModelFilename: \(currentModelFilename ?? "nil")")
        print("     - isModelLoaded: \(isModelLoaded)")
        print("     - modelPath: \(modelPath ?? "nil")")
    }
    
    private func unloadModel() {
        print("🔍 LLMService: Unloading model and cleaning up resources")
        
        // Safety check: prevent double-free
        guard llamaModel != nil || llamaContext != nil else {
            print("🔍 LLMService: No model resources to free - already clean")
            return
        }
        
        // Safely free context first
        if let context = llamaContext {
            print("🔍 LLMService: Freeing context...")
            llm_bridge_free_context(context)
            llamaContext = nil
            print("🔍 LLMService: Context freed")
        }
        
        // Then safely free model
        if let model = llamaModel {
            print("🔍 LLMService: Freeing model...")
            llm_bridge_free_model(model)
            llamaModel = nil
            print("🔍 LLMService: Model freed")
        }
        
        // Clear all state
        isModelLoaded = false
        modelPath = nil
        currentModelFilename = nil
        print("🔍 LLMService: Model unload completed")
    }
    
    /// Force unload the current model (public method for external control)
    func forceUnloadModel() async throws {
        print("🔍 LLMService: Force unloading model and clearing all state")
        
        // Safety check: prevent concurrent unloads
        guard !isModelOperationInProgress else {
            print("🔍 LLMService: Model operation already in progress, skipping unload")
            return
        }
        
        isModelOperationInProgress = true
        defer { isModelOperationInProgress = false }
        
        print("   Current state before unload:")
        print("     - isModelLoaded: \(isModelLoaded)")
        print("     - currentModelFilename: \(currentModelFilename ?? "nil")")
        print("     - llamaModel: \(llamaModel != nil ? "exists" : "nil")")
        print("     - llamaContext: \(llamaContext != nil ? "exists" : "nil")")
        print("     - conversationCount: \(conversationCount)")
        
        // Wait for any ongoing chat operations to complete
        if isChatOperationInProgress {
            print("⚠️ WARNING: Chat operation in progress, waiting for completion...")
            // Give it a moment to complete
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        // Prevent double-unload crashes
        guard isModelLoaded || llamaModel != nil || llamaContext != nil else {
            print("🔍 LLMService: No model to unload - already clean")
            return
        }
        
        // IMPROVEMENT: More comprehensive state clearing
        conversationCount = 0
        isChatOperationInProgress = false
        lastOperationTime = Date()
        
        // Force unload the model
        unloadModel()
        
        print("🔍 LLMService: Force unload completed - all state cleared")
        print("   State after unload:")
        print("     - isModelLoaded: \(isModelLoaded)")
        print("     - currentModelFilename: \(currentModelFilename ?? "nil")")
        print("     - llamaModel: \(llamaModel != nil ? "exists" : "nil")")
        print("     - llamaContext: \(llamaContext != nil ? "exists" : "nil")")
        print("     - conversationCount: \(conversationCount)")
    }
    
    private func loadModelWithLlamaCpp() async throws {
        guard let modelPath = modelPath else {
            throw NSError(domain: "LLMService", code: 3, userInfo: [NSLocalizedDescriptionKey: "No model path"])
        }
        
        print("LLMService: Loading model from path: \(modelPath)")
        
        // Run heavy C calls off the main thread
        try await Task.detached(priority: .userInitiated) { [self] in
            self.llamaModel = nil
            modelPath.withCString { cString in
                self.llamaModel = llm_bridge_load_model(cString)
            }
            
            guard let model = self.llamaModel else {
                print("LLMService: llm_bridge_load_model returned NULL")
                throw NSError(domain: "LLMService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to load model - bridge returned NULL"])
            }
            
            print("LLMService: Model loaded successfully, creating context...")
            self.llamaContext = llm_bridge_create_context(model)
            
            guard self.llamaContext != nil else {
                print("LLMService: llm_bridge_create_context returned NULL")
                // Clean up the model if context creation fails
                llm_bridge_free_model(model)
                self.llamaModel = nil
                throw NSError(domain: "LLMService", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to create context - bridge returned NULL"])
            }
            
            print("LLMService: Context created successfully")
        }.value
        
        self.isModelLoaded = true
        print("LLMService: Model loaded successfully with llama.cpp")
    }
    
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw NSError(domain: "LLMService", code: 7, userInfo: [NSLocalizedDescriptionKey: "Model loading timed out"])
            }
            
            guard let result = try await group.next() else {
                group.cancelAll()
                throw NSError(domain: "LLMService", code: 8, userInfo: [NSLocalizedDescriptionKey: "No result from timeout operation"])
            }
            
            group.cancelAll()
            return result
        }
    }

    /// Stream tokens for a user prompt, optionally with chat history
    func chat(user text: String, history: [ChatMessage]? = nil, onToken: @escaping (String) async -> Void) async throws {
        // Safety check - ensure we're not in the middle of unloading
        guard !text.isEmpty else {
            throw NSError(domain: "LLMService", code: 10, userInfo: [NSLocalizedDescriptionKey: "Empty input text"])
        }
        
        // Safety mechanism: if the flag has been stuck for more than 5 minutes, reset it
        if isChatOperationInProgress {
            let timeSinceLastOperation = Date().timeIntervalSince(lastOperationTime)
            if timeSinceLastOperation > 300 { // 5 minutes
                print("⚠️ WARNING: isChatOperationInProgress flag stuck for \(Int(timeSinceLastOperation)) seconds, resetting")
                isChatOperationInProgress = false
            }
        }
        
        // Prevent concurrent chat operations
        guard !isChatOperationInProgress else {
            throw NSError(domain: "LLMService", code: 11, userInfo: [NSLocalizedDescriptionKey: "Another chat operation is in progress"])
        }
        
        isChatOperationInProgress = true
        lastOperationTime = Date()
        
        // Ensure the flag is always reset, even if errors occur
        defer { 
            isChatOperationInProgress = false 
        }
        
        // Increment conversation counter
        conversationCount += 1
        print("🔍 LLMService: Starting conversation #\(conversationCount) with model \(currentModelFilename ?? "unknown")")
        
        // Validate input text
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NSError(domain: "LLMService",
                          code: 5,
                          userInfo: [NSLocalizedDescriptionKey: "Empty or whitespace-only input"])
        }
        
        // Check input length to prevent memory issues
        let maxInputLength = 2000 // Conservative limit for 3B models
        var processedText = text
        if processedText.count > maxInputLength {
            print("⚠️ WARNING: Input text too long (\(processedText.count) chars), truncating to \(maxInputLength)")
            let truncatedText = String(processedText.prefix(maxInputLength))
            print("🔍 DEBUG: Truncated text: '\(truncatedText)'")
            processedText = truncatedText
        }
        
        // IMPROVEMENT: Only reset context if we've had too many conversations with THIS model
        if conversationCount >= maxConversationsBeforeReset {
            print("🔄 DEBUG: Resetting LLM context after \(conversationCount) conversations with model \(currentModelFilename ?? "unknown")")
            
            // Only unload and reload the context, not the entire model
            if let context = llamaContext {
                llm_bridge_free_context(context)
                llamaContext = nil
            }
            
            // Recreate context
            if let model = llamaModel {
                llamaContext = llm_bridge_create_context(model)
                guard llamaContext != nil else {
                    throw NSError(domain: "LLMService", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to recreate context"])
                }
            }
            
            conversationCount = 0
        } else {
            // Only load model if we haven't already loaded it
            if !isModelLoaded {
                try await loadSelectedModel()
            }
        }
        
        guard isModelLoaded, let context = llamaContext else {
            throw NSError(domain: "LLMService",
                          code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Model not loaded"])
        }
        
        do {
            // Build the prompt using the new helper
            let prompt = buildPrompt(userText: processedText, history: history)
            
            print("🔍 LLMService: Final prompt length: \(prompt.count) characters")
            print("🔍 LLMService: Final prompt preview: \(String(prompt.prefix(200)))...")
            
            // Safety check for extremely long prompts
            let maxPromptLength = 4096 // Increased to handle larger contexts
            if prompt.count > maxPromptLength {
                throw NSError(domain: "LLMService",
                             code: 6, 
                             userInfo: [NSLocalizedDescriptionKey: "Prompt too long (\(prompt.count) characters). Please shorten your message."])
            }
            
            // Use the new streaming implementation
            try await streamResponseWithLlamaCpp(context: context, prompt: prompt, onToken: onToken)
            
        } catch {
            throw error
        }
    }

    private func streamResponseWithLlamaCpp(context: UnsafeMutableRawPointer, prompt: String, onToken: @escaping (String) async -> Void) async throws {
        // Ensure the model name is valid and available
        guard let modelName = currentModelFilename, !modelName.isEmpty else {
            throw NSError(domain: "LLMService", code: 12, userInfo: [NSLocalizedDescriptionKey: "Model name not available for streaming."])
        }

        // Use async/await with proper completion handling
        return try await withCheckedThrowingContinuation { continuation in
            // Track completion state to prevent multiple continuations
            var hasCompleted = false

            // Capture Swift strings for safe use inside the background block
            let promptToSend = prompt
            let modelNameToSend = modelName

            // Timeout for the entire streaming operation
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: 60_000_000_000) // 60 seconds
                if !hasCompleted {
                    hasCompleted = true
                    print("❌ LLMService: Streaming generation timed out.")
                    continuation.resume(throwing: NSError(domain: "LLMService", code: 14, userInfo: [NSLocalizedDescriptionKey: "Streaming generation timed out."]))
                }
            }

            // Call the C++ bridge function from a background thread
            DispatchQueue.global(qos: .userInitiated).async {
                modelNameToSend.withCString { modelNameCString in
                    promptToSend.withCString { promptCString in
                        llm_bridge_generate_stream_block(context, modelNameCString, promptCString, { piece in
                            if let piece = piece {
                                if let text = String(cString: piece, encoding: .utf8) {
                                    Task { await onToken(text) }
                                }
                            } else {
                                if !hasCompleted {
                                    hasCompleted = true
                                    timeoutTask.cancel()
                                    continuation.resume(returning: ())
                                }
                            }
                        }, 512)
                    }
                }
            }
        }
    }
    
    private func buildPrompt(userText: String, history: [ChatMessage]?) -> String {
        print("🔍 LLMService: buildPrompt called with history count: \(history?.count ?? 0)")
        if let history = history, !history.isEmpty {
            print("🔍 LLMService: Building prompt with \(history.count) history messages for model \(currentModelFilename ?? "unknown")")
            for (index, message) in history.enumerated() {
                print("  Message \(index): \(message.isUser ? "User" : "Assistant") - \(String(message.content.prefix(50)))")
            }
        } else {
            print("🔍 LLMService: Building fresh prompt (no history) for model \(currentModelFilename ?? "unknown")")
        }
        
        let systemPrompt = LanguageService.shared.getSystemPrompt()
        let modelFilename = currentModelFilename?.lowercased() ?? ""
        
        print("🔍 LLMService: Building prompt for model: \(currentModelFilename ?? "unknown") using chat template")
        return buildPromptUsingChatTemplate(userText: userText, history: history, systemPrompt: systemPrompt)
    }
    
    private func buildPromptUsingChatTemplate(userText: String, history: [ChatMessage]?, systemPrompt: String) -> String {
        let bufferLen = 32768
        var buf = [Int8](repeating: 0, count: bufferLen)

        // Roles and contents for system + history + current user
        let roleStrings: [String] = {
            var arr: [String] = ["system"]
            if let history = history {
                for m in history { arr.append(m.isUser ? "user" : "assistant") }
            }
            arr.append("user")
            return arr
        }()
        let contentStrings: [String] = {
            var arr: [String] = [systemPrompt]
            if let history = history {
                for m in history { arr.append(m.content) }
            }
            arr.append(userText)
            return arr
        }()

        var cRolePtrs: [UnsafePointer<CChar>?] = roleStrings.map { s in s.withCString { UnsafePointer(strdup($0)) } }
        var cContentPtrs: [UnsafePointer<CChar>?] = contentStrings.map { s in s.withCString { UnsafePointer(strdup($0)) } }

        let written: Int = cRolePtrs.withUnsafeBufferPointer { rbuf in
            cContentPtrs.withUnsafeBufferPointer { cbuf in
                Int(llm_bridge_apply_chat_template_messages(rbuf.baseAddress, cbuf.baseAddress, Int32(contentStrings.count), true, &buf, Int32(bufferLen)))
            }
        }

        // Free duplicated C strings
        for p in cRolePtrs { if let p = p { free(UnsafeMutablePointer(mutating: p)) } }
        for p in cContentPtrs { if let p = p { free(UnsafeMutablePointer(mutating: p)) } }

        if written > 0, let prompt = String(validatingUTF8: buf) {
            print("🔍 LLMService: Applied model chat template (\(written) bytes)")
            return prompt
        } else {
            print("❌ LLMService: Chat template application failed; returning user text only")
            return userText
        }
    }
    
    // Removed model-specific manual prompt builders. All models use chat template.
    
    /// Clear any potential state to ensure fresh calls
    func clearState() {
        print("LLMService: clearState() - clearing all state variables")
        
        // Clear conversation state
        conversationCount = 0
        
        // Clear operation flags
        isChatOperationInProgress = false
        isModelOperationInProgress = false
        
        // Reset operation timing
        lastOperationTime = Date()
        
        // Force unload model synchronously
        Task {
            try? await forceUnloadModel()
        }
        
        print("LLMService: clearState() completed - all state cleared")
    }

    private func getErrorMessage(for error: Error) -> String {
        if let nsError = error as NSError? {
            switch nsError.code {
            case 7:
                return "Model loading timed out. Please try a smaller model."
            case 6:
                return "Input too long. Please use shorter text."
            case 9:
                return "Model was unloaded. Please try again."
            case 10:
                return "Empty input text. Please provide some text to process."
            case 11:
                return "Another operation is in progress. Please wait and try again."
            default:
                return error.localizedDescription
            }
        }
        return error.localizedDescription
    }
}