import Foundation

struct LLMModelInfo {
    let id: String
    let name: String
    let filename: String
    let displayName: String
    let description: String
    let size: String
    let provider: String
    let isAvailable: Bool
    
    init(filename: String) {
        self.filename = filename
        self.id = filename
        
        // Parse display information from filename
        if filename.contains("llama-3.2-1b") {
            self.name = "Llama 3.2 1B"
            self.displayName = "Llama-3.2-1B-Instruct-Q5_K_M"
            self.description = "Meta's efficient 1B parameter model"
            self.provider = "Meta"
            self.size = "0.6 GB"
        } else if filename.contains("llama-3.2-3b") {
            self.name = "Llama 3.2 3B"
            self.displayName = "llama-3.2-3b-instruct-q4_0"
            self.description = "Meta's efficient 3B parameter model"
            self.provider = "Meta"
            self.size = "1.8 GB"
        } else {
            // Fallback for unknown models
            self.name = filename.replacingOccurrences(of: "-", with: " ").capitalized
            self.displayName = self.name
            self.description = "Custom model"
            self.provider = "Unknown"
            self.size = "Unknown"
        }
        
        // Check if model file exists anywhere in bundle resources or at bundle root
        var found = false
        if let allModelUrls = Bundle.main.urls(forResourcesWithExtension: "gguf", subdirectory: nil) {
            found = allModelUrls.contains { $0.lastPathComponent == "\(filename).gguf" }
        }
        if !found {
            let rootUrl = Bundle.main.bundleURL.appendingPathComponent("\(filename).gguf")
            found = FileManager.default.fileExists(atPath: rootUrl.path)
        }
        self.isAvailable = found
    }
}

@MainActor
class ModelManager: ObservableObject {
    static let shared = ModelManager()
    
    @Published var availableModels: [LLMModelInfo] = []
    @Published var selectedModel: LLMModelInfo?
    
    private let userDefaults = UserDefaults.standard
    private let selectedModelKey = "selectedLLMModel"
    
    private init() {
        loadAvailableModels()
        loadSelectedModel()
    }
    
    private func loadAvailableModels() {
        // List of model filenames that should be in the bundle
        // Llama 3.2 1B for speed and reliability
        let modelFilenames = [
            "Llama-3.2-1B-Instruct-Q5_K_M"     // Fast 1B parameter model
        ]
        
        availableModels = modelFilenames.map { LLMModelInfo(filename: $0) }
            .filter { $0.isAvailable }
        
        print("ModelManager: Loaded \(availableModels.count) available models")
        for model in availableModels {
            print("- \(model.displayName) (\(model.filename))")
        }
    }
    
    private func loadSelectedModel() {
        if let savedModelFilename = userDefaults.string(forKey: selectedModelKey),
           let model = availableModels.first(where: { $0.filename == savedModelFilename }) {
            selectedModel = model
        } else if let firstModel = availableModels.first {
            // Default to first available model
            selectedModel = firstModel
            saveSelectedModel()
        }
    }
    
    func selectModel(_ model: LLMModelInfo) {
        selectedModel = model
        saveSelectedModel()
        print("ModelManager: Selected model \(model.displayName)")

        // Preload only for small models to avoid memory spikes (TinyLlama, Llama 3.2 3B)
        if shouldPreload(filename: model.filename) {
            Task.detached(priority: .utility) {
                do {
                    try await LLMService.shared.loadSelectedModel()
                    print("ModelManager: Preloaded model \(model.filename)")
                } catch {
                    print("ModelManager: Preload failed for \(model.filename): \(error.localizedDescription)")
                }
            }
        }
    }

    private func shouldPreload(filename: String) -> Bool {
        if filename.contains("llama-3.2-1b") { return true }
        if filename.contains("llama-3.2-3b") { return true }
        // Preload Llama 3.2 models
        return false
    }
    
    private func saveSelectedModel() {
        if let model = selectedModel {
            userDefaults.set(model.filename, forKey: selectedModelKey)
        }
    }
    
    func getSelectedModelFilename() -> String? {
        return selectedModel?.filename
    }
}
