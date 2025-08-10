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
        
        // Parse display information from filename (case-insensitive)
        let lowercaseFilename = filename.lowercased()
        if lowercaseFilename.contains("llama-3.2-1b") {
            self.name = "Llama 3.2 1B"
            self.displayName = "Llama-3.2-1B-Instruct-Q5_K_M"
            self.description = "Meta's efficient 1B parameter model"
            self.provider = "Meta"
            self.size = "0.6 GB"
        } else if lowercaseFilename.contains("llama-3.2-3b") {
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
                    discovered.insert(u.deletingPathExtension().lastPathComponent)
                }
            }
        }
        
        // 2) Scan bundle resources for .gguf
        if let bundleUrls = Bundle.main.urls(forResourcesWithExtension: "gguf", subdirectory: nil) {
            for u in bundleUrls {
                discovered.insert(u.deletingPathExtension().lastPathComponent)
            }
        }
        
        // 3) If still empty, opportunistically copy known models from Downloads → Documents/Models
        if discovered.isEmpty {
            if let downloads = try? fm.url(for: .downloadsDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                let candidates = [
                    "Llama-3.2-1B-Instruct-Q5_K_M.gguf"
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
        let f = filename.lowercased()
        if f.contains("llama-3.2-1b") { return true }
        if f.contains("llama-3.2-3b") { return true }
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
