import Foundation
import SwiftUI

// Notification name for when the selected model changes
extension Notification.Name {
    static let modelDidChange = Notification.Name("modelDidChange")
}

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
        
        // Safety check: Reject any Llama models immediately
        if filename.lowercased().contains("llama") {
            self.name = "Excluded Model"
            self.displayName = "Excluded Model"
            self.description = "This model has been excluded"
            self.provider = "Excluded"
            self.size = "Unknown"
            self.isAvailable = false
            return
        }
        
        // Parse display information from filename (case-insensitive)
        let lowercaseFilename = filename.lowercased()
        if lowercaseFilename.contains("gemma-2-2b-it-q4_k_m") || lowercaseFilename.contains("gemma-2-2b-it") {
            self.name = "Gemma 2 2B IT"
            self.displayName = "Gemma-2-2B-It-Q4_K_M"
            self.description = "Google's 2B instruction-tuned model (Q4_K_M)"
            self.provider = "Google"
            self.size = "1.7 GB"
        } else if lowercaseFilename.contains("phi-3.5-mini-instruct-q4_k_m") || lowercaseFilename.contains("phi-3.5-mini-instruct") {
            self.name = "Phi-3.5 Mini Instruct"
            self.displayName = "Phi-3.5-Mini-Instruct-Q4_K_M"
            self.description = "Microsoft Phi-3.5 Mini Instruct (Q4_K_M)"
            self.provider = "Microsoft"
            self.size = "2.4 GB"
        } else if lowercaseFilename.contains("qwen2.5-1.5b-instruct-q5_k_m") || lowercaseFilename.contains("qwen2.5-1.5b-instruct") {
            self.name = "Qwen2.5 1.5B Instruct"
            self.displayName = "Qwen2.5-1.5B-Instruct-Q5_K_M"
            self.description = "Alibaba Qwen2.5 1.5B Instruct (Q5_K_M)"
            self.provider = "Alibaba"
            self.size = "1.3 GB"
        } else {
            // Fallback for unknown models
            self.name = filename.replacingOccurrences(of: "-", with: " ").capitalized
            self.displayName = self.name
            self.description = "Custom model"
            self.provider = "Unknown"
            self.size = "Unknown"
        }
        
        // Check if model file exists in bundle root or app Documents/Models
        var found = false
        if let allModelUrls = Bundle.main.urls(forResourcesWithExtension: "gguf", subdirectory: nil) {
            found = allModelUrls.contains { $0.lastPathComponent == "\(filename).gguf" }
        }
        if !found {
            if let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let modelsDir = docsDir.appendingPathComponent("Models", isDirectory: true)
                let docUrl = modelsDir.appendingPathComponent("\(filename).gguf")
                found = FileManager.default.fileExists(atPath: docUrl.path)
            }
        }
        self.isAvailable = found
    }
}

final class ModelManager: ObservableObject {
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
        print("ModelManager: Loading available models from bundle...")
        var discovered = Set<String>()
        
        // Look for .gguf files in the bundle root (models are copied there during build)
        if let bundleUrls = Bundle.main.urls(forResourcesWithExtension: "gguf", subdirectory: nil) {
            for url in bundleUrls {
                let filename = url.deletingPathExtension().lastPathComponent
                // Explicitly exclude any Llama models
                if !filename.lowercased().contains("llama") {
                    discovered.insert(filename)
                    print("ModelManager: Found model: \(filename)")
                }
            }
        } else {
            print("ModelManager: No .gguf files found in bundle root")
        }
        
        // Build model infos for discovered filenames and sort
        let infos = discovered.map { LLMModelInfo(filename: $0) }
            .filter { $0.isAvailable }
            .sorted { $0.displayName.lowercased() < $1.displayName.lowercased() }
        
        availableModels = infos
        
        print("ModelManager: Loaded \(availableModels.count) available models")
        print("ModelManager: Available models: \(availableModels.map { $0.filename })")
    }
    
    private func loadSelectedModel() {
        if let savedModelFilename = userDefaults.string(forKey: selectedModelKey),
           let model = availableModels.first(where: { $0.filename == savedModelFilename }) {
            selectedModel = model
        } else {
            // Default to Gemma if available, otherwise first available model
            if let gemmaModel = availableModels.first(where: { $0.filename.lowercased().contains("gemma-2-2b-it") }) {
                selectedModel = gemmaModel
                print("ModelManager: Defaulting to Gemma model: \(gemmaModel.filename)")
            } else if let firstModel = availableModels.first {
                selectedModel = firstModel
                print("ModelManager: Defaulting to first available model: \(firstModel.filename)")
            }
            saveSelectedModel()
        }
    }
    
    func selectModel(_ model: LLMModelInfo) {
        print("🔍 ModelManager: selectModel called for: \(model.displayName)")
        print("   Previous model: \(selectedModel?.displayName ?? "none")")
        
        selectedModel = model
        saveSelectedModel()
        print("✅ ModelManager: Selected model \(model.displayName)")

        // Notify that the model has changed
        print("🔍 ModelManager: Posting modelDidChange notification...")
        NotificationCenter.default.post(name: .modelDidChange, object: model)
        print("✅ ModelManager: modelDidChange notification posted")

        // REMOVED: Automatic preloading to prevent double model loading/unloading
        // ChatViewModel will handle the model loading when it receives the notification
        print("🔍 ModelManager: Skipping preload - ChatViewModel will handle model loading")
    }

    private func shouldPreload(filename: String) -> Bool {
        let f = filename.lowercased()
        if f.contains("gemma-2-2b-it") { return true }
        if f.contains("phi-3.5-mini-instruct") { return true }
        if f.contains("qwen2.5-1.5b-instruct") { return true }
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
