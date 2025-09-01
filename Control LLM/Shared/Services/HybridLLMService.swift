import Foundation

@MainActor
final class HybridLLMService: ObservableObject {
    static let shared = HybridLLMService()
    
    @Published var isModelLoaded = false
    @Published var currentModelFilename: String?
    @Published var currentEngine: LLMEngine = .llamaCpp
    
    private let llamaCppService = LLMService.shared
    private let ollamaService = OllamaService.shared
    
    // Add cancellation support
    private var currentGenerationTask: Task<Void, Error>?
    
    // CRITICAL FIX: Add async-safe semaphore to prevent concurrent access to generateResponse
    private let serviceSemaphore = AsyncSemaphore(value: 1)
    
    private init() {}
    
    enum LLMEngine {
        case llamaCpp
        case ollama
        
        var description: String {
            switch self {
            case .llamaCpp: return "llama.cpp"
            case .ollama: return "Ollama"
            }
        }
    }
    
    // MARK: - Model Loading
    
    func loadSelectedModel() async throws {
        guard let modelFilename = ModelManager.shared.getSelectedModelFilename() else {
            throw HybridLLMError.noModelSelected
        }
        
        print("🔍 HybridLLMService: Loading model: \(modelFilename)")
        
        // Determine which engine to use
        let engine = determineEngine(for: modelFilename)
        
        print("🔍 HybridLLMService: Using \(engine.description) for \(modelFilename)")
        
        // Load model with appropriate service
        switch engine {
        case .llamaCpp:
            try await llamaCppService.loadModel(modelFilename)
        case .ollama:
            do {
                try await ollamaService.loadModel(modelFilename)
            } catch {
                print("❌ HybridLLMService: Failed to load Ollama model \(modelFilename): \(error)")
                throw error
            }
        }
        
        // Update state
        await MainActor.run {
            self.currentModelFilename = modelFilename
            self.currentEngine = engine
            self.isModelLoaded = true
        }
        
        print("✅ HybridLLMService: Model loaded with \(engine.description)")
    }
    
    func forceUnloadModel() async throws {
        print("🔍 HybridLLMService: Force unloading model")
        
        switch currentEngine {
        case .llamaCpp:
            try await llamaCppService.forceUnloadModel()
        case .ollama:
            await ollamaService.unloadModel()
        }
        
        await MainActor.run {
            self.currentModelFilename = nil
            self.isModelLoaded = false
        }
    }
    
    // MARK: - Text Generation
    
    func generateResponse(
        userText: String,
        history: [ChatMessage]? = nil,
        useRawPrompt: Bool = false,
        maxTokens: Int = 2048,
        onToken: @escaping (String) async -> Void
    ) async throws {
        // CRITICAL FIX: Use async semaphore to prevent concurrent access
        await serviceSemaphore.wait()
        
        do {
            guard isModelLoaded else {
                throw HybridLLMError.modelNotLoaded
            }

        // Cancel any existing generation task
        currentGenerationTask?.cancel()
        
        // DEBUG: Log the useRawPrompt parameter
        print("🔍 HybridLLMService: generateResponse called with useRawPrompt: \(useRawPrompt)")
        
        // Create new cancellable task for generation
        currentGenerationTask = Task { [weak self, useRawPrompt] in
            guard let self = self else { return }
            
            // Donate the user's prompt to Shortcuts
            ShortcutsIntegrationHelper.shared.donateMessageSent(message: userText)
            
            print("🔍 HybridLLMService: Generating response with \(currentEngine.description)")
            print("🔍 HybridLLMService: useRawPrompt flag: \(useRawPrompt)")
            
            do {
                switch currentEngine {
                case .llamaCpp:
                    if useRawPrompt {
                        print("🔍 HybridLLMService: Using chatRaw path")
                        try await llamaCppService.chatRaw(
                            prompt: userText,
                            maxTokens: maxTokens,
                            onToken: { partialResponse in
                                if Task.isCancelled { return }
                                Task { await onToken(partialResponse) }
                            }
                        )
                    } else {
                        print("🔍 HybridLLMService: Using regular chat path")
                        try await llamaCppService.chat(
                            user: userText,
                            history: history,
                            maxTokens: maxTokens,
                            onToken: { partialResponse in
                                if Task.isCancelled { return }
                                Task { await onToken(partialResponse) }
                            }
                        )
                    }
                    
                case .ollama:
                    // Build prompt using existing logic but adapted for Ollama
                    let prompt = buildPrompt(userText: userText, history: history)
                    let response = try await ollamaService.generateText(prompt: prompt)
                    
                    // Check if task was cancelled before calling onToken
                    if !Task.isCancelled {
                        await onToken(response)
                    }
                }
            } catch {
                // Only log error if not cancelled
                if !Task.isCancelled {
                    print("❌ HybridLLMService: Error in generation: \(error)")
                    throw error
                }
            }
        }
        
        // Wait for the task to complete or be cancelled
        _ = try? await currentGenerationTask?.value
        
        // Signal semaphore after successful completion
        await serviceSemaphore.signal()
        
    } catch {
        // Signal semaphore before re-throwing the error
        await serviceSemaphore.signal()
        throw error
    }
    }
    
    // MARK: - Non-streaming Generation (for PDF processing)
    
    func generateResponseSync(
        userText: String,
        history: [ChatMessage]? = nil,
        useRawPrompt: Bool = false,
        maxTokens: Int = 2048
    ) async throws -> String {
        // CRITICAL FIX: Use async semaphore to prevent concurrent access
        await serviceSemaphore.wait()
        
        do {
            guard isModelLoaded else {
                throw HybridLLMError.modelNotLoaded
            }
            
            print("🔍 HybridLLMService: generateResponseSync called with useRawPrompt: \(useRawPrompt)")
            
            var result = ""
            
            switch currentEngine {
            case .llamaCpp:
                if useRawPrompt {
                    print("🔍 HybridLLMService: Using chatRaw path (sync)")
                    try await llamaCppService.chatRaw(
                        prompt: userText,
                        maxTokens: maxTokens,
                        onToken: { partialResponse in
                            result += partialResponse
                        }
                    )
                } else {
                    print("🔍 HybridLLMService: Using regular chat path (sync)")
                    try await llamaCppService.chat(
                        user: userText,
                        history: history,
                        maxTokens: maxTokens,
                        onToken: { partialResponse in
                            result += partialResponse
                        }
                    )
                }
                
            case .ollama:
                // Build prompt using existing logic but adapted for Ollama
                let prompt = buildPrompt(userText: userText, history: history)
                result = try await ollamaService.generateText(prompt: prompt)
            }
            
            // Signal semaphore after successful completion
            await serviceSemaphore.signal()
            return result
            
        } catch {
            // Signal semaphore before re-throwing the error
            await serviceSemaphore.signal()
            throw error
        }
    }
    
    // MARK: - Cancellation Support (Phase 4: Enhanced Reliability)
    
    func stopGeneration() {
        print("🔍 HybridLLMService: PHASE 4 - Stopping generation with enhanced reliability")
        
        // Cancel the current generation task
        currentGenerationTask?.cancel()
        currentGenerationTask = nil
        
        // Cancel the underlying LLM generation with enhanced logic
        switch currentEngine {
        case .llamaCpp:
            print("🔍 HybridLLMService: PHASE 4 - Cancelling llama.cpp generation")
            llamaCppService.cancelGeneration()
            
            // Wait briefly for cancellation to take effect
            Task {
                try? await Task.sleep(nanoseconds: UInt64(Constants.maxCancellationWaitTime) * 1_000_000)
                
                // Verify cancellation took effect
                if currentGenerationTask != nil {
                    print("⚠️ HybridLLMService: PHASE 4 - Cancellation may not have taken effect, forcing cleanup")
                    currentGenerationTask?.cancel()
                    currentGenerationTask = nil
                }
            }
            
        case .ollama:
            print("🔍 HybridLLMService: PHASE 4 - Ollama doesn't support streaming cancellation, but cleaning up tasks")
            // Ollama doesn't support streaming cancellation in our implementation
            // But we can still clean up our task references
            break
        }
    }
    
    // MARK: - Engine Determination
    
    private func determineEngine(for modelFilename: String) -> LLMEngine {
        let lowercased = modelFilename.lowercased()
        
        // Use llama.cpp for all GGUF models (which is what we have locally)
        if lowercased.hasSuffix(".gguf") {
            return .llamaCpp
        }
        
        // Use llama.cpp as default for all models
        return .llamaCpp
    }
    
    // MARK: - Prompt Building
    
    private func buildPrompt(userText: String, history: [ChatMessage]?) -> String {
        // For clipboard analysis, integrate the system prompt directly into the user message
        // This prevents the LLM from responding to the system prompt instead of the content
        let systemPrompt = NSLocalizedString("LLM System Prompt", comment: "")
        
        // Use a simple, universal format that works well with Ollama
        var fullPrompt = systemPrompt + "\n\n"
        
        // Add conversation history if any
        if let history = history, !history.isEmpty {
            for message in history {
                if message.isUser {
                    fullPrompt += "User: \(message.content)\n"
                } else {
                    fullPrompt += "Assistant: \(message.content)\n"
                }
            }
        }
        
        // Add current user message
        fullPrompt += "User: \(userText)\nAssistant:"
        
        return fullPrompt
    }
    
    // MARK: - Health Checks
    
    func checkEngineHealth() async -> (llamaCpp: Bool, ollama: Bool) {
        async let llamaCppHealthy = checkLlamaCppHealth()
        async let ollamaHealthy = ollamaService.checkServerHealth()
        
        return await (llamaCpp: llamaCppHealthy, ollama: ollamaHealthy)
    }
    
    private func checkLlamaCppHealth() async -> Bool {
        // llama.cpp is embedded, so it's always "healthy" if the app runs
        return true
    }
    
    // MARK: - Status Methods
    
    func getCurrentEngineInfo() -> String {
        if !isModelLoaded {
            return NSLocalizedString("No model loaded", comment: "")
        }
        
        return "\(currentEngine.description): \(currentModelFilename ?? NSLocalizedString("Unknown", comment: ""))"
    }
}

// MARK: - Error Types

enum HybridLLMError: Error {
    case noModelSelected
    case modelNotLoaded
    case engineNotAvailable(HybridLLMService.LLMEngine)
    case llamaCppError(Error)
    case ollamaError(Error)
    
    var localizedDescription: String {
        switch self {
        case .noModelSelected:
            return NSLocalizedString("No model selected", comment: "")
        case .modelNotLoaded:
            return NSLocalizedString("Model not loaded", comment: "")
        case .engineNotAvailable(let engine):
            return "\(engine.description) engine not available"
        case .llamaCppError(let error):
            return String(format: NSLocalizedString("llama.cpp error: %@", comment: ""), error.localizedDescription)
        case .ollamaError(let error):
            return String(format: NSLocalizedString("Ollama error: %@", comment: ""), error.localizedDescription)
        }
    }
}
