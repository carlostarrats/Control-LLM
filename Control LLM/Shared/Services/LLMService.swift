import Foundation
import SwiftUI

final class LLMService: @unchecked Sendable {
    static let shared = LLMService()
    private var modelPath: String?
    private var currentModelFilename: String?
    private var llamaModel: UnsafeMutableRawPointer?
    private var llamaContext: UnsafeMutableRawPointer?
    private var isModelLoaded = false
    private var conversationCount = 0
    private let maxConversationsBeforeReset = 3  // Reduced from 5 to 3 for 3B model
    private var isModelOperationInProgress = false  // For model loading/unloading
    private var isChatOperationInProgress = false   // For chat generation
    private var lastOperationTime: Date = Date()  // Track when operations start
    
    /// Load the currently selected model from ModelManager
    func loadSelectedModel() async throws {
        // Safety mechanism: if the flag has been stuck for more than 5 minutes, reset it
        if isModelOperationInProgress {
            let timeSinceLastOperation = Date().timeIntervalSince(lastOperationTime)
            if timeSinceLastOperation > 300 { // 5 minutes
                print("⚠️ WARNING: isModelOperationInProgress flag stuck for \(Int(timeSinceLastOperation)) seconds, resetting")
                isModelOperationInProgress = false
            }
        }
        
        // Prevent concurrent model operations
        guard !isModelOperationInProgress else {
            throw NSError(domain: "LLMService", code: 11, userInfo: [NSLocalizedDescriptionKey: "Another model operation is in progress"])
        }
        
        isModelOperationInProgress = true
        lastOperationTime = Date()
        defer { 
            isModelOperationInProgress = false 
        }
        
        guard let modelFilename = await ModelManager.shared.getSelectedModelFilename() else {
            throw NSError(domain: "LLMService",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "No model selected"])
        }
        
        // Don't reload if it's the same model
        if currentModelFilename == modelFilename && isModelLoaded {
            return
        }
        
        // Try to find the model file in the app sandbox first (Documents/Models)
        var url: URL?
        var docsModelsDir: URL?
        let fm = FileManager.default
        if let docsDir = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            let modelsDir = docsDir.appendingPathComponent("Models", isDirectory: true)
            docsModelsDir = modelsDir
            let expected = modelsDir.appendingPathComponent("\(modelFilename).gguf")
            if fm.fileExists(atPath: expected.path) {
                url = expected
            } else if let contents = try? fm.contentsOfDirectory(at: modelsDir, includingPropertiesForKeys: nil) {
                // Case-insensitive match on base name, tolerate dashed/underscored variants
                let target = modelFilename.replacingOccurrences(of: "_", with: "-").lowercased()
                if let match = contents.first(where: { file in
                    guard file.pathExtension.lowercased() == "gguf" else { return false }
                    let base = file.deletingPathExtension().lastPathComponent
                        .replacingOccurrences(of: "_", with: "-").lowercased()
                    return base == target
                }) {
                    url = match
                    self.currentModelFilename = match.deletingPathExtension().lastPathComponent
                } else if let only = contents.first(where: { $0.pathExtension.lowercased() == "gguf" }) {
                    // If a single gguf exists, use it
                    url = only
                    self.currentModelFilename = only.deletingPathExtension().lastPathComponent
                }
            }
        }
        
        // Then try to find the model file anywhere in the bundle resources (only if not already found)
        if url == nil {
            if let allModelUrls = Bundle.main.urls(forResourcesWithExtension: "gguf", subdirectory: nil) {
                if let match = allModelUrls.first(where: { $0.lastPathComponent == "\(modelFilename).gguf" }) {
                    url = match
                }
            }
        }

        // Fallback 1: look directly at the bundle root path
        if url == nil {
            let rootUrl = Bundle.main.bundleURL.appendingPathComponent("\(modelFilename).gguf")
            if FileManager.default.fileExists(atPath: rootUrl.path) {
                url = rootUrl
            }
        }

        // Fallback 2: copy from known repo location into app sandbox (Documents/Models) and use that path
        if url == nil {
            let repoPath = "/Users/carlostarrats/Desktop/Control LLM/Control LLM/Screens/Models/\(modelFilename).gguf"
            if fm.fileExists(atPath: repoPath) {
                // Ensure app Documents/Models exists
                if let docsDir = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let modelsDir = docsDir.appendingPathComponent("Models", isDirectory: true)
                    if !fm.fileExists(atPath: modelsDir.path) {
                        try? fm.createDirectory(at: modelsDir, withIntermediateDirectories: true)
                    }
                    let destUrl = modelsDir.appendingPathComponent("\(modelFilename).gguf")
                    if !fm.fileExists(atPath: destUrl.path) {
                        _ = try? fm.removeItem(at: destUrl)
                        do { try fm.copyItem(at: URL(fileURLWithPath: repoPath), to: destUrl) } catch {}
                    }
                    if fm.fileExists(atPath: destUrl.path) { url = destUrl }
                }
            }
        }
        
        guard let modelUrl = url else {
            let docsList: String = {
                guard let dir = docsModelsDir, let items = try? fm.contentsOfDirectory(atPath: dir.path) else { return "<empty>" }
                let ggufs = items.filter { $0.lowercased().hasSuffix(".gguf") }
                return ggufs.isEmpty ? "<empty>" : ggufs.joined(separator: ", ")
            }()
            let msg = "Model \(modelFilename).gguf not found. Looked in Documents/Models (\(docsModelsDir?.path ?? "?")) with files: [\(docsList)], and in app bundle."
            throw NSError(domain: "LLMService", code: 1, userInfo: [NSLocalizedDescriptionKey: msg])
        }

        // Clear previous model to free memory
        unloadModel()
        
        self.modelPath = modelUrl.path
        self.currentModelFilename = modelFilename
        
        // Load the model using llama.cpp with a timeout to avoid UI stalls
        do {
            try await withTimeout(seconds: 30) { [self] in
                try await self.loadModelWithLlamaCpp()
            }
        } catch {
            let reason = (error as NSError).localizedDescription
            print("LLMService: loadModelWithLlamaCpp failed: \(reason)")
            throw error
        }
        
        print("LLMService: Successfully loaded model \(modelFilename)")
    }
    
    private func unloadModel() {
        print("LLMService: Unloading model and cleaning up resources")
        
        if let context = llamaContext {
            // Free llama.cpp context
            llm_bridge_free_context(context)
            llamaContext = nil
            print("LLMService: Context freed")
        }
        
        if let model = llamaModel {
            // Free llama.cpp model
            llm_bridge_free_model(model)
            llamaModel = nil
            print("LLMService: Model freed")
        }
        
        isModelLoaded = false
        modelPath = nil
        currentModelFilename = nil
        print("LLMService: Model unload completed")
    }
    
    private func loadModelWithLlamaCpp() async throws {
        guard let modelPath = modelPath else {
            throw NSError(domain: "LLMService", code: 3, userInfo: [NSLocalizedDescriptionKey: "No model path"])
        }
        
        print("LLMService: Loading model from path: \(modelPath)")
        
        // Run heavy C calls off the main thread
        try await Task.detached(priority: .userInitiated) {
            self.llamaModel = nil
            modelPath.withCString { cString in
                self.llamaModel = llm_bridge_load_model(cString)
            }
            
            guard let model = self.llamaModel else {
                print("LLMService: llm_bridge_load_model returned NULL")
                throw NSError(domain: "LLMService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to load model - bridge returned NULL"])
            }
            
            print("LLMService: Model loaded successfully, creating context...")
            self.llamaContext = llm_bridge_create_context(model)
            
            guard self.llamaContext != nil else {
                print("LLMService: llm_bridge_create_context returned NULL")
                // Clean up the model if context creation fails
                llm_bridge_free_model(model)
                self.llamaModel = nil
                throw NSError(domain: "LLMService", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to create context - bridge returned NULL"])
            }
            
            print("LLMService: Context created successfully")
        }.value
        
        self.isModelLoaded = true
        print("LLMService: Model loaded successfully with llama.cpp")
    }
    
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw NSError(domain: "LLMService", code: 7, userInfo: [NSLocalizedDescriptionKey: "Model loading timed out"])
            }
            
            guard let result = try await group.next() else {
                group.cancelAll()
                throw NSError(domain: "LLMService", code: 8, userInfo: [NSLocalizedDescriptionKey: "No result from timeout operation"])
            }
            
            group.cancelAll()
            return result
        }
    }

    /// Stream tokens for a user prompt, optionally with chat history
    func chat(user text: String, history: [ChatMessage]? = nil, onToken: @escaping (String) async -> Void) async throws {
        // Safety check - ensure we're not in the middle of unloading
        guard !text.isEmpty else {
            throw NSError(domain: "LLMService", code: 10, userInfo: [NSLocalizedDescriptionKey: "Empty input text"])
        }
        
        // Safety mechanism: if the flag has been stuck for more than 5 minutes, reset it
        if isChatOperationInProgress {
            let timeSinceLastOperation = Date().timeIntervalSince(lastOperationTime)
            if timeSinceLastOperation > 300 { // 5 minutes
                print("⚠️ WARNING: isChatOperationInProgress flag stuck for \(Int(timeSinceLastOperation)) seconds, resetting")
                isChatOperationInProgress = false
            }
        }
        
        // Prevent concurrent chat operations
        guard !isChatOperationInProgress else {
            throw NSError(domain: "LLMService", code: 11, userInfo: [NSLocalizedDescriptionKey: "Another chat operation is in progress"])
        }
        
        isChatOperationInProgress = true
        lastOperationTime = Date()
        
        // Ensure the flag is always reset, even if errors occur
        defer { 
            isChatOperationInProgress = false 
        }
        
        // Increment conversation counter
        conversationCount += 1
        
        // Validate input text
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NSError(domain: "LLMService",
                          code: 5,
                          userInfo: [NSLocalizedDescriptionKey: "Empty or whitespace-only input"])
        }
        
        // Check input length to prevent memory issues
        let maxInputLength = 2000 // Conservative limit for 3B models
        var processedText = text
        if processedText.count > maxInputLength {
            print("⚠️ WARNING: Input text too long (\(processedText.count) chars), truncating to \(maxInputLength)")
            let truncatedText = String(processedText.prefix(maxInputLength))
            print("🔍 DEBUG: Truncated text: '\(truncatedText)'")
            processedText = truncatedText
        }
        
        // Reset context if we've had too many conversations
        if conversationCount >= maxConversationsBeforeReset {
            print("🔄 DEBUG: Resetting LLM context after \(conversationCount) conversations")
            clearState()
            try await loadSelectedModel()
            conversationCount = 0
        } else {
            // Only load model if we haven't already loaded it
            if !isModelLoaded {
                try await loadSelectedModel()
            }
        }
        
        guard isModelLoaded, let context = llamaContext else {
            throw NSError(domain: "LLMService",
                          code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Model not loaded"])
        }
        
        do {
            // Build the prompt using the new helper
            let prompt = buildPrompt(userText: processedText, history: history)
            
            // Safety check for extremely long prompts
            let maxPromptLength = 3000
            if prompt.count > maxPromptLength {
                throw NSError(domain: "LLMService", 
                             code: 6, 
                             userInfo: [NSLocalizedDescriptionKey: "Prompt too long (\(prompt.count) characters). Please shorten your message."])
            }
            
            // Use llama.cpp to generate response
            let response = try await Task.detached(priority: .userInitiated) {
                try await self.generateResponseWithLlamaCpp(context: context, prompt: prompt, onToken: onToken)
            }.value
            
        } catch {
            throw error
        }
    }
    
    private func generateResponseWithLlamaCpp(context: UnsafeMutableRawPointer, prompt: String, onToken: @escaping (String) async -> Void) async throws -> String {
        
        // Convert prompt to C string
        let promptCString = prompt.cString(using: .utf8)!
        
        // Use async/await with proper completion handling and timeout
        return try await withCheckedThrowingContinuation { continuation in
            // Run blocking llama.cpp call off the main thread to avoid UI freeze.
            // Avoid capturing a non-Sendable raw pointer by passing its bitPattern instead.
            let ctxBits = UInt(bitPattern: context)
            
            // Track completion state to prevent race conditions
            var hasCompleted = false
            
            // Add timeout to prevent getting stuck
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: 30_000_000_000) // 30 second timeout
                
                if !hasCompleted {
                    hasCompleted = true
                    continuation.resume(throwing: NSError(domain: "LLMService", code: 4, userInfo: [NSLocalizedDescriptionKey: "LLM generation timed out"]))
                }
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [ctxBits] in
                 guard let ctxPtr = UnsafeMutableRawPointer(bitPattern: ctxBits) else {
                      if !hasCompleted {
                          hasCompleted = true
                          timeoutTask.cancel()
                          continuation.resume(throwing: NSError(domain: "LLMService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid context pointer - conversion failed"]))
                      }
                     return
                  }

                 if !self.isModelLoaded {
                      if !hasCompleted {
                          hasCompleted = true
                          timeoutTask.cancel()
                          continuation.resume(throwing: NSError(domain: "LLMService", code: 9, userInfo: [NSLocalizedDescriptionKey: "Model was unloaded during generation"]))
                      }
                     return
                 }
                 
                 // Use reliable non-streaming generation (streaming has issues)
                 let outputBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: 4096)
                 defer { outputBuffer.deallocate() }
                 
                 let result = llm_bridge_generate_text(ctxPtr, promptCString, outputBuffer, 4096)
                 if result > 0 {
                     let response = String(cString: outputBuffer)
                     
                     // Send response as token
                     Task { @MainActor in
                         await onToken(response)
                     }
                     
                     if !hasCompleted {
                         hasCompleted = true
                         timeoutTask.cancel()
                         continuation.resume(returning: response)
                     }
                 } else {
                     if !hasCompleted {
                         hasCompleted = true
                         timeoutTask.cancel()
                         continuation.resume(throwing: NSError(domain: "LLMService", code: 3, userInfo: [NSLocalizedDescriptionKey: "LLM generation failed"]))
                      }
                 }
                 
              }
        }
    }
    
    private func buildPrompt(userText: String, history: [ChatMessage]?) -> String {
        let systemPrompt = LanguageService.shared.getSystemPrompt()
        var fullPrompt = "<|begin_of_text|><|start_header_id|>system<|end_header_id|>\n\n\(systemPrompt)<|eot_id|>"

        if let history = history {
            for message in history {
                if message.isUser {
                    fullPrompt += "<|start_header_id|>user<|end_header_id|>\n\n\(message.content)<|eot_id|>"
                } else {
                    fullPrompt += "<|start_header_id|>assistant<|end_header_id|>\n\n\(message.content)<|eot_id|>"
                }
            }
        }

        fullPrompt += "<|start_header_id|>user<|end_header_id|>\n\n\(userText)<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n"
        return fullPrompt
    }
    
    /// Clear any potential state to ensure fresh calls
    func clearState() {

        conversationCount = 0
        unloadModel()
    }

    private func getErrorMessage(for error: Error) -> String {
        if let nsError = error as NSError? {
            switch nsError.code {
            case 7:
                return "Model loading timed out. Please try a smaller model like TinyLlama."
            case 6:
                return "Input too long. Please use shorter text."
            case 9:
                return "Model was unloaded. Please try again."
            case 10:
                return "Empty input text. Please provide some text to process."
            case 11:
                return "Another operation is in progress. Please wait and try again."
            default:
                return error.localizedDescription
            }
        }
        return error.localizedDescription
    }
}




