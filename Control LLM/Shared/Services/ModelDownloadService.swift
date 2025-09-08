//
//  ModelDownloadService.swift
//  Control LLM
//
//  Service for downloading models from Hugging Face
//

import Foundation
import Combine

@MainActor
class ModelDownloadService: ObservableObject {
    static let shared = ModelDownloadService()
    
    @Published var downloadProgress: [String: Double] = [:]
    @Published var downloadingModels: Set<String> = []
    @Published var queuedModels: [String] = []
    @Published var downloadErrors: [String: String] = [:]
    
    private var downloadTasks: [String: URLSessionDataTask] = [:]
    private var cancellables = Set<AnyCancellable>()
    private var isProcessingQueue = false
    
    // MARK: - Model Configuration
    private let modelConfigurations: [String: ModelDownloadConfig] = [
        "gemma-3-1b-it-Q4_K_M": ModelDownloadConfig(
            filename: "gemma-3-1b-it-Q4_K_M.gguf",
            repository: "unsloth/gemma-3-1b-it-GGUF",
            downloadURL: "https://huggingface.co/unsloth/gemma-3-1b-it-GGUF/resolve/main/gemma-3-1b-it-Q4_K_M.gguf",
            size: "0.8 GB"
        ),
        "Llama-3.2-1B-Instruct-Q4_K_M": ModelDownloadConfig(
            filename: "Llama-3.2-1B-Instruct-Q4_K_M.gguf",
            repository: "unsloth/Llama-3.2-1B-Instruct-GGUF",
            downloadURL: "https://huggingface.co/unsloth/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf",
            size: "0.8 GB"
        ),
        "Qwen3-1.7B-Q4_K_M": ModelDownloadConfig(
            filename: "Qwen3-1.7B-Q4_K_M.gguf",
            repository: "unsloth/Qwen3-1.7B-GGUF",
            downloadURL: "https://huggingface.co/unsloth/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q4_K_M.gguf",
            size: "1.0 GB"
        ),
        "smollm2-1.7b-instruct-q4_k_m": ModelDownloadConfig(
            filename: "smollm2-1.7b-instruct-q4_k_m.gguf",
            repository: "HuggingFaceTB/SmolLM2-1.7B-Instruct-GGUF",
            downloadURL: "https://huggingface.co/HuggingFaceTB/SmolLM2-1.7B-Instruct-GGUF/resolve/main/smollm2-1.7b-instruct-q4_k_m.gguf",
            size: "1.0 GB"
        )
    ]
    
    private init() {}
    
    // MARK: - Public Methods
    
    func getAvailableDownloadModels() -> [LLMModelInfo] {
        return modelConfigurations.compactMap { (key, config) in
            // Only return models that aren't already installed
            let modelInfo = LLMModelInfo(filename: key)
            return modelInfo.isAvailable ? nil : modelInfo
        }.sorted { model1, model2 in
            // Custom alphabetical order: Gemma, Llama, Smol, Qwen
            let name1 = model1.name.lowercased()
            let name2 = model2.name.lowercased()
            
            // Define order priorities
            func getOrderPriority(_ name: String) -> Int {
                if name.contains("gemma") { return 1 }
                if name.contains("llama") { return 2 }
                if name.contains("smol") { return 3 }
                if name.contains("qwen") { return 4 }
                return 5 // Unknown models go last
            }
            
            let priority1 = getOrderPriority(name1)
            let priority2 = getOrderPriority(name2)
            
            return priority1 < priority2
        }
    }
    
    func downloadModel(_ modelFilename: String) async throws {
        guard let config = modelConfigurations[modelFilename] else {
            throw ModelDownloadError.invalidModel
        }
        
        // Check if already downloading or queued
        if downloadingModels.contains(modelFilename) || queuedModels.contains(modelFilename) {
            return
        }
        
        // Check if already installed
        let modelInfo = LLMModelInfo(filename: modelFilename)
        if modelInfo.isAvailable {
            throw ModelDownloadError.alreadyInstalled
        }
        
        // If something is already downloading, add to queue
        if !downloadingModels.isEmpty {
            queuedModels.append(modelFilename)
            downloadErrors.removeValue(forKey: modelFilename)
            return
        }
        
        // Start download immediately
        await startDownload(config: config, modelFilename: modelFilename)
    }
    
    private func startDownload(config: ModelDownloadConfig, modelFilename: String) async {
        downloadingModels.insert(modelFilename)
        downloadProgress[modelFilename] = 0.0
        downloadErrors.removeValue(forKey: modelFilename)
        
        do {
            try await performDownload(config: config, modelFilename: modelFilename)
            
            // Download completed successfully
            downloadingModels.remove(modelFilename)
            downloadProgress.removeValue(forKey: modelFilename)
            
            // Refresh ModelManager to detect the new model
            await ModelManager.shared.refreshAvailableModels()
            
            // Process next in queue
            await processNextInQueue()
            
        } catch {
            // Download failed
            downloadingModels.remove(modelFilename)
            downloadProgress.removeValue(forKey: modelFilename)
            downloadErrors[modelFilename] = error.localizedDescription
            
            // Process next in queue even if this one failed
            await processNextInQueue()
        }
    }
    
    private func processNextInQueue() async {
        guard !queuedModels.isEmpty, downloadingModels.isEmpty else { return }
        
        let nextModel = queuedModels.removeFirst()
        
        guard let config = modelConfigurations[nextModel] else {
            // Skip invalid model and process next
            await processNextInQueue()
            return
        }
        
        await startDownload(config: config, modelFilename: nextModel)
    }
    
    func cancelDownload(_ modelFilename: String) {
        // If it's currently downloading
        if let task = downloadTasks[modelFilename] {
            task.cancel()
            downloadTasks.removeValue(forKey: modelFilename)
        }
        
        // Remove from downloading
        downloadingModels.remove(modelFilename)
        downloadProgress.removeValue(forKey: modelFilename)
        downloadErrors.removeValue(forKey: modelFilename)
        
        // Remove from queue if it's there
        if let index = queuedModels.firstIndex(of: modelFilename) {
            queuedModels.remove(at: index)
        }
        
        // If we cancelled a downloading model, process next in queue
        if downloadingModels.isEmpty {
            Task {
                await processNextInQueue()
            }
        }
    }
    
    func isDownloading(_ modelFilename: String) -> Bool {
        return downloadingModels.contains(modelFilename)
    }
    
    func isQueued(_ modelFilename: String) -> Bool {
        return queuedModels.contains(modelFilename)
    }
    
    func getDownloadProgress(_ modelFilename: String) -> Double {
        return downloadProgress[modelFilename] ?? 0.0
    }
    
    func getDownloadError(_ modelFilename: String) -> String? {
        return downloadErrors[modelFilename]
    }
    
    // MARK: - Private Methods
    
    private func performDownload(config: ModelDownloadConfig, modelFilename: String) async throws {
        guard let url = URL(string: config.downloadURL) else {
            throw ModelDownloadError.invalidURL
        }
        
        print("🚀 Starting download for \(modelFilename) from \(config.downloadURL)")
        
        // Create destination URL in Documents/Models directory
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let modelsDir = documentsDir.appendingPathComponent("Models", isDirectory: true)
        
        // Create Models directory if it doesn't exist
        try FileManager.default.createDirectory(at: modelsDir, withIntermediateDirectories: true)
        
        let destinationURL = modelsDir.appendingPathComponent(config.filename)
        
        // Remove existing file if it exists
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        // Use URLSession with proper progress tracking
        let (data, response) = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(Data, URLResponse?), Error>) in
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let data = data else {
                    continuation.resume(throwing: ModelDownloadError.downloadFailed("No data received"))
                    return
                }
                
                continuation.resume(returning: (data, response))
            }
            
            // Store task for potential cancellation
            downloadTasks[modelFilename] = task
            
            // Start download
            task.resume()
            
            // Monitor progress
            Task {
                await monitorDownloadProgress(task: task, modelFilename: modelFilename)
            }
        }
        
        // Check response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ModelDownloadError.downloadFailed("Download failed with invalid response")
        }
        
        // Save data to file
        try data.write(to: destinationURL)
        print("✅ ModelDownloadService: Successfully downloaded \(modelFilename) to \(destinationURL.path)")
    }
    
    private func monitorDownloadProgress(task: URLSessionDataTask, modelFilename: String) async {
        while !task.progress.isFinished && !task.progress.isCancelled {
            await MainActor.run {
                downloadProgress[modelFilename] = task.progress.fractionCompleted
                print("📥 Download progress for \(modelFilename): \(Int(task.progress.fractionCompleted * 100))%")
            }
            
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        // Clean up task reference
        downloadTasks.removeValue(forKey: modelFilename)
    }
    
}

// MARK: - Supporting Types

struct ModelDownloadConfig {
    let filename: String
    let repository: String
    let downloadURL: String
    let size: String
}

enum ModelDownloadError: LocalizedError {
    case invalidModel
    case alreadyInstalled
    case invalidURL
    case downloadFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidModel:
            return "Invalid model specified"
        case .alreadyInstalled:
            return "Model is already installed"
        case .invalidURL:
            return "Invalid download URL"
        case .downloadFailed(let message):
            return "Download failed: \(message)"
        }
    }
}
