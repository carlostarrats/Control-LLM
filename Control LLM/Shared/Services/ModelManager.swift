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
        if lowercaseFilename.contains("deepseek-r1-distill-qwen-1.5b") {
            self.name = "DeepSeek R1 Distill"
            self.displayName = "DeepSeek-R1-Distill-Qwen-1.5B-Q5_K_M"
            self.description = "DeepSeek's distilled 1.5B parameter model"
            self.provider = "DeepSeek"
            self.size = "0.9 GB"
        } else if lowercaseFilename.contains("gemma-2-2b-it") {
            self.name = "Gemma 2 2B IT"
            self.displayName = "gemma-2-2b-it-Q5_K_M"
            self.description = "Google's efficient 2B parameter instruction-tuned model"
            self.provider = "Google"
            self.size = "1.2 GB"
        } else if lowercaseFilename.contains("qwen2.5-1.5b-instruct") {
            self.name = "Qwen 2.5 1.5B"
            self.displayName = "qwen2.5-1.5b-instruct-q5_k_m"
            self.description = "Alibaba's 1.5B parameter instruction model"
            self.provider = "Alibaba"
            self.size = "0.9 GB"
        } else {
            // Fallback for unknown models
            self.name = filename.replacingOccurrences(of: "-", with: " ").capitalized
            self.displayName = self.name
            self.description = "Custom model"
            self.provider = "Unknown"
            self.size = "Unknown"
        }
        
        // Check if model file exists in bundle resources, bundle root, or app Documents/Models
        var found = false
        if let allModelUrls = Bundle.main.urls(forResourcesWithExtension: "gguf", subdirectory: nil) {
            found = allModelUrls.contains { $0.lastPathComponent == "\(filename).gguf" }
        }
        if !found {
            let rootUrl = Bundle.main.bundleURL.appendingPathComponent("\(filename).gguf")
            found = FileManager.default.fileExists(atPath: rootUrl.path)
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
        var discovered: Set<String> = []
        let fm = FileManager.default
        
        // 1) Ensure Documents/Models exists and scan it for .gguf
        if let docsDir = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            let modelsDir = docsDir.appendingPathComponent("Models", isDirectory: true)
            if !fm.fileExists(atPath: modelsDir.path) {
                try? fm.createDirectory(at: modelsDir, withIntermediateDirectories: true)
            }
            if let urls = try? fm.contentsOfDirectory(at: modelsDir, includingPropertiesForKeys: nil) {
                for u in urls where u.pathExtension.lowercased() == "gguf" {
                    let filename = u.deletingPathExtension().lastPathComponent
                    // Explicitly exclude any Llama models
                    if !filename.lowercased().contains("llama") {
                        discovered.insert(filename)
                    }
                }
            }
        }
        
        // 2) Scan bundle resources for .gguf
        if let bundleUrls = Bundle.main.urls(forResourcesWithExtension: "gguf", subdirectory: nil) {
            for u in bundleUrls {
                let filename = u.deletingPathExtension().lastPathComponent
                // Explicitly exclude any Llama models
                if !filename.lowercased().contains("llama") {
                    discovered.insert(filename)
                }
            }
        }
        
        // 3) If still empty, opportunistically copy known models from Downloads → Documents/Models
        if discovered.isEmpty {
            if let downloads = try? fm.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                let candidates = [
                    "gemma-2-2b-it-Q5_K_M.gguf",
                    "DeepSeek-R1-Distill-Qwen-1.5B-Q5_K_M.gguf",
                    "qwen2.5-1.5b-instruct-q5_k_m.gguf"
                ]
                if let docsDir = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let modelsDir = docsDir.appendingPathComponent("Models", isDirectory: true)
                    for name in candidates {
                        let src = downloads.appendingPathComponent(name)
                        if fm.fileExists(atPath: src.path) {
                            let dst = modelsDir.appendingPathComponent(name)
                            if !fm.fileExists(atPath: dst.path) {
                                try? fm.copyItem(at: src, to: dst)
                            }
                            discovered.insert(dst.deletingPathExtension().lastPathComponent)
                        }
                    }
                }
            }
        }
        
        // Build model infos for discovered filenames and sort
        let infos = discovered.map { LLMModelInfo(filename: $0) }
            .filter { $0.isAvailable }
            .sorted { $0.displayName.lowercased() < $1.displayName.lowercased() }
        
        availableModels = infos
        
        print("ModelManager: Loaded \(availableModels.count) available models")
    }
    
    private func loadSelectedModel() {
        if let savedModelFilename = userDefaults.string(forKey: selectedModelKey),
           let model = availableModels.first(where: { $0.filename == savedModelFilename }) {
            selectedModel = model
        } else {
            // Default to Gemma if available, otherwise first available model
            if let gemmaModel = availableModels.first(where: { $0.filename.lowercased().contains("gemma-2-2b-it") }) {
                selectedModel = gemmaModel
            } else if let firstModel = availableModels.first {
                selectedModel = firstModel
            }
            saveSelectedModel()
        }
    }
    
    func selectModel(_ model: LLMModelInfo) {
        selectedModel = model
        saveSelectedModel()
        print("ModelManager: Selected model \(model.displayName)")

        // Notify that the model has changed
        NotificationCenter.default.post(name: .modelDidChange, object: model)

        // Preload only for small models to avoid memory spikes
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
        let f = filename.lowercased()
        if f.contains("gemma-2-2b-it") { return true }
        if f.contains("deepseek-r1-distill-qwen-1.5b") { return true }
        if f.contains("qwen2.5-1.5b-instruct") { return true }
        // Preload small models for better performance
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
