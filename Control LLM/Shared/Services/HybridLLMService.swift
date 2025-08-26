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
        onToken: @escaping (String) async -> Void
    ) async throws {
        guard isModelLoaded else {
            throw HybridLLMError.modelNotLoaded
        }

        // Cancel any existing generation task
        currentGenerationTask?.cancel()
        
        // Create new cancellable task for generation
        currentGenerationTask = Task { [weak self] in
            guard let self = self else { return }
            
            // Donate the user's prompt to Shortcuts
            ShortcutsIntegrationHelper.shared.donateMessageSent(message: userText)
            
            print("🔍 HybridLLMService: Generating response with \(currentEngine.description)")
            
            do {
                switch currentEngine {
                case .llamaCpp:
                    try await llamaCppService.chat(
                        user: userText,
                        history: history,
                        onToken: { partialResponse in
                            // Check if task was cancelled
                            if Task.isCancelled { return }
                            Task { await onToken(partialResponse) }
                        }
                    )
                    
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
    }
    
    // MARK: - Cancellation Support
    
    func stopGeneration() {
        print("🔍 HybridLLMService: Stopping generation")
        currentGenerationTask?.cancel()
        currentGenerationTask = nil
        
        // Cancel the underlying LLM generation
        switch currentEngine {
        case .llamaCpp:
            llamaCppService.cancelGeneration()
        case .ollama:
            // Ollama doesn't support streaming cancellation in our implementation
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
        let systemPrompt = "You are a helpful AI assistant. Please respond in the same language as the user's prompt. If you are unable to understand or respond in that language, please default to responding in English."
        
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
            return "No model loaded"
        }
        
        return "\(currentEngine.description): \(currentModelFilename ?? "Unknown")"
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
            return "No model selected"
        case .modelNotLoaded:
            return "Model not loaded"
        case .engineNotAvailable(let engine):
            return "\(engine.description) engine not available"
        case .llamaCppError(let error):
            return "llama.cpp error: \(error.localizedDescription)"
        case .ollamaError(let error):
            return "Ollama error: \(error.localizedDescription)"
        }
    }
}
