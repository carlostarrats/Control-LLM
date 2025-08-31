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
    private var _isMultiPassMode = false             // For multi-pass processing
    private var lastOperationTime: Date = Date()  // Track when operations start
    
    /// Public read-only access to multi-pass mode status
    var isMultiPassMode: Bool {
        return _isMultiPassMode
    }
    
    /// Cancel ongoing LLM generation (Phase 4: Enhanced Reliability)
    func cancelGeneration() {
        print("🔍 LLMService: PHASE 4 - Cancelling ongoing generation with enhanced reliability")
        
        // Set the cancellation flag in the C bridge
        llm_bridge_cancel_generation()
        
        // Reset the operation in progress flag to allow new operations
        isModelOperationInProgress = false
        
        print("🔍 LLMService: PHASE 4 - Cancellation flag set and operation flags reset")
    }
    
    /// Enable multi-pass mode to prevent concurrency errors during multi-pass processing
    func enableMultiPassMode() {
        print("🔧 LLMService: Enabling multi-pass mode")
        _isMultiPassMode = true
        isChatOperationInProgress = true
    }
    
    /// Disable multi-pass mode and reset chat operation flags
    func disableMultiPassMode() {
        print("🔧 LLMService: Disabling multi-pass mode")
        _isMultiPassMode = false
        isChatOperationInProgress = false
    }
    
    /// Load a specific model by filename with optimized performance
    func loadModel(_ modelFilename: String) async throws {
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
        
        // OPTIMIZATION: Check if we're already loading the same model
        if currentModelFilename == modelFilename && isModelLoaded {
            print("🔍 LLMService: Model \(modelFilename) already loaded, skipping reload")
            return
        }
        
        isModelOperationInProgress = true
        lastOperationTime = Date()
        defer { 
            isModelOperationInProgress = false 
        }
        
        print("🔍 LLMService: Loading specific model: \(modelFilename) (previous: \(currentModelFilename ?? "none"))")
        
        // OPTIMIZATION: Find model file with priority order for fastest access
        let modelURL = try await findModelFile(for: modelFilename)
        
        // OPTIMIZATION: Clear previous model to free memory before loading new one
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
    
    /// Load the currently selected model from ModelManager
    func loadSelectedModel() async throws {
        guard let modelFilename = ModelManager.shared.getSelectedModelFilename() else {
            throw NSError(domain: "LLMService",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "No model selected"])
        }
        
        // Use the optimized loadModel method to avoid code duplication
        try await loadModel(modelFilename)
    }
    
    /// OPTIMIZATION: Find model file with priority order for fastest access
    private func findModelFile(for modelFilename: String) async throws -> URL {
        // Priority 1: Models directory (fastest - bundled with app)
        if let modelsDir = Bundle.main.url(forResource: "Models", withExtension: nil) {
            let modelUrl = modelsDir.appendingPathComponent("\(modelFilename).gguf")
            if FileManager.default.fileExists(atPath: modelUrl.path) {
                print("🔍 LLMService: Found model in Models directory: \(modelUrl.path)")
                return modelUrl
            }
        }
        
        // Priority 2: Bundle root (medium - also bundled)
        if let rootUrl = Bundle.main.url(forResource: modelFilename, withExtension: "gguf", subdirectory: nil) {
            print("🔍 LLMService: Found model in bundle root: \(rootUrl.path)")
            return rootUrl
        }
        
        // Priority 3: Documents/Models (slowest - file system access)
        if let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let modelsDir = docsDir.appendingPathComponent("Models", isDirectory: true)
            let docUrl = modelsDir.appendingPathComponent("\(modelFilename).gguf")
            if FileManager.default.fileExists(atPath: docUrl.path) {
                print("🔍 LLMService: Found model in Documents/Models: \(docUrl.path)")
                return docUrl
            }
        }
        
        print("❌ LLMService: Model file not found anywhere: \(modelFilename).gguf")
        throw NSError(domain: "LLMService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Model file not found in any location"])
    }
    
    private func unloadModel() {
        print("🔍 LLMService: Unloading model and cleaning up resources")
        
        // Safety check: prevent double-free
        guard llamaModel != nil || llamaContext != nil else {
            print("🔍 LLMService: No model resources to free - already clean")
            return
        }
        
        // CRASH FIX: Sequential cleanup to prevent race conditions and memory access violations
        // Free context first (it depends on the model)
        if let context = llamaContext {
            print("🔍 LLMService: Freeing context...")
            llm_bridge_free_context(context)
            llamaContext = nil
            print("🔍 LLMService: Context freed")
        }
        
        // Then free model
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
            // CRASH PROTECTION: Reset pointers before initialization
            self.llamaModel = nil
            self.llamaContext = nil
            
            // CRASH PROTECTION: Validate model path exists
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: modelPath) else {
                print("❌ LLMService: Model file does not exist at path: \(modelPath)")
                throw NSError(domain: "LLMService", code: 13, userInfo: [NSLocalizedDescriptionKey: "Model file not found at specified path"])
            }
            
            // CRASH PROTECTION: Check file size to ensure it's not corrupted
            do {
                let attributes = try fileManager.attributesOfItem(atPath: modelPath)
                let fileSize = attributes[.size] as? Int64 ?? 0
                if fileSize < 1000000 { // Less than 1MB
                    print("❌ LLMService: Model file appears too small (\(fileSize) bytes), may be corrupted")
                    throw NSError(domain: "LLMService", code: 14, userInfo: [NSLocalizedDescriptionKey: "Model file appears corrupted or too small"])
                }
            } catch {
                print("⚠️ LLMService: Could not validate model file attributes: \(error)")
            }
            
            modelPath.withCString { cString in
                self.llamaModel = llm_bridge_load_model(cString)
            }
            
            // CRASH PROTECTION: Validate model pointer
            guard let model = self.llamaModel else {
                throw NSError(domain: "LLMService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to load model - bridge returned NULL"])
            }
            
            // CRASH PROTECTION: Validate model pointer is not a dangling reference
            if model == UnsafeMutableRawPointer(bitPattern: 0x1) || model == UnsafeMutableRawPointer(bitPattern: 0x0) {
                throw NSError(domain: "LLMService", code: 15, userInfo: [NSLocalizedDescriptionKey: "Failed to load model - bridge returned invalid pointer"])
            }
            
            // CRASH PROTECTION: Create context with error handling
            self.llamaContext = llm_bridge_create_context(model)
            
            // CRASH PROTECTION: Validate context pointer
            guard let context = self.llamaContext else {
                // Clean up the model if context creation fails
                llm_bridge_free_model(model)
                self.llamaModel = nil
                throw NSError(domain: "LLMService", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to create context - bridge returned NULL"])
            }
            
            // CRASH PROTECTION: Validate context pointer is not a dangling reference
            if context == UnsafeMutableRawPointer(bitPattern: 0x1) || context == UnsafeMutableRawPointer(bitPattern: 0x0) {
                // Clean up both model and context
                llm_bridge_free_context(context)
                llm_bridge_free_model(model)
                self.llamaModel = nil
                self.llamaContext = nil
                throw NSError(domain: "LLMService", code: 16, userInfo: [NSLocalizedDescriptionKey: "Failed to create context - bridge returned invalid pointer"])
            }
        }.value
        
        self.isModelLoaded = true
        print("✅ LLMService: Model loaded successfully with llama.cpp")
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
    func chat(user text: String, history: [ChatMessage]? = nil, maxTokens: Int = 8192, onToken: @escaping (String) async -> Void) async throws {
        print("🔍🔍🔍 LLMService.chat: ENTRY POINT - userText parameter: '\(text.prefix(100))...'")
        print("🔍 LLMService.chat: History count: \(history?.count ?? 0)")
        // Safety mechanism: if the flag has been stuck for more than 5 minutes, reset it
        if isChatOperationInProgress {
            let timeSinceLastOperation = Date().timeIntervalSince(lastOperationTime)
            if timeSinceLastOperation > 300 { // 5 minutes
                print("⚠️ WARNING: isChatOperationInProgress flag stuck for \(Int(timeSinceLastOperation)) seconds, resetting")
                isChatOperationInProgress = false
            }
        }
        
        // Prevent concurrent chat operations (unless in multi-pass mode)
        if !_isMultiPassMode {
            guard !isChatOperationInProgress else {
                throw NSError(domain: "LLMService", code: 22, userInfo: [NSLocalizedDescriptionKey: "Another chat operation is in progress"])
            }
            
            isChatOperationInProgress = true
            lastOperationTime = Date()
            
            // Ensure the flag is always reset, even if errors occur (only for single-pass)
            defer { 
                isChatOperationInProgress = false 
            }
        } else {
            print("🔧 LLMService: Multi-pass mode active, skipping concurrency check")
            lastOperationTime = Date()
        }
        
        // Increment conversation counter
        conversationCount += 1
        print("🔍 LLMService: Starting conversation #\(conversationCount) with model \(currentModelFilename ?? "unknown")")
        
        // Validate input text
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NSError(domain: "LLMService",
                          code: 23,
                          userInfo: [NSLocalizedDescriptionKey: "Empty or whitespace-only input"])
        }
        
        // Check input length to prevent memory issues
        let maxInputLength = Constants.maxInputLength // Increased limit for file uploads - allows ~2-3 pages of content
        var processedText = text
        if processedText.count > maxInputLength {
            print("⚠️ WARNING: Input text too long (\(processedText.count) chars), truncating to \(maxInputLength)")
            let truncatedText = String(processedText.prefix(maxInputLength))
            print("🔍 DEBUG: Truncated text: '\(truncatedText)'")
            processedText = truncatedText
            
            // Throw error to inform user about truncation
            throw NSError(domain: "LLMService",
                          code: 26,
                          userInfo: [NSLocalizedDescriptionKey: "Input text was too long (\(processedText.count) characters) and was truncated to \(maxInputLength) characters. Please shorten your message to avoid losing important information."])
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
                guard let context = llamaContext else {
                    throw NSError(domain: "LLMService", code: 21, userInfo: [NSLocalizedDescriptionKey: "Failed to recreate context"])
                }
                // CRASH PROTECTION: Validate recreated context pointer
                if context == UnsafeMutableRawPointer(bitPattern: 0x1) || context == UnsafeMutableRawPointer(bitPattern: 0x0) {
                    llamaContext = nil
                    throw NSError(domain: "LLMService", code: 25, userInfo: [NSLocalizedDescriptionKey: "Failed to recreate context - invalid pointer"])
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
                          code: 24,
                          userInfo: [NSLocalizedDescriptionKey: "Model not loaded"])
        }
        
        do {
            // Build the prompt using the new helper
            let prompt = buildPrompt(userText: processedText, history: history)
            
            print("🔍 LLMService: Final prompt length: \(prompt.count) characters")
            print("🔍 LLMService: Final prompt preview: \(String(prompt.prefix(200)))...")
            
            // Safety check for extremely long prompts
            // Increased to match maxInputLength and model's actual context window (32768 tokens)
            let maxPromptLength = 16000 // Increased from 4096 to handle larger contexts
            if prompt.count > maxPromptLength {
                throw NSError(domain: "LLMService",
                             code: 6, 
                             userInfo: [NSLocalizedDescriptionKey: "Prompt too long (\(prompt.count) characters). Please shorten your message."])
            }
            
            // CRITICAL FIX: Add specific check for multi-pass processing prompts
            // Multi-pass prompts can be complex and need extra validation
                    if prompt.count > Constants.criticalThreshold {
            print("⚠️ WARNING: Multi-pass prompt is very long (\(prompt.count) characters). This may cause tokenization issues.")
            print("🔍 Prompt preview: \(String(prompt.prefix(500)))...")
        }
        
        // Warning for prompts approaching token limits
        let warningThreshold = Constants.warningThreshold // Characters
        if prompt.count > warningThreshold {
                print("⚠️ WARNING: Prompt is long (\(prompt.count) characters) and may approach token limits. Consider shortening your message or clearing chat history.")
            }
            
            // Use the new streaming implementation
            try await streamResponseWithLlamaCpp(context: context, prompt: prompt, maxTokens: maxTokens, onToken: onToken)
            
        } catch {
            throw error
        }
    }

    /// Stream tokens for a raw prompt (bypass chat template entirely)
    func chatRaw(prompt rawPrompt: String, maxTokens: Int = 8192, onToken: @escaping (String) async -> Void) async throws {
        // Ensure model is ready
        if !isModelLoaded { try await loadSelectedModel() }
        guard let context = llamaContext else {
            throw NSError(domain: "LLMService", code: 24, userInfo: [NSLocalizedDescriptionKey: "Model not loaded"])
        }

        // Minimal validation
        let prompt = rawPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else {
            throw NSError(domain: "LLMService", code: 18, userInfo: [NSLocalizedDescriptionKey: "Empty prompt for streaming"]) 
        }

        // Stream directly
        try await streamResponseWithLlamaCpp(context: context, prompt: prompt, maxTokens: maxTokens, onToken: onToken)
    }

    private func streamResponseWithLlamaCpp(context: UnsafeMutableRawPointer, prompt: String, maxTokens: Int = 8192, onToken: @escaping (String) async -> Void) async throws {
        // CRASH PROTECTION: Validate context pointer
        guard context != UnsafeMutableRawPointer(bitPattern: 0x0) && context != UnsafeMutableRawPointer(bitPattern: 0x1) else {
            print("❌ LLMService: Invalid context pointer in streamResponseWithLlamaCpp")
            throw NSError(domain: "LLMService", code: 17, userInfo: [NSLocalizedDescriptionKey: "Invalid context pointer for streaming"])
        }
        
        // Ensure the model name is valid and available
        guard let modelName = currentModelFilename, !modelName.isEmpty else {
            throw NSError(domain: "LLMService", code: 12, userInfo: [NSLocalizedDescriptionKey: "Model name not available for streaming."])
        }

        // CRASH PROTECTION: Validate prompt
        guard !prompt.isEmpty else {
            print("❌ LLMService: Empty prompt in streamResponseWithLlamaCpp")
            throw NSError(domain: "LLMService", code: 18, userInfo: [NSLocalizedDescriptionKey: "Empty prompt for streaming"])
        }

        // Use async/await with proper completion handling
        return try await withCheckedThrowingContinuation { continuation in
            // Track completion state to prevent multiple continuations
            var hasCompleted = false

            // Capture Swift strings for safe use inside the background block
            let promptToSend = prompt
            let modelNameToSend = modelName

            // Timeout for the entire streaming operation
            // Increased timeout for multi-pass processing scenarios
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: 180_000_000_000) // 180 seconds (3 minutes)
                if !hasCompleted {
                    hasCompleted = true
                    print("❌ LLMService: Streaming generation timed out.")
                    continuation.resume(throwing: NSError(domain: "LLMService", code: 20, userInfo: [NSLocalizedDescriptionKey: "Streaming generation timed out. This may happen with very large documents requiring multi-pass processing."]))
                }
            }

            // Call the C++ bridge function from a background thread
            DispatchQueue.global(qos: .userInitiated).async {
                // CRASH PROTECTION: Validate strings before converting to C strings
                guard !modelNameToSend.isEmpty, !promptToSend.isEmpty else {
                    print("❌ LLMService: Empty strings before C string conversion")
                    if !hasCompleted {
                        hasCompleted = true
                        timeoutTask.cancel()
                        continuation.resume(throwing: NSError(domain: "LLMService", code: 19, userInfo: [NSLocalizedDescriptionKey: "Invalid strings for C++ bridge"]))
                    }
                    return
                }
                
                modelNameToSend.withCString { modelNameCString in
                    promptToSend.withCString { promptCString in
                        print("🔧 LLMService: Calling llm_bridge_generate_stream_block...")
                        llm_bridge_generate_stream_block(context, modelNameCString, promptCString, { piece in
                            if let piece = piece {
                                let pieceString = String(cString: piece, encoding: .utf8) ?? ""
                                
                                // Check for token limit marker
                                if pieceString == "__TOKEN_LIMIT_REACHED__" {
                                    print("⚠️ WARNING: Token limit reached during generation")
                                    if !hasCompleted {
                                        hasCompleted = true
                                        timeoutTask.cancel()
                                        continuation.resume(throwing: NSError(domain: "LLMService", 
                                                                           code: 27, 
                                                                           userInfo: [NSLocalizedDescriptionKey: "Response generation reached the maximum token limit (8000 tokens). The response may be incomplete. Consider asking a more specific question or breaking your request into smaller parts."]))
                                    }
                                    return
                                }
                                
                                if !pieceString.isEmpty {
                                    Task { await onToken(pieceString) }
                                }
                            } else {
                                if !hasCompleted {
                                    hasCompleted = true
                                    timeoutTask.cancel()
                                    // Call completion callback when streaming finishes
                                    continuation.resume(returning: ())
                                }
                            }
                        }, Int32(maxTokens))
                    }
                }
            }
        }
    }
    
    private func buildPrompt(userText: String, history: [ChatMessage]?) -> String {
        print("🔍🔍🔍 LLMService.buildPrompt: ENTRY POINT - userText parameter: '\(userText.prefix(100))...'")
        print("🔍 LLMService: buildPrompt called with history count: \(history?.count ?? 0)")
        if let history = history, !history.isEmpty {
            print("🔍 LLMService: Building prompt with \(history.count) history messages for model \(currentModelFilename ?? "unknown")")
            for (index, message) in history.enumerated() {
                print("  Message \(index): \(message.isUser ? "User" : "Assistant") - \(String(message.content.prefix(50)))")
            }
        } else {
            print("🔍 LLMService: Building fresh prompt (no history) for model \(currentModelFilename ?? "unknown")")
        }
        

        
        let systemPrompt = NSLocalizedString("LLM System Prompt", comment: "")
        
        // UNIVERSAL APPROACH: Use the standard chat template system for ALL models
        // This ensures compatibility with any model you switch to
        print("🔍 LLMService: Building prompt for model: \(currentModelFilename ?? "unknown") using universal chat template")
        return buildPromptUsingChatTemplate(userText: userText, history: history, systemPrompt: systemPrompt)
    }
    
    private func buildPromptUsingChatTemplate(userText: String, history: [ChatMessage]?, systemPrompt: String) -> String {
        // UNIVERSAL APPROACH: Use the standard chat template system for ALL models
        print("🔍 LLMService: Using universal chat template for model: \(currentModelFilename ?? "unknown")")
        
        // CRASH PROTECTION: Validate inputs
        guard !userText.isEmpty, !systemPrompt.isEmpty else {
            print("❌ LLMService: Empty userText or systemPrompt in buildPromptUsingChatTemplate")
            return userText // Fallback to user text only
        }
        
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

        // CRASH PROTECTION: Validate arrays before processing
        guard !roleStrings.isEmpty, !contentStrings.isEmpty, roleStrings.count == contentStrings.count else {
            print("❌ LLMService: Invalid role/content arrays in buildPromptUsingChatTemplate")
            return userText // Fallback to user text only
        }
        
        // CRASH PROTECTION: Sanitize content strings to prevent crashes
        let sanitizedContentStrings: [String] = contentStrings.map { content in
            // Remove any potentially problematic characters and ensure valid UTF-8
            let sanitized = content
                .replacingOccurrences(of: "\0", with: "") // Remove null bytes
                .replacingOccurrences(of: "\r", with: "\n") // Normalize line endings
                .trimmingCharacters(in: .whitespacesAndNewlines) // Remove leading/trailing whitespace
            
            // Ensure the string is valid UTF-8 and not empty
            guard !sanitized.isEmpty, sanitized.utf8.count > 0 else {
                return "[Content removed for safety]"
            }
            
            return sanitized
        }

        let cRolePtrs: [UnsafePointer<CChar>?] = roleStrings.map { s in s.withCString { UnsafePointer(strdup($0)) } }
        let cContentPtrs: [UnsafePointer<CChar>?] = sanitizedContentStrings.map { s in s.withCString { UnsafePointer(strdup($0)) } }

        // CRASH PROTECTION: Ensure cleanup happens in all code paths
        defer {
            // Free duplicated C strings - this will run even if function throws or returns early
            for p in cRolePtrs { if let p = p { free(UnsafeMutablePointer(mutating: p)) } }
            for p in cContentPtrs { if let p = p { free(UnsafeMutablePointer(mutating: p)) } }
        }

        // CRASH PROTECTION: Validate C string arrays
        guard cRolePtrs.count == cContentPtrs.count, cRolePtrs.count > 0 else {
            print("❌ LLMService: C string conversion failed in buildPromptUsingChatTemplate")
            return userText // Fallback to user text only
        }

        let written: Int = cRolePtrs.withUnsafeBufferPointer { rbuf in
            cContentPtrs.withUnsafeBufferPointer { cbuf in
                // CRASH PROTECTION: Validate buffer pointers
                guard rbuf.baseAddress != nil, cbuf.baseAddress != nil else {
                    print("❌ LLMService: Invalid buffer pointers in buildPromptUsingChatTemplate")
                    return 0
                }
                
                print("🔧 LLMService: Calling llm_bridge_apply_chat_template_messages...")
                return Int(llm_bridge_apply_chat_template_messages(rbuf.baseAddress, cbuf.baseAddress, Int32(sanitizedContentStrings.count), true, &buf, Int32(bufferLen)))
            }
        }

        if written > 0, let prompt = String(validatingUTF8: buf) {
            print("✅ LLMService: Applied model chat template (\(written) bytes)")
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
        
        // Force unload model asynchronously to prevent race conditions
        // Note: This is a fire-and-forget operation to avoid blocking the UI
        Task.detached(priority: .background) {
            do {
                try await self.forceUnloadModel()
                print("LLMService: clearState() - model unloaded successfully")
            } catch {
                print("⚠️ LLMService: clearState() - model unload failed: \(error)")
            }
        }
        
        print("LLMService: clearState() completed - state variables cleared, model unload initiated")
    }

    private func getErrorMessage(for error: Error) -> String {
        if let nsError = error as NSError? {
            switch nsError.code {
            case 1:
                return "No model selected. Please select a model first."
            case 2:
                return "Model file not found in bundle root. Please check your model installation."
            case 3:
                return "No model path available. Please select a model first."
            case 4:
                return "Failed to load model. Please try again."
            case 5:
                return "Failed to create model context. Please try again."
            case 6:
                return "Prompt too long. Please shorten your message."
            case 7:
                return "Model loading timed out. Please try a smaller model."
            case 8:
                return "No result from timeout operation. Please try again."
            case 9:
                return "Operation failed due to internal error. Please try again."
            case 10:
                return "Operation was cancelled or interrupted. Please try again."
            case 11:
                return "Another operation is in progress. Please wait and try again."
            case 12:
                return "Model name not available for streaming. Please try again."
            case 13:
                return "Model file not found. Please check your model installation."
            case 14:
                return "Model file appears corrupted. Please reinstall the model."
            case 15:
                return "Failed to load model due to invalid pointer. Please try again."
            case 16:
                return "Failed to create context due to invalid pointer. Please try again."
            case 17:
                return "Invalid context pointer for streaming. Please try again."
            case 18:
                return "Empty prompt for streaming. Please provide some text."
            case 19:
                return "Invalid strings for C++ bridge. Please try again."
            case 20:
                return "Streaming generation timed out. Please try again."
            case 21:
                return "Failed to recreate context. Please try again."
            case 22:
                return "Another chat operation is in progress. Please wait and try again."
            case 23:
                return "Empty or whitespace-only input. Please provide some text to process."
            case 24:
                return "Model not loaded. Please select and load a model first."
            case 25:
                return "Failed to recreate context due to invalid pointer. Please try again."
            case 26:
                return "Input text was shortened to fit within limits. If the shortened version doesn't accurately represent your intent, please try a shorter message."
            case 27:
                return "Response generation reached the maximum token limit (8000 tokens). The response may be incomplete. Consider asking a more specific question or breaking your request into smaller parts."
            default:
                return error.localizedDescription
            }
        }
        return error.localizedDescription
    }
}