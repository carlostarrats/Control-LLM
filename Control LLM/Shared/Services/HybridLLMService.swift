import Foundation

@MainActor
final class HybridLLMService: ObservableObject {
    static let shared = HybridLLMService()
    
    @Published var isModelLoaded = false
    @Published var currentModelFilename: String?
    @Published var currentEngine: LLMEngine = .llamaCpp
    
    private let llamaCppService = LLMService.shared
    private let ollamaService = OllamaService.shared
    
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
            try await llamaCppService.loadSelectedModel()
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

        // Donate the user's prompt to Shortcuts
        ShortcutsIntegrationHelper.shared.donateMessageSent(message: userText)
        
        print("🔍 HybridLLMService: Generating response with \(currentEngine.description)")
        
        switch currentEngine {
        case .llamaCpp:
            try await llamaCppService.chat(
                user: userText,
                history: history,
                onToken: onToken
            )
            
        case .ollama:
            // Build prompt using existing logic but adapted for Ollama
            let prompt = buildPrompt(userText: userText, history: history)
            let response = try await ollamaService.generateText(prompt: prompt)
            
            // Call onToken with the complete response
            await onToken(response)
        }
    }
    
    // MARK: - Engine Determination
    
    private func determineEngine(for modelFilename: String) -> LLMEngine {
        let lowercased = modelFilename.lowercased()
        
        // Use Ollama for Qwen if desired; DeepSeek removed
        if lowercased.contains("qwen") {
            return .ollama
        }
        
        // Use llama.cpp for other models (like Gemma)
        return .llamaCpp
    }
    
    // MARK: - Prompt Building
    
    private func buildPrompt(userText: String, history: [ChatMessage]?) -> String {
        let systemPrompt = "You are a helpful AI assistant. You provide clear, accurate, and helpful responses to user questions and requests."
        
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
