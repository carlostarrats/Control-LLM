import Foundation

@MainActor
final class OllamaService: ObservableObject {
    static let shared = OllamaService()
    
    private let baseURL = "https://localhost:11434"
    private var session: URLSession
    
    @Published var isModelLoaded = false
    @Published var currentModelName: String?
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        
        // Create secure session with localhost certificate handling
        let delegate = LocalhostCertificateDelegate()
        self.session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
    }
    
    // MARK: - Model Management
    
    func loadModel(_ modelName: String) async throws {
        print("🔍 OllamaService: Loading model: \(modelName)")
        
        // Convert filename to Ollama model name
        let ollamaModelName = convertToOllamaModelName(modelName)
        
        // Check if model is available, if not pull it
        let availableModels = try await listModels()
        let modelExists = availableModels.contains { $0.name.contains(ollamaModelName) }
        
        if !modelExists {
            print("🔍 OllamaService: Model not found, pulling: \(ollamaModelName)")
            try await pullModel(ollamaModelName)
        }
        
        // Pre-warm the model with a quick single-token generation to load it into memory
        do {
            print("🔍 OllamaService: Pre-warming model: \(ollamaModelName)")
            _ = try await preWarmModel(ollamaModelName)
            print("✅ OllamaService: Model pre-warmed successfully: \(ollamaModelName)")
        } catch {
            print("❌ OllamaService: Model pre-warm failed for: \(ollamaModelName), error: \(error)")
            throw error
        }
        
        await MainActor.run {
            self.currentModelName = ollamaModelName
            self.isModelLoaded = true
        }
        
        print("✅ OllamaService: Model loaded successfully: \(ollamaModelName)")
    }
    
    func unloadModel() async {
        print("🔍 OllamaService: Unloading current model")
        await MainActor.run {
            self.currentModelName = nil
            self.isModelLoaded = false
        }
    }
    
    private func preWarmModel(_ modelName: String) async throws -> String {
        print("🔍 OllamaService: Pre-warming model with minimal generation: \(modelName)")
        
        guard let url = URL(string: "https://localhost:11434/api/generate") else {
            throw OllamaError.invalidURL
        }
        
        let requestBody: [String: Any] = [
            "model": modelName,
            "prompt": "Hi",
            "stream": false,
            "options": [
                "num_predict": 1,  // Only generate 1 token to warm up quickly
                "temperature": 0.1,  // Low temperature for consistent, fast response
                "top_p": 0.9
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = 15  // Shorter timeout for warmup
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode != 200 {
                print("❌ OllamaService: Pre-warm failed with status: \(httpResponse.statusCode)")
                throw OllamaError.serverError(httpResponse.statusCode)
            }
        }
        
        guard let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let responseText = jsonResponse["response"] as? String else {
            throw OllamaError.invalidResponse
        }
        
        print("✅ OllamaService: Pre-warm response received (length: \(responseText.count))")
        return responseText
    }
    
    // MARK: - Text Generation
    
    func generateText(prompt: String, modelName: String? = nil) async throws -> String {
        let model = modelName ?? currentModelName ?? "gemma2:2b"
        
        SecureLogger.logModelOperation("Generating text", modelName: model)
        SecureLogger.log("Prompt", sensitiveData: prompt)
        
        guard let url = URL(string: "\(baseURL)/api/generate") else {
            throw OllamaError.invalidURL
        }
        
        let requestBody = OllamaGenerateRequest(
            model: model,
            prompt: prompt,
            stream: false
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OllamaError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw OllamaError.serverError(httpResponse.statusCode)
        }
        
        let ollamaResponse = try JSONDecoder().decode(OllamaGenerateResponse.self, from: data)
        
        SecureLogger.log("Generated response", sensitiveData: ollamaResponse.response)
        return ollamaResponse.response
    }
    
    // MARK: - Model Discovery
    
    func listModels() async throws -> [OllamaModel] {
        guard let url = URL(string: "\(baseURL)/api/tags") else {
            throw OllamaError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OllamaError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        let modelsResponse = try JSONDecoder().decode(OllamaModelsResponse.self, from: data)
        return modelsResponse.models
    }
    
    func pullModel(_ modelName: String) async throws {
        guard let url = URL(string: "\(baseURL)/api/pull") else {
            throw OllamaError.invalidURL
        }
        
        let requestBody = OllamaPullRequest(name: modelName)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw OllamaError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        print("✅ OllamaService: Model pulled successfully: \(modelName)")
    }
    
    // MARK: - Server Health
    
    func checkServerHealth() async -> Bool {
        guard let url = URL(string: "\(baseURL)/api/tags") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        
        do {
            let (_, response) = try await session.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
    
    // MARK: - Helper Methods
    
    private func convertToOllamaModelName(_ filename: String) -> String {
        // Generic conversion - no hardcoded names
        return filename.replacingOccurrences(of: ".gguf", with: "").lowercased()
    }
}

// MARK: - Data Models

struct OllamaGenerateRequest: Codable {
    let model: String
    let prompt: String
    let stream: Bool
}

struct OllamaGenerateResponse: Codable {
    let model: String
    let response: String
    let done: Bool
    let context: [Int]?
    let total_duration: Int?
    let load_duration: Int?
    let prompt_eval_count: Int?
    let prompt_eval_duration: Int?
    let eval_count: Int?
    let eval_duration: Int?
}

struct OllamaModelsResponse: Codable {
    let models: [OllamaModel]
}

struct OllamaModel: Codable {
    let name: String
    let size: Int64
    let digest: String
    let modified_at: String
}

struct OllamaPullRequest: Codable {
    let name: String
}

// MARK: - Error Types

enum OllamaError: Error {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case modelNotFound
    case networkError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid Ollama server URL", comment: "")
        case .invalidResponse:
            return NSLocalizedString("Invalid response from Ollama server", comment: "")
        case .serverError(let code):
            return String(format: NSLocalizedString("Ollama server error: %@", comment: ""), String(code))
        case .modelNotFound:
            return NSLocalizedString("Model not found on Ollama server", comment: "")
        case .networkError(let error):
            return String(format: NSLocalizedString("Network error: %@", comment: ""), error.localizedDescription)
        }
    }
}
