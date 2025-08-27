import Foundation
import SwiftUI



struct LLMModelInfo: Identifiable {
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
        

        
        // Detect model info from filename patterns (no hardcoded names)
        let lowercaseFilename = filename.lowercased()
        
        // Detect model type and provider with improved accuracy
        if lowercaseFilename.contains("gemma") {
            self.provider = NSLocalizedString("Google", comment: "")
            if lowercaseFilename.contains("3n") {
                self.name = NSLocalizedString("Gemma 3N E4B IT", comment: "")
                self.description = NSLocalizedString("Advanced reasoning and accuracy for complex conversations | 140+ languages", comment: "")
                self.size = "4.3 GB"
            } else if lowercaseFilename.contains("3-1b") {
                self.name = NSLocalizedString("Gemma 3 1B IT", comment: "")
                self.description = NSLocalizedString("Balanced performance for everyday conversations | 140+ languages", comment: "")
                self.size = "0.8 GB"
            } else if lowercaseFilename.contains("3-270m") {
                self.name = NSLocalizedString("Gemma 3 270M IT", comment: "")
                self.description = NSLocalizedString("Ultra-fast responses for simple tasks | 140+ languages", comment: "")
                self.size = "0.3 GB"
            } else if lowercaseFilename.contains("2") {
                self.name = NSLocalizedString("Gemma 2 Model", comment: "")
                self.description = NSLocalizedString("Google's previous generation language model", comment: "")
                self.size = NSLocalizedString("Unknown", comment: "")
            } else {
                self.name = NSLocalizedString("Gemma Model", comment: "")
                self.description = NSLocalizedString("Google's Gemma language model", comment: "")
                self.size = NSLocalizedString("Unknown", comment: "")
            }
        } else if lowercaseFilename.contains("phi") {
            self.provider = NSLocalizedString("Microsoft", comment: "")
            if lowercaseFilename.contains("3") {
                self.name = NSLocalizedString("Phi-3 Model", comment: "")
                self.description = NSLocalizedString("Advanced reasoning with strong code and math capabilities | 23 languages", comment: "")
                self.size = "2.4 GB"
            } else if lowercaseFilename.contains("2") {
                self.name = NSLocalizedString("Phi-2 Model", comment: "")
                self.description = NSLocalizedString("Balanced performance with code and math focus | 23 languages", comment: "")
                self.size = "1.3 GB"
            } else {
                self.name = NSLocalizedString("Phi Model", comment: "")
                self.description = NSLocalizedString("Microsoft's Phi language model with code capabilities | 23 languages", comment: "")
                self.size = NSLocalizedString("Unknown", comment: "")
            }
        } else if lowercaseFilename.contains("qwen") {
            self.provider = NSLocalizedString("Alibaba", comment: "")
            if lowercaseFilename.contains("2.5") {
                self.name = NSLocalizedString("Qwen2.5 Model", comment: "")
                // CRASH FIX: Handle different Qwen 2.5 variants with accurate sizes
                if lowercaseFilename.contains("0.5b") {
                    self.description = NSLocalizedString("Ultra-compact model optimized for mobile | 29+ languages", comment: "")
                    self.size = "0.5 GB"
                } else if lowercaseFilename.contains("1.5b") {
                    self.description = NSLocalizedString("General tasks with broader technical abilities | 29+ languages", comment: "")
                    self.size = "1.5 GB"
                } else {
                    self.description = NSLocalizedString("Qwen2.5 language model with technical focus | 29+ languages", comment: "")
                    self.size = NSLocalizedString("Unknown", comment: "")
                }
            } else if lowercaseFilename.contains("2") {
                self.name = NSLocalizedString("Qwen2 Model", comment: "")
                self.description = NSLocalizedString("Advanced reasoning with broad technical abilities | 30 languages", comment: "")
                self.size = "1.3 GB"
            } else {
                self.name = NSLocalizedString("Qwen Model", comment: "")
                self.description = NSLocalizedString("General purpose language model with technical focus | 30 languages", comment: "")
                self.size = NSLocalizedString("Unknown", comment: "")
            }
        } else if lowercaseFilename.contains("llama") {
            self.provider = NSLocalizedString("Meta", comment: "")
            if lowercaseFilename.contains("3") {
                self.name = NSLocalizedString("Llama 3 Model", comment: "")
                self.description = NSLocalizedString("Meta's latest large language model", comment: "")
                self.size = NSLocalizedString("Unknown", comment: "")
            } else if lowercaseFilename.contains("2") {
                self.name = NSLocalizedString("Llama 2 Model", comment: "")
                self.description = NSLocalizedString("Meta's previous generation language model", comment: "")
                self.size = NSLocalizedString("Unknown", comment: "")
            } else {
                self.name = NSLocalizedString("Llama Model", comment: "")
                self.description = NSLocalizedString("Meta's open source language model", comment: "")
                self.size = NSLocalizedString("Unknown", comment: "")
            }
        } else {
            self.name = filename.replacingOccurrences(of: "-", with: " ").capitalized
            self.description = NSLocalizedString("Custom or specialized language model", comment: "")
            self.provider = NSLocalizedString("Unknown", comment: "")
            self.size = NSLocalizedString("Unknown", comment: "")
        }
        
        // CRASH FIX: Special formatting for Qwen 2.5 models to add space between Qwen and 2.5
        var displayName = filename.replacingOccurrences(of: "-", with: " ").capitalized
        if lowercaseFilename.contains("qwen") && lowercaseFilename.contains("2.5") {
            displayName = displayName.replacingOccurrences(of: "Qwen2.5", with: "Qwen 2.5")
        }
        self.displayName = displayName
        
        // Check if model file exists in Models directory or bundle root
        var found = false
        
        // Check Models directory first
        if let modelsDir = Bundle.main.url(forResource: "Models", withExtension: nil) {
            let modelUrl = modelsDir.appendingPathComponent("\(filename).gguf")
            found = FileManager.default.fileExists(atPath: modelUrl.path)
        }
        
        // Fallback to bundle root
        if !found {
            if let allModelUrls = Bundle.main.urls(forResourcesWithExtension: "gguf", subdirectory: nil) {
                found = allModelUrls.contains { $0.lastPathComponent == "\(filename).gguf" }
            }
        }
        
        // Also check Documents/Models as final fallback
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
        print("ModelManager: Loading available models...")
        var discovered = Set<String>()
        let discoveredQueue = DispatchQueue(label: "discovered.serial")
        
        // OPTIMIZATION: Use concurrent dispatch for faster model discovery
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "model.discovery", attributes: .concurrent)
        
        // Look for .gguf files in the Models directory (fastest)
        if let modelsDir = Bundle.main.url(forResource: "Models", withExtension: nil) {
            group.enter()
            queue.async {
                do {
                    let modelFiles = try FileManager.default.contentsOfDirectory(at: modelsDir, includingPropertiesForKeys: nil)
                    for url in modelFiles {
                        if url.pathExtension == "gguf" {
                            let filename = url.deletingPathExtension().lastPathComponent
                            discoveredQueue.sync {
                                discovered.insert(filename)
                            }
                            print("ModelManager: Found model: \(filename)")
                        }
                    }
                } catch {
                    print("ModelManager: Error reading Models directory: \(error)")
                }
                group.leave()
            }
        } else {
            print("ModelManager: Models directory not found in bundle")
        }
        
        // Also check bundle root as fallback
        group.enter()
        queue.async {
            if let bundleUrls = Bundle.main.urls(forResourcesWithExtension: "gguf", subdirectory: nil) {
                for url in bundleUrls {
                    let filename = url.deletingPathExtension().lastPathComponent
                    discoveredQueue.sync {
                        discovered.insert(filename)
                    }
                    print("ModelManager: Found model in bundle root: \(filename)")
                }
            }
            group.leave()
        }
        
        // Wait for discovery to complete
        group.wait()
        
        // OPTIMIZATION: Build model infos with better sorting
        let infos = discovered.map { LLMModelInfo(filename: $0) }
            .filter { $0.isAvailable }
            .sorted { model1, model2 in
                // Sort by provider first, then by name
                if model1.provider != model2.provider {
                    return model1.provider < model2.provider
                }
                return model1.displayName.lowercased() < model2.displayName.lowercased()
            }
        
        availableModels = infos
        
        print("ModelManager: Loaded \(availableModels.count) available models")
        print("ModelManager: Available models: \(availableModels.map { $0.filename })")
    }
    
    private func loadSelectedModel() {
        if let savedModelFilename = userDefaults.string(forKey: selectedModelKey),
           let model = availableModels.first(where: { $0.filename == savedModelFilename }) {
            selectedModel = model
        } else {
                    // Default to first available model
        if let firstModel = availableModels.first {
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
        // No hardcoded preloading - return false for all models
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
