import Foundation

final class LLMService {
    static let shared = LLMService()
    private var modelPath: String?
    private var currentModelFilename: String?
    private var llamaModel: UnsafeMutableRawPointer?
    private var llamaContext: UnsafeMutableRawPointer?
    private var isModelLoaded = false

    /// Load the currently selected model from ModelManager
    func loadSelectedModel() async throws {
        print("🚨 LLMService: loadSelectedModel started")
        NSLog("🚨 LLMService: loadSelectedModel started")
        fflush(stdout)
        
        guard let modelFilename = await ModelManager.shared.getSelectedModelFilename() else {
            print("🚨 LLMService: ERROR - No model selected")
            NSLog("🚨 LLMService: ERROR - No model selected")
            fflush(stdout)
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
        if let context = llamaContext {
            // Free llama.cpp context
            llm_bridge_free_context(context)
            llamaContext = nil
        }
        if let model = llamaModel {
            // Free llama.cpp model
            llm_bridge_free_model(model)
            llamaModel = nil
        }
        isModelLoaded = false
        modelPath = nil
        currentModelFilename = nil
    }
    
    private func loadModelWithLlamaCpp() async throws {
        guard let modelPath = modelPath else {
            throw NSError(domain: "LLMService", code: 3, userInfo: [NSLocalizedDescriptionKey: "No model path"])
        }
        
        // Run heavy C calls off the main thread
        try await Task.detached(priority: .userInitiated) {
            self.llamaModel = nil
            modelPath.withCString { cString in
                self.llamaModel = llm_bridge_load_model(cString)
            }
            guard let model = self.llamaModel else {
                throw NSError(domain: "LLMService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to load model"])
            }
            self.llamaContext = llm_bridge_create_context(model)
            guard self.llamaContext != nil else {
                throw NSError(domain: "LLMService", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to create context"])
            }
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

    /// Stream tokens for a user prompt
    func chat(user text: String,
              onToken: @escaping (String) async -> Void) async throws {

        print("🚨 LLMService: chat started with text: '\(text)'")
        NSLog("🚨 LLMService: chat started with text: '\(text)'")
        fflush(stdout)
        
        print("🚨 LLMService: About to load model")
        NSLog("🚨 LLMService: About to load model")
        fflush(stdout)
        
        try await loadSelectedModel()
        
        print("🚨 LLMService: Model loaded, isModelLoaded = \(isModelLoaded)")
        NSLog("🚨 LLMService: Model loaded, isModelLoaded = \(isModelLoaded)")
        fflush(stdout)
        
        guard isModelLoaded, let context = llamaContext else {
            print("🚨 LLMService: ERROR - Model not loaded")
            NSLog("🚨 LLMService: ERROR - Model not loaded")
            fflush(stdout)
            throw NSError(domain: "LLMService",
                          code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Model not loaded"])
        }

        print("🚨 LLMService: About to start prediction")
        NSLog("🚨 LLMService: About to start prediction")
        fflush(stdout)
        
        do {
            // Add timeout protection for the prediction
            try await withTimeout(seconds: 30) { [self] in

                // Force console output with multiple approaches
                print("🔍 DEBUG: User message: '\(text)'")
                NSLog("🔍 DEBUG: User message: '\(text)'")
                fflush(stdout)
                
                print("🔍 DEBUG: System prompt: '\(LanguageService.shared.getSystemPrompt())'")
                NSLog("🔍 DEBUG: System prompt: '\(LanguageService.shared.getSystemPrompt())'")
                fflush(stdout)
                
                print("🔍 DEBUG: Model filename: \(currentModelFilename ?? "unknown")")
                NSLog("🔍 DEBUG: Model filename: \(currentModelFilename ?? "unknown")")
                fflush(stdout)
                
                // Build the prompt in the correct Llama 3.2 format
                let systemPrompt = LanguageService.shared.getSystemPrompt()
                let prompt = "<|begin_of_text|><|start_header_id|>system<|end_header_id|>\n\n\(systemPrompt)<|eot_id|><|start_header_id|>user<|end_header_id|>\n\n\(text)<|eot_id|><|start_header_id|>assistant<|end_header_id|>\n\n"
                
                print("🔍 DEBUG: Full prompt: '\(prompt)'")
                
                // Use llama.cpp to generate response
                let response = try await generateResponseWithLlamaCpp(context: context, prompt: prompt, onToken: onToken)
                
                print("🔍 DEBUG: Generated response: '\(response)'")
            }
        } catch {
            // Provide a helpful error message if the LLM fails
            await onToken("I'm having trouble responding right now. Please try again.")
            throw error
        }
    }
    
    private func generateResponseWithLlamaCpp(context: UnsafeMutableRawPointer, prompt: String, onToken: @escaping (String) async -> Void) async throws -> String {
        print("🔍 DEBUG: Using llama.cpp bridge for text generation")
        
        // Convert prompt to C string
        let promptCString = prompt.cString(using: .utf8)!
        
        // Run blocking llama.cpp call off the main thread to avoid UI freeze.
        // Avoid capturing a non-Sendable raw pointer by passing its bitPattern instead.
        let ctxBits = UInt(bitPattern: context)
        DispatchQueue.global(qos: .userInitiated).async { [ctxBits] in
            // Rolling buffer filter to strip sequences like <|python_tag|> even when split across pieces
            var buffer = ""
            guard let ctxPtr = UnsafeMutableRawPointer(bitPattern: ctxBits) else { return }
            llm_bridge_generate_stream_block(ctxPtr, promptCString, { piece in
                if let piece = piece {
                    // Copy the C string immediately on this thread to avoid use-after-free
                    let incoming = String(cString: piece)
                    buffer += incoming

                    // Drain complete tags and produce clean text
                    func drainBufferRemovingTags(_ bufferRef: inout String) -> String {
                        var output = ""
                        while true {
                            if let start = bufferRef.range(of: "<|") {
                                // emit clean text before the tag start
                                output += String(bufferRef[..<start.lowerBound])
                                if let end = bufferRef.range(of: "|>", range: start.upperBound..<bufferRef.endIndex) {
                                    // remove the whole tag and continue scanning
                                    bufferRef.removeSubrange(start.lowerBound...end.upperBound)
                                    continue
                                } else {
                                    // keep the partial tag in buffer; stop draining
                                    bufferRef.removeSubrange(bufferRef.startIndex..<start.lowerBound)
                                    break
                                }
                            } else {
                                // no tag start: emit everything and clear
                                output += bufferRef
                                bufferRef.removeAll(keepingCapacity: true)
                                break
                            }
                        }
                        return output
                    }

                    let cleaned = drainBufferRemovingTags(&buffer)
                    if cleaned.isEmpty { return }
                    Task { await onToken(cleaned) }
                }
            }, 32)
        }
        
        // For now, return empty (chat UI already received streamed tokens)
        return ""
    }
    
    /// Clear any potential state to ensure fresh calls
    func clearState() {
        unloadModel()
    }
}




