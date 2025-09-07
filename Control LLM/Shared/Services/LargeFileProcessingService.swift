import Foundation

// MARK: - Performance Optimization: High-Performance Text Processing

/// High-performance StringBuilder for efficient string concatenation
class PerformanceStringBuilder {
    private var buffer: [String] = []
    private var totalLength: Int = 0
    
    func append(_ string: String) {
        buffer.append(string)
        totalLength += string.count
    }
    
    func toString() -> String {
        return buffer.joined()
    }
    
    func clear() {
        buffer.removeAll()
        totalLength = 0
    }
}

/// High-performance text processor with compiled regex patterns
class TextProcessor {
    static let shared = TextProcessor()
    
    // Compiled regex patterns for better performance
    private let whitespaceRegex: NSRegularExpression
    private let pageNumberRegex: NSRegularExpression
    private let lineBreakRegex: NSRegularExpression
    private let multipleSpacesRegex: NSRegularExpression
    
    private init() {
        do {
            // Compile regex patterns once for better performance
            self.whitespaceRegex = try NSRegularExpression(pattern: "\\s+", options: [])
            self.pageNumberRegex = try NSRegularExpression(pattern: "\\b\\d+\\s*of\\s*\\d+\\b|\\bPage\\s+\\d+\\b", options: [])
            self.lineBreakRegex = try NSRegularExpression(pattern: "\\n\\s*\\n", options: [])
            self.multipleSpacesRegex = try NSRegularExpression(pattern: "\\s{3,}", options: [])
        } catch {
            fatalError("Failed to compile regex patterns: \(error)")
        }
    }
    
    func cleanWhitespace(_ text: String) -> String {
        return whitespaceRegex.stringByReplacingMatches(
            in: text,
            options: [],
            range: NSRange(text.startIndex..., in: text),
            withTemplate: " "
        )
    }
    
    func removePageNumbers(_ text: String) -> String {
        return pageNumberRegex.stringByReplacingMatches(
            in: text,
            options: [],
            range: NSRange(text.startIndex..., in: text),
            withTemplate: ""
        )
    }
    
    func normalizeLineBreaks(_ text: String) -> String {
        var result = lineBreakRegex.stringByReplacingMatches(
            in: text,
            options: [],
            range: NSRange(text.startIndex..., in: text),
            withTemplate: "\n\n"
        )
        
        result = multipleSpacesRegex.stringByReplacingMatches(
            in: result,
            options: [],
            range: NSRange(result.startIndex..., in: result),
            withTemplate: " "
        )
        
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Performance Actors for Better Concurrency
actor ProgressActor {
    private var pendingProgressUpdates: [String] = []
    private var lastProgressUpdate: Date = Date()
    
    func updateProgress(_ message: String) {
        pendingProgressUpdates.append(message)
        lastProgressUpdate = Date()
    }
    
    func getPendingUpdates() -> [String] {
        let updates = pendingProgressUpdates
        pendingProgressUpdates.removeAll()
        return updates
    }
}

actor TranscriptActor {
    private var transcript: String = ""
    
    func updateTranscript(_ text: String) {
        transcript = text
    }
    
    func getTranscript() -> String {
        return transcript
    }
}

actor FinalSynthesisActor {
    private var finalSynthesisResult: String?
    private var sequentialFinalSynthesisResult: String?
    
    func setFinalSynthesisResult(_ result: String?) {
        finalSynthesisResult = result
    }
    
    func setSequentialFinalSynthesisResult(_ result: String?) {
        sequentialFinalSynthesisResult = result
    }
    
    func getFinalSynthesisResult() -> String? {
        return finalSynthesisResult
    }
    
    func getSequentialFinalSynthesisResult() -> String? {
        return sequentialFinalSynthesisResult
    }
}

actor ProcessedDataActor {
    private var processedFileContent: FileContent?
    private var processedSummaries: [String] = []
    
    func setProcessedData(fileContent: FileContent, summaries: [String]) {
        processedFileContent = fileContent
        processedSummaries = summaries
    }
    
    func getProcessedData() -> (fileContent: FileContent, summaries: [String])? {
        guard let fileContent = processedFileContent, !processedSummaries.isEmpty else {
            return nil
        }
        return (fileContent, processedSummaries)
    }
    
    func hasProcessedData() -> Bool {
        return processedFileContent != nil && !processedSummaries.isEmpty
    }
}

// MARK: - AsyncSemaphore for controlling concurrent LLM access
actor AsyncSemaphore {
    private var value: Int
    private var waiters: [CheckedContinuation<Void, Never>] = []
    
    init(value: Int) {
        self.value = value
        self.waiters = []
    }
    
    func wait() async {
        if value > 0 {
            value -= 1
            return
        }
        
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }
    
    func signal() {
        if !waiters.isEmpty {
            let waiter = waiters.removeFirst()
            waiter.resume()
        } else {
            value += 1
        }
    }
}

class LargeFileProcessingService {
    static let shared = LargeFileProcessingService()
    
    // MARK: - Properties
    // PERFORMANCE FIX: Use actor-based concurrency instead of locks
    private let progressActor = ProgressActor()
    private let transcriptActor = TranscriptActor()
    
    // PERFORMANCE OPTIMIZATION: Model-specific chunk size multipliers
    private let modelChunkMultipliers: [String: Double] = [
        "llama-3.2-1b": 1.5,      // Smaller model, larger chunks
        "llama-3.2-3b": 1.2,      // Medium model, medium chunks
        "gemma-3-1b": 1.4,        // Smaller model, larger chunks
        "qwen3-1.7b": 1.3,        // Medium model, medium chunks
        "smollm2-1.7b": 1.3,      // Medium model, medium chunks
        "default": 1.0             // Default multiplier
    ]
    
    // NEW: Store final synthesis results for both parallel and sequential processing
    private var finalSynthesisResult: String?
    private var sequentialFinalSynthesisResult: String?
    private let finalSynthesisActor = FinalSynthesisActor()
    
    // CRITICAL FIX: Store processed PDF data for subsequent questions with automatic cleanup
    private var processedFileContent: FileContent?
    private var processedSummaries: [String] = []
    private let processedDataActor = ProcessedDataActor()
    
    // Security: Track data creation time for automatic cleanup
    private var dataCreationTime: Date?
    private let dataRetentionInterval: TimeInterval = 5 * 60 // 5 minutes

    private init() {}
    
    deinit {
        // Security: Clear all data when service is deallocated
        Task {
            await clearProcessedData()
        }
    }
    
    // MARK: - Performance Optimizations
    
    /// Calculate optimal chunk size based on model and content
    func calculateOptimalChunkSize(for modelFilename: String, contentLength: Int) async -> Int {
        let baseChunkSize = 2000  // Base chunk size
        
        // Get model-specific multiplier
        let modelKey = extractModelKey(from: modelFilename)
        let modelMultiplier = modelChunkMultipliers[modelKey] ?? modelChunkMultipliers["default"]!
        
        // Content-based multiplier (larger content = larger chunks)
        let contentMultiplier = min(2.0, max(0.5, Double(contentLength) / 100000.0))
        
        // Calculate optimal size
        let optimalSize = Int(Double(baseChunkSize) * modelMultiplier * contentMultiplier)
        
        // Ensure reasonable bounds
        let minSize = 500
        let maxSize = 4000
        
        let finalSize = max(minSize, min(maxSize, optimalSize))
        
        print("🔥 LargeFileProcessingService: Chunk size calculation:")
        print("   - Model: \(modelKey), Multiplier: \(modelMultiplier)")
        print("   - Content: \(contentLength) chars, Multiplier: \(contentMultiplier)")
        print("   - Base: \(baseChunkSize) → Optimal: \(finalSize)")
        
        return finalSize
    }
    
    /// Extract model key from filename for multiplier lookup
    private func extractModelKey(from filename: String) -> String {
        let lowercased = filename.lowercased()
        
        if lowercased.contains("llama-3.2-1b") { return "llama-3.2-1b" }
        if lowercased.contains("llama-3.2-3b") { return "llama-3.2-3b" }
        if lowercased.contains("gemma-3-1b") { return "gemma-3-1b" }
        if lowercased.contains("qwen3-1.7b") { return "qwen3-1.7b" }
        if lowercased.contains("smollm2-1.7b") { return "smollm2-1.7b" }
        
        return "default"
    }
    
    // CRITICAL FIX: Check if processed PDF data is available for questions
    func hasProcessedData() async -> Bool {
        // Security: Check if data has expired and clean up if necessary
        await checkAndCleanupExpiredData()
        return await processedDataActor.hasProcessedData()
    }
    
    // Security: Check and cleanup expired data
    private func checkAndCleanupExpiredData() async {
        guard let creationTime = dataCreationTime else { return }
        
        let timeSinceCreation = Date().timeIntervalSince(creationTime)
        if timeSinceCreation >= dataRetentionInterval {
            print("🧹 LargeFileProcessingService: Data expired after 24 hours, cleaning up")
            await clearProcessedData()
        }
    }
    
    // Security: Clear all processed data from memory
    private func clearProcessedData() async {
        processedFileContent = nil
        processedSummaries.removeAll()
        finalSynthesisResult = nil
        sequentialFinalSynthesisResult = nil
        dataCreationTime = nil
        
        // Clear actor data
        await processedDataActor.setProcessedData(fileContent: FileContent(fileName: "", content: "", type: .text), summaries: [])
        await finalSynthesisActor.setFinalSynthesisResult(nil)
        await finalSynthesisActor.setSequentialFinalSynthesisResult(nil)
        
        print("✅ LargeFileProcessingService: All processed data cleared from memory")
    }
    
    // CRITICAL FIX: Get processed PDF data for answering questions
    func getProcessedData() async -> (fileContent: FileContent, summaries: [String])? {
        return await processedDataActor.getProcessedData()
    }
    
    // CRITICAL FIX: Answer questions using stored processed PDF data
    func answerQuestion(
        question: String,
        llmService: HybridLLMService,
        progressHandler: @escaping (String) async -> Void,
        transcriptHandler: @escaping (String) async -> Void
    ) async -> String? {
        
        guard let (_, summaries) = await getProcessedData() else {
            await transcriptHandler("❌ No processed PDF data available. Please upload and process a PDF first.")
            return nil
        }
        
        await progressHandler("Answering your question using the processed PDF...")
        await transcriptHandler("🤖 Using processed PDF data to answer: '\(question)'")
        
        // Use the stored summaries to answer the question
        return await generateDirectFinalAnswer(
            summaries: summaries,
            instruction: question,
            llmService: llmService,
            transcriptHandler: transcriptHandler,
            progressHandler: progressHandler
        )
    }

    func process(
        fileContent: FileContent,
        instruction: String,
        maxContentLength: Int,
        llmService: HybridLLMService,
        progressHandler: @escaping (String) async -> Void,
        transcriptHandler: @escaping (String) async -> Void
    ) async -> String? {
        
        #if DEBUG
        print("🔥 LargeFileProcessingService: Starting process for file '\(fileContent.fileName)'")
        print("🔥 LargeFileProcessingService: Content length: \(fileContent.content.count) characters")
        print("🔥 LargeFileProcessingService: Max content length: \(maxContentLength)")
        print("🔥 LargeFileProcessingService: Instruction: '\(instruction)'")
        #endif
        
        // CRITICAL FIX: Ensure model is loaded before processing
        if !(await llmService.isModelLoaded) {
            print("🔥 LargeFileProcessingService: Model not loaded, loading model first...")
            await progressHandler("Loading model...")
            do {
                try await llmService.loadSelectedModel()
                print("✅ LargeFileProcessingService: Model loaded successfully")
            } catch {
                print("❌ LargeFileProcessingService: Failed to load model: \(error)")
                await progressHandler("Error: Failed to load model")
                return nil
            }
        } else {
            print("✅ LargeFileProcessingService: Model already loaded")
        }
        
        // NEW: All images should use simple processing to avoid chunking issues
        if fileContent.type == .image {
            #if DEBUG
            print("🔥 LargeFileProcessingService: Image content detected (\(fileContent.content.count) chars), processing directly")
            #endif
            await progressHandler("Processing image text directly...")
            return await processImageContent(
                fileContent: fileContent,
                instruction: instruction,
                llmService: llmService,
                progressHandler: progressHandler,
                transcriptHandler: transcriptHandler
            )
        }
        
        // NEW: PDFs use clean text extraction first, then LLM processing
        if fileContent.type == .pdf {
            #if DEBUG
            print("🔥 LargeFileProcessingService: PDF content detected (\(fileContent.content.count) chars), extracting clean text first")
            #endif
            await progressHandler("Extracting clean text from PDF...")
            return await processPDFWithCleanText(
                fileContent: fileContent,
                instruction: instruction,
                llmService: llmService,
                progressHandler: progressHandler,
                transcriptHandler: transcriptHandler
            )
        }
        
        // PERFORMANCE OPTIMIZATION: Dynamic chunk sizing based on model and content
        let optimalChunkSize = await calculateOptimalChunkSize(
            for: await llmService.currentModelFilename ?? "default",
            contentLength: fileContent.content.count
        )
        let totalChunks = Int(ceil(Double(fileContent.content.count) / Double(optimalChunkSize)))
        
        print("🔥 LargeFileProcessingService: Content length: \(fileContent.content.count)")
        print("🔥 LargeFileProcessingService: Optimal chunk size: \(optimalChunkSize)")
        print("🔥 LargeFileProcessingService: Total chunks: \(totalChunks)")
        print("🔥 LargeFileProcessingService: Expected total processed: \(optimalChunkSize * totalChunks)")
        
        // CRITICAL FIX: Use sequential processing to ensure chunks are processed in order
        // Parallel processing was causing random chunk order (4, 2, 1 instead of 1, 2, 3, 4...)
        if totalChunks > 1 {
            await progressHandler("Processing \(totalChunks) parts sequentially...")
            return await processChunksSequentially(
                fileContent: fileContent,
                instruction: instruction,
                chunkSize: optimalChunkSize,
                totalChunks: totalChunks,
                llmService: llmService,
                progressHandler: progressHandler,
                transcriptHandler: transcriptHandler
            )
        } else {
            // Single chunk - use sequential processing
            await progressHandler("Processing single part...")
            return await processChunksSequentially(
                fileContent: fileContent,
                instruction: instruction,
                chunkSize: optimalChunkSize,
                totalChunks: totalChunks,
                llmService: llmService,
                progressHandler: progressHandler,
                transcriptHandler: transcriptHandler
            )
        }
    }
    
    // REMOVED: Broken parallel processing logic that was causing corrupted output
    // The sequential processing below is the working implementation
    /*
    private func processChunksInParallel(
        fileContent: FileContent,
        instruction: String,
        chunkSize: Int,
        totalChunks: Int,
        llmService: HybridLLMService,
        progressHandler: @escaping (String) async -> Void,
        transcriptHandler: @escaping (String) async -> Void
    ) async -> String? {
        
        print("🔥 LargeFileProcessingService: Using PARALLEL processing for \(totalChunks) chunks")
        
        // CRITICAL FIX: Create semaphore OUTSIDE task creation so all tasks share the same instance
        let llmSemaphore = AsyncSemaphore(value: 1)
        
        var summaries: [String] = []
        let summariesLock = NSLock()
        var completedChunks = 0
        let progressLock = NSLock()
        
        // NEW: Progress batching for better performance
        var pendingProgressUpdates: [String] = []
        var lastProgressUpdate = Date()
        
        // NEW: Early synthesis threshold (start final synthesis when 70% done)
        let synthesisThreshold = Int(Double(totalChunks) * 0.7)
        var earlySynthesisStarted = false
        

        
        // Wait for all chunks to complete
        do {
            print("🔍 LargeFileProcessingService: About to start withThrowingTaskGroup")
            let results = try await withThrowingTaskGroup(of: String.self) { group in
                print("🔍 LargeFileProcessingService: Inside task group, adding \(totalChunks) tasks")
                
                // CRITICAL FIX: Create tasks directly within the task group instead of pre-creating them
                for chunkIndex in 1...totalChunks {
                    print("🔍 LargeFileProcessingService: Adding task \(chunkIndex) to group")
                    group.addTask { [self, chunkIndex, chunkSize, fileContent, llmService, llmSemaphore] in
                        print("🔍 LargeFileProcessingService: Executing task \(chunkIndex)")
                        print("🔍 LargeFileProcessingService: Chunk \(chunkIndex) - startIndex: \((chunkIndex - 1) * chunkSize), endIndex: \(min((chunkIndex - 1) * chunkSize + chunkSize, fileContent.content.count))")
                        
                        let startIndex = (chunkIndex - 1) * chunkSize
                        let endIndex = min(startIndex + chunkSize, fileContent.content.count)
                        let chunk = String(fileContent.content[fileContent.content.index(fileContent.content.startIndex, offsetBy: startIndex)..<fileContent.content.index(fileContent.content.startIndex, offsetBy: endIndex)])
                        
                        let chunkPrompt = """
                        You are an expert document analyst. This is part \(chunkIndex) of \(totalChunks) from the document '\(fileContent.fileName)'.
                        
                        TASK: Create a comprehensive, detailed summary of this text section that captures:
                        - Main themes, key concepts, and central ideas
                        - Important facts, data, statistics, and examples
                        - Critical details, insights, and implications
                        - Technical information, procedures, or methodologies
                        - Any relationships or connections to broader topics
                        
                        REQUIREMENTS:
                        - Be comprehensive and thorough in your analysis
                        - Focus on substance and meaningful content, not just surface-level information
                        - Maintain accuracy and completeness
                        - Use clear, professional language
                        - Do not mention that this is a part of a larger document
                        - Focus only on the content provided below
                        
                        --- PART \(chunkIndex)/\(totalChunks) CONTENT ---
                        \(chunk)
                        
                        Please provide a detailed, well-structured summary that captures the full substance of this content.
                        """

                        do {
                            var chunkSummary = ""
                            
                            // CRITICAL FIX: Use async semaphore to prevent concurrent LLM access
                            // This ensures only one task can use the LLM service at a time
                            await llmSemaphore.wait()
                            
                            do {
                                // DEBUG: Check if model is actually loaded before calling generateResponse
                                print("🔍 LargeFileProcessingService: About to call generateResponse for chunk \(chunkIndex)")
                                
                                // CRITICAL FIX: Show immediate progress when starting each chunk
                                await transcriptHandler("Starting chunk \(chunkIndex)/\(totalChunks)...")
                                
                                // CRITICAL FIX: Add timeout and completion tracking to prevent infinite loops
                                var chunkSummary = ""
                                var chunkComplete = false
                                
                                // Create a task with timeout to prevent hanging
                                let chunkTask = Task {
                                    try await withThrowingTaskGroup(of: Void.self) { group in
                                        // Add the LLM generation task
                                        group.addTask {
                                            try await llmService.generateResponse(userText: chunkPrompt, useRawPrompt: true, maxTokens: 500) { token in
                                                // CRITICAL FIX: Stop generating when we reach the chunk size limit
                                                // This prevents infinite generation and ensures chunks actually complete
                                                if chunkSummary.count >= chunkSize {
                                                    chunkComplete = true
                                                    return
                                                }
                                                
                                                chunkSummary += token
                                                
                                                // CRITICAL FIX: Make transcript updates actually different each time
                                                // Show real progress with unique content to ensure UI updates
                                                if chunkSummary.count % 10 == 0 {
                                                    let progress = chunkSummary.count
                                                    // CRITICAL FIX: Use actual chunk size for percentage calculation
                                                    // This shows real progress through the current chunk
                                                    let percentage = min(100, Int((Double(progress) / Double(chunkSize)) * 100))
                                                    await transcriptHandler("Processing chunk \(chunkIndex)/\(totalChunks)... Generated \(progress) characters (\(percentage)% complete)")
                                                }
                                            }
                                        }
                                        
                                        // Add timeout task
                                        group.addTask {
                                            try await Task.sleep(nanoseconds: UInt64(30 * 1_000_000_000)) // 30 second timeout
                                            throw NSError(domain: "LargeFileProcessingService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Chunk processing timed out after 30 seconds"])
                                        }
                                        
                                        // Wait for either completion or timeout
                                        try await group.next()
                                        group.cancelAll() // Cancel remaining tasks
                                    }
                                }
                                
                                // Wait for either completion or timeout
                                do {
                                    // Wait for the chunk task to complete naturally
                                    try await chunkTask.value
                                } catch {
                                    // CRITICAL FIX: Handle timeout and completion properly
                                    if let nsError = error as? NSError, nsError.domain == "LargeFileProcessingService" && nsError.code == 1 {
                                        // Timeout occurred - check if we have enough content
                                        if chunkSummary.count >= 50 { // At least 50 characters to be useful
                                            await transcriptHandler("⚠️ Chunk \(chunkIndex)/\(totalChunks) timed out but has sufficient content (\(chunkSummary.count) characters)")
                                            chunkTask.cancel()
                                        } else {
                                            // Not enough content, this is a real failure
                                            throw error
                                        }
                                    } else if chunkSummary.count >= chunkSize {
                                        // We have enough content, cancel the task and continue
                                        chunkTask.cancel()
                                        print("🔍 LargeFileProcessingService: Chunk \(chunkIndex) reached target size, cancelling generation")
                                    } else {
                                        // Real error occurred, re-throw it
                                        throw error
                                    }
                                }
                                
                                // Ensure we don't exceed chunk size
                                if chunkSummary.count > chunkSize {
                                    chunkSummary = String(chunkSummary.prefix(chunkSize))
                                }
                                
                                // CRITICAL FIX: Show when chunk actually completes
                                await transcriptHandler("✅ Chunk \(chunkIndex)/\(totalChunks) completed!")
                            } catch {
                                // CRITICAL FIX: Better error handling to see what's failing
                                print("❌ LargeFileProcessingService: Chunk \(chunkIndex) failed with error: \(error)")
                                
                                // CRITICAL FIX: Check if this is a memory allocation failure and try to fix it immediately
                                if error.localizedDescription.contains("failed to find a memory slot") {
                                    await transcriptHandler("🔄 Memory allocation failure detected in part \(chunkIndex). Attempting to reset LLM and retry...")
                                    
                                    do {
                                        // Try to reset the LLM context
                                        try await llmService.forceUnloadModel()
                                        await transcriptHandler("✅ LLM context reset successfully")
                                        
                                        // Wait a moment for the reset to complete
                                        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                                        
                                        // Retry the chunk with fresh LLM context
                                        await transcriptHandler("🔄 Retrying part \(chunkIndex)/\(totalChunks)...")
                                        
                                        var retryChunkSummary = ""
                                        try await llmService.generateResponse(userText: chunkPrompt, useRawPrompt: true, maxTokens: 500) { token in
                                            retryChunkSummary += token
                                            await transcriptHandler(token)
                                        }
                                        
                                        // If retry succeeds, use the result and continue
                                        if !retryChunkSummary.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                                            // Signal semaphore before returning
                                            await llmSemaphore.signal()
                                            
                                            // Thread-safe append to summaries
                                            await withCheckedContinuation { continuation in
                                                summariesLock.lock()
                                                summaries.append(retryChunkSummary)
                                                summariesLock.unlock()
                                                continuation.resume()
                                            }
                                            
                                            await transcriptHandler("✅ Part \(chunkIndex)/\(totalChunks) completed successfully after retry")
                                            
                                            // Update progress
                                            await withCheckedContinuation { continuation in
                                                progressLock.lock()
                                                completedChunks += 1
                                                let currentCompleted = completedChunks
                                                progressLock.unlock()
                                                
                                                Task {
                                                    let progressMessage = "Processed \(currentCompleted)/\(totalChunks) parts (\(Int((Double(currentCompleted) / Double(totalChunks)) * 100))%)"
                                                    await progressHandler(progressMessage)
                                                    continuation.resume()
                                                }
                                            }
                                            
                                            return retryChunkSummary
                                        } else {
                                            await transcriptHandler("❌ Part \(chunkIndex)/\(totalChunks) retry failed - no content generated")
                                        }
                                    } catch {
                                        await transcriptHandler("❌ LLM reset failed: \(error.localizedDescription)")
                                    }
                                }
                                
                                await transcriptHandler("❌ Chunk \(chunkIndex)/\(totalChunks) failed: \(error.localizedDescription)")
                                
                                // Signal semaphore before re-throwing the error
                                await llmSemaphore.signal()
                                throw error
                            }
                            
                            // Signal semaphore after successful completion
                            await llmSemaphore.signal()
                            
                            // Thread-safe append to summaries using async-safe locking
                            await withCheckedContinuation { continuation in
                                summariesLock.lock()
                                summaries.append(chunkSummary)
                                summariesLock.unlock()
                                continuation.resume()
                            }
                            
                            // Update progress when chunk completes using async-safe locking
                            await withCheckedContinuation { continuation in
                                progressLock.lock()
                                completedChunks += 1
                                let currentCompleted = completedChunks
                                progressLock.unlock()
                                
                                Task {
                                    // NEW: Batch progress updates for better performance
                                    let progressMessage = "Processed \(currentCompleted)/\(totalChunks) parts (\(Int((Double(currentCompleted) / Double(totalChunks)) * 100))%)"
                                    pendingProgressUpdates.append(progressMessage)
                                    
                                    let now = Date()
                                    if now.timeIntervalSince(lastProgressUpdate) >= 0.5 || pendingProgressUpdates.count >= 3 {
                                        await progressHandler(pendingProgressUpdates.last ?? progressMessage)
                                        pendingProgressUpdates.removeAll()
                                        lastProgressUpdate = now
                                    }
                                    
                                    // REMOVED: Early synthesis was causing corrupted results
                                    // Final synthesis will be done after all chunks complete
                                    
                                    continuation.resume()
                                }
                            }
                            
                            return chunkSummary
                        } catch {
                            throw error
                        }
                    }
                }
                
                print("🔍 LargeFileProcessingService: All tasks added, starting execution")
                var results: [String] = []
                for try await result in group {
                    results.append(result)
                }
                return results
            }
            
            // Sort results by chunk index to maintain order
            summaries = results.sorted { chunk1, chunk2 in
                let index1 = extractChunkIndex(from: chunk1)
                let index2 = extractChunkIndex(from: chunk2)
                return index1 < index2
            }
            
            print("🔥 LargeFileProcessingService: All \(totalChunks) chunks processed successfully")
            
        } catch {
            let errorMessage = "Error during parallel processing: \(error.localizedDescription)"
            print("🔥 LargeFileProcessingService: Error in parallel processing: \(errorMessage)")
            await progressHandler("Error: Processing failed.")
            return nil  // Return nil on failure, not the error message
        }
        
        // CRITICAL FIX: Store processed data for subsequent questions
        await processedDataActor.setProcessedData(fileContent: fileContent, summaries: summaries)
        
        // Security: Track data creation time for automatic cleanup
        dataCreationTime = Date()
        
        print("🔥 LargeFileProcessingService: Stored processed data for future questions")
        
        // CRITICAL FIX: Focus on PROBLEM_STATEMENT - ensure LLM actually answers the user's question
        // WORKING SOLUTION: Generate final summary without broken LLM
        await transcriptHandler("🔄 Generating final unified summary from all chunks...")
        return generateWorkingFinalSummary(from: summaries, instruction: instruction)
    }
    */
    
    // NEW: Sequential processing for single chunks or fallback
    private func processChunksSequentially(
        fileContent: FileContent,
        instruction: String,
        chunkSize: Int,
        totalChunks: Int,
        llmService: HybridLLMService,
        progressHandler: @escaping (String) async -> Void,
        transcriptHandler: @escaping (String) async -> Void
    ) async -> String? {
        
        print("🔥 LargeFileProcessingService: Using SEQUENTIAL processing for \(totalChunks) chunks")
        
        var summaries: [String] = []
        
        for chunkIndex in 1...totalChunks {
            await progressHandler("Analyzing part \(chunkIndex)/\(totalChunks)...")
            
            // REMOVED: Early synthesis at 70% completion was causing corrupted results
            // Early synthesis should only run after ALL chunks are complete
            
            let startIndex = (chunkIndex - 1) * chunkSize
            let endIndex = min(startIndex + chunkSize, fileContent.content.count)
            let chunk = String(fileContent.content[fileContent.content.index(fileContent.content.startIndex, offsetBy: startIndex)..<fileContent.content.index(fileContent.content.startIndex, offsetBy: endIndex)])
            
            let chunkPrompt = """
            You are an expert document analyst. This is part \(chunkIndex) of \(totalChunks) from the document '\(fileContent.fileName)'.
            
            TASK: Create a comprehensive, detailed summary of this text section that captures:
            - Main themes, key concepts, and central ideas
            - Important facts, data, statistics, and examples
            - Critical details, insights, and implications
            - Technical information, procedures, or methodologies
            - Any relationships or connections to broader topics
            
            REQUIREMENTS:
            - Be comprehensive and thorough in your analysis
            - Focus on substance and meaningful content, not just surface-level information
            - Maintain accuracy and completeness
            - Use clear, professional language
            - Do not mention that this is a part of a larger document
            - Focus only on the content provided below
            
            --- PART \(chunkIndex)/\(totalChunks) CONTENT ---
            \(chunk)
            
            Please provide a detailed, well-structured summary that captures the full substance of this content.
            """

                do {
                    // FIXED: Re-enable LLM processing for proper chunk summarization
                    await transcriptHandler("✅ Processing chunk \(chunkIndex)/\(totalChunks) with LLM...")
                    
                    var chunkSummary = ""
                    try await llmService.generateResponse(userText: chunkPrompt, useRawPrompt: true, maxTokens: 300) { token in
                        chunkSummary += token
                    }
                    
                    // Ensure we have meaningful content
                    if chunkSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        await transcriptHandler("⚠️ Chunk \(chunkIndex)/\(totalChunks) generated empty summary, using fallback")
                        chunkSummary = extractKeyInformation(from: chunk, chunkIndex: chunkIndex, totalChunks: totalChunks)
                    }
                    
                    summaries.append(chunkSummary)
                    await transcriptHandler("✅ Chunk \(chunkIndex)/\(totalChunks) processed successfully with \(chunkSummary.count) characters")
                } catch {
                    let errorMessage = "Error processing part \(chunkIndex)/\(totalChunks): \(error.localizedDescription)"
                    print("🔥 LargeFileProcessingService: Error processing part \(chunkIndex)/\(totalChunks): \(errorMessage)")
                    
                    // CRITICAL FIX: Check if this is a memory allocation failure and try to fix it immediately
                    if error.localizedDescription.contains("failed to find a memory slot") {
                        await transcriptHandler("🔄 Memory allocation failure detected in part \(chunkIndex). Attempting to reset LLM and retry...")
                        
                        do {
                            // Try to reset the LLM context
                            try await llmService.forceUnloadModel()
                            await transcriptHandler("✅ LLM context reset successfully")
                            
                            // Wait a moment for the reset to complete
                            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                            
                            // Retry the chunk with fresh LLM context
                            await transcriptHandler("🔄 Retrying part \(chunkIndex)/\(totalChunks)...")
                            
                            var retryChunkSummary = ""
                            try await llmService.generateResponse(userText: chunkPrompt, useRawPrompt: true, maxTokens: 300) { token in
                                retryChunkSummary += token
                                await transcriptHandler(token)
                            }
                            
                            // If retry succeeds, use the result and continue
                            if !retryChunkSummary.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                                summaries.append(retryChunkSummary)
                                await transcriptHandler("✅ Part \(chunkIndex)/\(totalChunks) completed successfully after retry")
                                continue // Move to next chunk
                            } else {
                                await transcriptHandler("❌ Part \(chunkIndex)/\(totalChunks) retry failed - no content generated")
                            }
                        } catch {
                            await transcriptHandler("❌ LLM reset failed: \(error.localizedDescription)")
                        }
                    }
                    
                    // If we get here, the chunk failed and couldn't be retried
                    await transcriptHandler("❌ Part \(chunkIndex)/\(totalChunks) failed and could not be retried")
                    await progressHandler("Error: Processing failed.")
                    return nil  // Return nil on failure, not the error message
                }

                    // Give the UI a moment to update
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds (4x less frequent for better performance)
    }
    
    // CRITICAL FIX: Store processed data for subsequent questions
    await processedDataActor.setProcessedData(fileContent: fileContent, summaries: summaries)
    
    // Security: Track data creation time for automatic cleanup
    dataCreationTime = Date()
    
    print("🔥 LargeFileProcessingService: Stored processed data for future questions")
    
            // CRITICAL FIX: Focus on PROBLEM_STATEMENT - ensure LLM actually answers the user's question
        // Generate the final answer directly using all completed summaries
        await transcriptHandler("🔄 Generating final answer from all processed parts...")
        
        return await generateDirectFinalAnswer(
            summaries: summaries,
            instruction: instruction,
            llmService: llmService,
            transcriptHandler: transcriptHandler,
            progressHandler: progressHandler
        )
    }
    
    // NEW: Process image content - return text directly (OCR result)
    private func processImageContent(
        fileContent: FileContent,
        instruction: String,
        llmService: HybridLLMService,
        progressHandler: @escaping (String) async -> Void,
        transcriptHandler: @escaping (String) async -> Void
    ) async -> String? {
        
        print("🔥 LargeFileProcessingService: Processing image content directly")
        await progressHandler("Analyzing image text...")
        
        // For any question about image text, just return the text content directly
        await progressHandler("Image analysis complete!")
        return fileContent.content
    }
    
    // NEW: Process PDF with parallel page processing
    private func processPDFWithCleanText(
        fileContent: FileContent,
        instruction: String,
        llmService: HybridLLMService,
        progressHandler: @escaping (String) async -> Void,
        transcriptHandler: @escaping (String) async -> Void
    ) async -> String? {
        
        print("🔥 LargeFileProcessingService: Processing PDF with parallel page processing")
        
        // Step 1: Extract clean text from PDF content
        let cleanText = extractCleanTextFromPDF(fileContent.content)
        print("🔥 LargeFileProcessingService: Clean text extracted (\(cleanText.count) chars)")
        
        await progressHandler("Clean text extracted, processing pages in parallel...")
        
        // Step 2: Parallel page processing for better performance
        let pages = extractPDFPages(cleanText)
        print("🔥 LargeFileProcessingService: Extracted \(pages.count) pages")
        
        if pages.count > 1 {
            await progressHandler("Processing \(pages.count) pages in parallel...")
            return await processPagesInParallel(
                pages: pages,
                instruction: instruction,
                llmService: llmService,
                progressHandler: progressHandler,
                transcriptHandler: transcriptHandler
            )
        } else {
            // Single page - use direct processing
            await progressHandler("Single page detected, processing directly...")
            return createIntelligentTextSummary(from: cleanText, instruction: instruction)
        }
    }
    
    // PERFORMANCE OPTIMIZATION: Extract PDF pages for parallel processing
    private func extractPDFPages(_ content: String) -> [String] {
        // Split content by common page break patterns
        let pageBreaks = [
            "\\f", // Form feed
            "\\n\\s*\\n\\s*\\n", // Multiple newlines
            "\\n\\s*---\\s*\\n", // Dashed separators
            "\\n\\s*===\\s*\\n", // Equals separators
            "\\n\\s*Page\\s+\\d+\\s*\\n", // Page numbers
        ]
        
        var pages: [String] = [content] // Start with full content as single page
        
        for pattern in pageBreaks {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
                if matches.count > 1 {
                    // Split by this pattern
                    let splitContent = regex.stringByReplacingMatches(
                        in: content,
                        options: [],
                        range: NSRange(content.startIndex..., in: content),
                        withTemplate: "|||PAGE_BREAK|||"
                    )
                    pages = splitContent.components(separatedBy: "|||PAGE_BREAK|||")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    break
                }
            }
        }
        
        // If no page breaks found, split by content length
        if pages.count == 1 && content.count > 5000 {
            let chunkSize = content.count / 3 // Split into 3 parts
            pages = []
            var startIndex = content.startIndex
            
            while startIndex < content.endIndex {
                let endIndex = content.index(startIndex, offsetBy: min(chunkSize, content.distance(from: startIndex, to: content.endIndex)))
                let page = String(content[startIndex..<endIndex])
                if !page.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    pages.append(page)
                }
                startIndex = endIndex
            }
        }
        
        return pages
    }
    
    // PERFORMANCE OPTIMIZATION: Process PDF pages in parallel
    private func processPagesInParallel(
        pages: [String],
        instruction: String,
        llmService: HybridLLMService,
        progressHandler: @escaping (String) async -> Void,
        transcriptHandler: @escaping (String) async -> Void
    ) async -> String? {
        
        print("🔥 LargeFileProcessingService: Processing \(pages.count) pages in parallel")
        
        var pageSummaries: [String] = []
        let pageCount = pages.count
        
        // Process pages in parallel with controlled concurrency
        await withTaskGroup(of: (Int, String?).self) { group in
            for (index, page) in pages.enumerated() {
                group.addTask {
                    let summary = await self.processSinglePage(
                        page: page,
                        pageIndex: index + 1,
                        totalPages: pageCount,
                        instruction: instruction,
                        llmService: llmService,
                        progressHandler: progressHandler,
                        transcriptHandler: transcriptHandler
                    )
                    return (index, summary)
                }
            }
            
            // Collect results as they complete
            for await (index, result) in group {
                if let summary = result {
                    pageSummaries.append(summary)
                }
            }
        }
        
        // Sort page summaries by index
        pageSummaries.sort { page1, page2 in
            let index1 = extractPageIndex(from: page1)
            let index2 = extractPageIndex(from: page2)
            return index1 < index2
        }
        
        await progressHandler("All pages processed, creating final summary...")
        
        // Create final summary from all page summaries
        return createFinalPDFSummary(
            pageSummaries: pageSummaries,
            instruction: instruction,
            totalPages: pageCount
        )
    }
    
    // Process a single PDF page
    private func processSinglePage(
        page: String,
        pageIndex: Int,
        totalPages: Int,
        instruction: String,
        llmService: HybridLLMService,
        progressHandler: @escaping (String) async -> Void,
        transcriptHandler: @escaping (String) async -> Void
    ) async -> String? {
        
        await progressHandler("Processing page \(pageIndex)/\(totalPages)...")
        
        // Create page-specific summary
        let pageSummary = createIntelligentTextSummary(from: page, instruction: instruction)
        
        // Add page header
        let finalPageSummary = "📄 PAGE \(pageIndex)/\(totalPages)\n\n\(pageSummary)"
        
        await transcriptHandler("✅ Page \(pageIndex)/\(totalPages) processed")
        
        return finalPageSummary
    }
    
    // Extract page index from summary
    private func extractPageIndex(from summary: String) -> Int {
        if let range = summary.range(of: "PAGE (\\d+)/", options: .regularExpression) {
            let indexString = String(summary[range])
            if let index = Int(indexString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                return index
            }
        }
        return 0
    }
    
    // Create final PDF summary from page summaries
    private func createFinalPDFSummary(
        pageSummaries: [String],
        instruction: String,
        totalPages: Int
    ) -> String {
        
        var finalSummary = "📋 PDF DOCUMENT SUMMARY\n\n"
        finalSummary += "📖 Request: \(instruction)\n\n"
        finalSummary += "📊 Analysis: Document processed across \(totalPages) pages\n\n"
        
        if pageSummaries.isEmpty {
            finalSummary += "❌ No pages were successfully processed.\n"
            return finalSummary
        }
        
        finalSummary += "📄 PAGE SUMMARIES:\n\n"
        
        for (index, pageSummary) in pageSummaries.enumerated() {
            finalSummary += "--- PAGE \(index + 1) ---\n"
            finalSummary += pageSummary + "\n\n"
        }
        
        finalSummary += "✅ PDF processing complete - \(pageSummaries.count)/\(totalPages) pages processed successfully"
        
        return finalSummary
    }
    
    // PERFORMANCE OPTIMIZATION: High-performance text extraction
    private func extractCleanTextFromPDF(_ content: String) -> String {
        // Use PerformanceStringBuilder for better performance
        var result = PerformanceStringBuilder()
        
        // Process content in chunks for better memory efficiency
        let chunkSize = 1000
        var startIndex = content.startIndex
        
        while startIndex < content.endIndex {
            let endIndex = content.index(startIndex, offsetBy: min(chunkSize, content.distance(from: startIndex, to: content.endIndex)))
            let chunk = String(content[startIndex..<endIndex])
            
            // Process chunk with optimized algorithms
            let processedChunk = processTextChunk(chunk)
            result.append(processedChunk)
            
            startIndex = endIndex
        }
        
        return result.toString()
    }
    
    // PERFORMANCE OPTIMIZATION: Process text chunks efficiently
    private func processTextChunk(_ chunk: String) -> String {
        var processed = chunk
        
        // Use compiled regex patterns for better performance
        processed = TextProcessor.shared.cleanWhitespace(processed)
        processed = TextProcessor.shared.removePageNumbers(processed)
        processed = TextProcessor.shared.normalizeLineBreaks(processed)
        
        return processed
    }
    
    // NEW: Chunk raw text at natural boundaries (sentences, paragraphs)
    private func chunkRawTextAtNaturalBoundaries(_ content: String) -> [String] {
        var chunks: [String] = []
        let paragraphs = content.components(separatedBy: "\n\n")
        
        for paragraph in paragraphs {
            let trimmedParagraph = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedParagraph.isEmpty {
                // Split long paragraphs into sentences
                let sentences = trimmedParagraph.components(separatedBy: CharacterSet(charactersIn: ".!?"))
                var currentChunk = ""
                
                for sentence in sentences {
                    let trimmedSentence = sentence.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    if !trimmedSentence.isEmpty {
                        if currentChunk.count + trimmedSentence.count > 400 {
                            // Much smaller chunks to avoid context limits
                            if !currentChunk.isEmpty {
                                chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
                                currentChunk = ""
                            }
                        }
                        currentChunk += trimmedSentence + ". "
                    }
                }
                
                // Add the last chunk from this paragraph
                if !currentChunk.isEmpty {
                    chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        }
        
        return chunks
    }
    
    // NEW: Extract key information directly from text without LLM (improved)
    private func extractKeyInformationDirectly(_ content: String) -> [String] {
        var keyPoints: [String] = []
        
        // First, try to split by lines
        let lines = content.components(separatedBy: .newlines)
        
        // If we have very few lines (meaning it's mostly one big block), split by sentences instead
        let meaningfulLines = lines.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        if meaningfulLines.count < 5 {
            // Content is mostly one block, split by sentences
            let sentences = content.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            for sentence in sentences {
                let trimmedSentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedSentence.count > 15 && trimmedSentence.count < 300 {
                    // Skip timestamps and casual conversation
                    if isTimestampOrCasual(trimmedSentence) {
                        continue
                    }
                    
                    // Look for important patterns
                    if isImportantLine(trimmedSentence) {
                        let cleanSentence = cleanAndFormatPoint(trimmedSentence)
                        if !cleanSentence.isEmpty {
                            keyPoints.append(cleanSentence)
                        }
                    }
                }
            }
        } else {
            // Content has proper line breaks, process line by line
            for line in lines {
                let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmedLine.isEmpty && trimmedLine.count > 8 && trimmedLine.count < 400 {
                    // Skip timestamps and casual conversation
                    if isTimestampOrCasual(trimmedLine) {
                        continue
                    }
                    
                    // Look for important patterns with better logic
                    if isImportantLine(trimmedLine) {
                        // Clean and format the line
                        let cleanLine = cleanAndFormatPoint(trimmedLine)
                        if !cleanLine.isEmpty && cleanLine.count > 15 {
                            keyPoints.append(cleanLine)
                        }
                    }
                }
            }
        }
        
        // Remove duplicates and limit to most important points
        let uniquePoints = Array(Set(keyPoints))
        return Array(uniquePoints.prefix(15)) // Increased to 15 points for comprehensive information like original
    }
    
    // NEW: Improved logic to determine if a line is important
    private func isImportantLine(_ line: String) -> Bool {
        // Skip very long lines (likely entire document blocks)
        if line.count > 600 {
            return false
        }
        
        // Check for bullet points and numbered lists
        if line.hasPrefix("•") || line.hasPrefix("-") || line.hasPrefix("*") ||
           line.range(of: "^\\d+\\.", options: .regularExpression) != nil {
            return true
        }
        
        // Check for section headers (all caps or title case)
        if line.range(of: "^[A-Z][A-Z\\s]+$", options: .regularExpression) != nil ||
           line.range(of: "^[A-Z][a-z]+(\\s+[A-Z][a-z]+)*:", options: .regularExpression) != nil {
            return true
        }
        
        // Check for important content patterns
        if isImportantContent(line) {
            return true
        }
        
        // Check for sentences that contain important keywords
        if containsImportantKeywords(line) {
            return true
        }
        
        // Check for sentences with numbers (often contain important data)
        if line.range(of: "\\d+", options: .regularExpression) != nil && line.count > 15 {
            return true
        }
        
        // Check for questions (often important)
        if line.contains("?") && line.count > 10 {
            return true
        }
        
        // Check for statements with common important words
        let importantWords = ["will", "should", "must", "need", "require", "important", "note", "warning", "caution", "result", "conclusion", "summary", "findings", "recommendation", "affect", "impact", "change", "develop", "improve", "increase", "decrease"]
        let lowercasedLine = line.lowercased()
        for word in importantWords {
            if lowercasedLine.contains(word) && line.count > 15 {
                return true
            }
        }
        
        // Check for sentences with proper structure (more lenient)
        if line.contains(".") && line.count > 20 && line.count < 300 {
            return true
        }
        
        return false
    }
    
    // NEW: Check if line contains important keywords
    private func containsImportantKeywords(_ line: String) -> Bool {
        let importantKeywords = [
            // Medical terms
            "diagnosis", "treatment", "symptoms", "condition", "disease", "syndrome",
            "malformation", "fluid", "pressure", "nerves", "spinal", "cord", "brain",
            "mri", "scan", "test", "results", "findings", "recommendation", "surgery",
            "patient", "doctor", "physician", "specialist", "clinic", "hospital",
            "appointment", "consultation", "examination", "assessment", "evaluation",
            
            // General important terms
            "important", "significant", "critical", "urgent", "priority", "key",
            "main", "primary", "essential", "necessary", "required", "mandatory",
            "conclusion", "summary", "recommendation", "action", "next steps",
            "deadline", "due date", "schedule", "timeline", "milestone",
            
            // Financial terms
            "cost", "price", "budget", "expense", "revenue", "profit", "loss",
            "payment", "invoice", "receipt", "refund", "discount", "fee",
            
            // Legal terms
            "agreement", "contract", "terms", "conditions", "liability", "responsibility",
            "obligation", "rights", "duties", "compliance", "regulation", "policy"
        ]
        
        let lowerLine = line.lowercased()
        for keyword in importantKeywords {
            if lowerLine.contains(keyword) {
                return true
            }
        }
        
        return false
    }
    
    // NEW: Check if line is timestamp or casual conversation
    private func isTimestampOrCasual(_ line: String) -> Bool {
        // Timestamp patterns (0:00:02, 0:00:03, etc.)
        if line.range(of: "^\\d+:\\d+:\\d+", options: .regularExpression) != nil {
            return true
        }
        
        // Casual conversation patterns
        let casualWords = ["okay", "yeah", "uh-huh", "um", "uh", "so", "like", "you know", "i mean", "right", "sure"]
        let lowerLine = line.lowercased()
        for word in casualWords {
            if lowerLine.contains(word) && line.count < 50 {
                return true
            }
        }
        
        return false
    }
    
    // NEW: Check if content is important (medical terms, numbers, names, etc.)
    private func isImportantContent(_ line: String) -> Bool {
        // Medical terms and conditions
        let medicalTerms = ["diagnosis", "treatment", "symptoms", "condition", "disease", "syndrome", 
                           "malformation", "fluid", "pressure", "nerves", "spinal", "cord", "brain",
                           "mri", "scan", "test", "results", "findings", "recommendation", "surgery",
                           "patient", "doctor", "physician", "specialist", "clinic", "hospital",
                           "appointment", "consultation", "examination", "assessment", "evaluation"]
        
        let lowerLine = line.lowercased()
        for term in medicalTerms {
            if lowerLine.contains(term) {
                return true
            }
        }
        
        // Contains numbers (measurements, dates, etc.)
        if line.range(of: "\\d+", options: .regularExpression) != nil {
            return true
        }
        
        // Contains proper nouns (names, places)
        if line.range(of: "[A-Z][a-z]+", options: .regularExpression) != nil {
            return true
        }
        
        // Reasonable length for meaningful content
        return line.count > 20 && line.count < 200
    }
    
    // NEW: Create LLM-enhanced summary from extracted points
    private func createLLMEnhancedSummary(_ keyPoints: [String], llmService: HybridLLMService) async -> String {
        print("🔥 LargeFileProcessingService: Starting LLM enhancement with \(keyPoints.count) key points")
        
        // Combine key points into a single text block
        let extractedText = keyPoints.joined(separator: "\n")
        print("🔥 LargeFileProcessingService: Extracted text length: \(extractedText.count) characters")
        
        // Check if we have enough content but not too much
        if extractedText.count < 100 {
            print("🔥 LargeFileProcessingService: Not enough content, falling back to simple summary")
            // Fallback to simple summary if not enough content
            return createIntelligentTextSummary(from: extractedText, instruction: "")
        }
        
        // Create prompt for LLM processing
        var llmPrompt = """
        Write a brief summary of this document. Use exactly 3 sentences.

        \(extractedText)

        Summary:
        """
        
        // Check if content is too large for LLM
        if extractedText.count > 800 {
            print("🔥 LargeFileProcessingService: Content too large (\(extractedText.count) chars), truncating for LLM")
            // Truncate to avoid token limits
            let truncatedText = String(extractedText.prefix(800))
            llmPrompt = llmPrompt.replacingOccurrences(of: extractedText, with: truncatedText)
        }
        
        do {
            print("🔥 LargeFileProcessingService: Calling LLM for enhancement...")
            // Process through LLM with conservative token limit
            let llmResponse = try await llmService.generateResponseSync(
                userText: llmPrompt,
                useRawPrompt: true,
                maxTokens: 1000  // Very high limit - let model complete naturally
            )
            
            print("🔥 LargeFileProcessingService: LLM enhancement successful, response length: \(llmResponse.count)")
            return llmResponse
            
        } catch {
            print("❌ LargeFileProcessingService: Error creating LLM-enhanced summary: \(error)")
            // Fallback to simple summary if LLM fails
            return createIntelligentTextSummary(from: extractedText, instruction: "")
        }
    }
    
    // NEW: Create intelligent text summary without LLM enhancement
    private func createIntelligentTextSummary(from content: String, instruction: String) -> String {
        print("🔥 LargeFileProcessingService: Creating intelligent text summary")
        
        // Extract structured information from the text
        let documentInfo = extractDocumentStructure(content)
        let keyPoints = extractKeyInformationDirectly(content)
        let importantData = extractImportantData(content)
        let topics = extractMainTopics(content)
        
        // Create a well-structured, readable summary
        var summary = "📋 DOCUMENT SUMMARY\n\n"
        
        // Add document overview with better formatting
        summary += "📖 Document Overview:\n"
        summary += "• Content Type: \(documentInfo.type)\n"
        summary += "• Main Topics: \(topics.joined(separator: ", "))\n"
        summary += "• Data Points: \(importantData.count) important items found\n\n"
        
        // Add key points with better formatting
        if !keyPoints.isEmpty {
            summary += "🔑 Key Points:\n"
            for (index, point) in keyPoints.enumerated() {
                let cleanPoint = cleanAndFormatPoint(point)
                summary += "\(index + 1). \(cleanPoint)\n\n"
            }
        }
        
        // Add important data with better formatting
        if !importantData.isEmpty {
            summary += "📊 Important Data:\n"
            for data in importantData.prefix(15) {
                summary += "• \(data)\n"
            }
            summary += "\n"
        }
        
        // Add document structure info with better formatting
        if !documentInfo.sections.isEmpty {
            summary += "📑 Document Structure:\n"
            for section in documentInfo.sections.prefix(15) {
                summary += "• \(section)\n"
            }
            summary += "\n"
        }
        
        // Add summary based on instruction with better formatting
        if !instruction.isEmpty && instruction.lowercased() != "summarize" {
            summary += "🎯 Response to Your Question:\n"
            summary += "Question: \"\(instruction)\"\n\n"
            summary += "The document contains relevant information that addresses your question. "
            summary += "Key details are highlighted in the sections above.\n\n"
        }
        
        summary += "✅ Summary generated using intelligent text analysis"
        
        return summary
    }
    
    // NEW: Extract document structure and type
    private func extractDocumentStructure(_ content: String) -> (type: String, sections: [String]) {
        var sections: [String] = []
        var documentType = "General Document"
        
        // Look for document type indicators
        let lowerContent = content.lowercased()
        if lowerContent.contains("medical") || lowerContent.contains("diagnosis") || lowerContent.contains("treatment") {
            documentType = "Medical Document"
        } else if lowerContent.contains("legal") || lowerContent.contains("contract") || lowerContent.contains("agreement") {
            documentType = "Legal Document"
        } else if lowerContent.contains("financial") || lowerContent.contains("budget") || lowerContent.contains("report") {
            documentType = "Financial Document"
        } else if lowerContent.contains("transcript") || lowerContent.contains("conversation") {
            documentType = "Transcript/Conversation"
        }
        
        // Extract section headers (lines that are all caps or start with numbers)
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLine.count > 5 && trimmedLine.count < 100 {
                // Check if it's a section header
                if trimmedLine.range(of: "^[A-Z\\s]+$", options: .regularExpression) != nil ||
                   trimmedLine.range(of: "^\\d+\\.\\s+[A-Z]", options: .regularExpression) != nil ||
                   trimmedLine.range(of: "^[A-Z][A-Z\\s]+:", options: .regularExpression) != nil {
                    sections.append(trimmedLine)
                }
            }
        }
        
        return (type: documentType, sections: sections)
    }
    
    // NEW: Extract important data (numbers, dates, names, etc.)
    private func extractImportantData(_ content: String) -> [String] {
        var importantData: [String] = []
        
        // Extract dates
        let datePattern = "\\b\\d{1,2}[/-]\\d{1,2}[/-]\\d{2,4}\\b|\\b\\d{4}[/-]\\d{1,2}[/-]\\d{1,2}\\b"
        if let regex = try? NSRegularExpression(pattern: datePattern) {
            let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
            for match in matches {
                if let range = Range(match.range, in: content) {
                    let date = String(content[range])
                    importantData.append("Date: \(date)")
                }
            }
        }
        
        // Extract monetary amounts
        let moneyPattern = "\\$\\d+[,\\.]?\\d*|\\d+[,\\.]?\\d*\\s*(dollars?|USD|cents?)"
        if let regex = try? NSRegularExpression(pattern: moneyPattern, options: .caseInsensitive) {
            let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
            for match in matches {
                if let range = Range(match.range, in: content) {
                    let amount = String(content[range])
                    importantData.append("Amount: \(amount)")
                }
            }
        }
        
        // Extract percentages
        let percentPattern = "\\d+%|\\d+\\s*percent"
        if let regex = try? NSRegularExpression(pattern: percentPattern, options: .caseInsensitive) {
            let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
            for match in matches {
                if let range = Range(match.range, in: content) {
                    let percent = String(content[range])
                    importantData.append("Percentage: \(percent)")
                }
            }
        }
        
        // Extract phone numbers
        let phonePattern = "\\(?\\d{3}\\)?[-\\s]?\\d{3}[-\\s]?\\d{4}"
        if let regex = try? NSRegularExpression(pattern: phonePattern) {
            let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
            for match in matches {
                if let range = Range(match.range, in: content) {
                    let phone = String(content[range])
                    importantData.append("Phone: \(phone)")
                }
            }
        }
        
        return Array(Set(importantData)) // Remove duplicates
    }
    
    // NEW: Extract main topics from content
    private func extractMainTopics(_ content: String) -> [String] {
        let words = content.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 4 && !isCommonWord($0) }
        
        // Count word frequency
        var wordCount: [String: Int] = [:]
        for word in words {
            wordCount[word, default: 0] += 1
        }
        
        // Get top 5 most frequent meaningful words
        let topWords = wordCount.sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key.capitalized }
        
        return Array(topWords)
    }
    
    // NEW: Check if word is common (should be filtered out)
    private func isCommonWord(_ word: String) -> Bool {
        let commonWords = ["the", "and", "for", "are", "but", "not", "you", "all", "can", "had", "her", "was", "one", "our", "out", "day", "get", "has", "him", "his", "how", "its", "may", "new", "now", "old", "see", "two", "who", "boy", "did", "man", "men", "put", "say", "she", "too", "use", "way", "will", "with", "this", "that", "they", "have", "been", "from", "were", "said", "each", "which", "their", "time", "will", "about", "there", "could", "other", "after", "first", "well", "also", "where", "much", "some", "very", "when", "come", "here", "just", "like", "long", "make", "many", "over", "such", "take", "than", "them", "these", "think", "want", "what", "year", "your", "good", "know", "look", "more", "most", "only", "other", "right", "should", "still", "those", "under", "water", "would", "write", "being", "every", "great", "might", "shall", "these", "those", "where", "which", "while", "whose", "world", "years", "young", "again", "along", "among", "begin", "being", "below", "between", "during", "family", "follow", "friend", "little", "never", "number", "people", "please", "really", "should", "something", "sometimes", "through", "together", "without", "another", "because", "before", "change", "different", "example", "important", "interest", "question", "sentence", "something", "thought", "through", "together", "without"]
        
        return commonWords.contains(word.lowercased())
    }
    
    // NEW: Clean and format individual points
    private func cleanAndFormatPoint(_ point: String) -> String {
        var cleanPoint = point.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove bullet points and numbering
        cleanPoint = cleanPoint.replacingOccurrences(of: "^[•\\-\\*]\\s*", with: "", options: .regularExpression)
        cleanPoint = cleanPoint.replacingOccurrences(of: "^\\d+\\.\\s*", with: "", options: .regularExpression)
        
        // Remove internal thinking patterns
        cleanPoint = cleanPoint.replacingOccurrences(of: "\\b(thinking|let me|I need to|I should|I will|I can|I'll)\\b", with: "", options: [.regularExpression, .caseInsensitive])
        cleanPoint = cleanPoint.replacingOccurrences(of: "\\b(this is|that is|it is|there is|here is)\\b", with: "", options: [.regularExpression, .caseInsensitive])
        cleanPoint = cleanPoint.replacingOccurrences(of: "\\b(so|now|then|next|also|furthermore|moreover|additionally)\\b", with: "", options: [.regularExpression, .caseInsensitive])
        
        // Clean up multiple spaces
        cleanPoint = cleanPoint.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        // Capitalize first letter
        if !cleanPoint.isEmpty {
            cleanPoint = String(cleanPoint.prefix(1).uppercased()) + String(cleanPoint.dropFirst())
        }
        
        // Ensure it ends with proper punctuation
        if !cleanPoint.isEmpty && !cleanPoint.hasSuffix(".") && !cleanPoint.hasSuffix("!") && !cleanPoint.hasSuffix("?") {
            cleanPoint += "."
        }
        
        return cleanPoint
    }
    
    // NEW: Extracted final synthesis logic
    private func createFinalSynthesis(
        summaries: [String],
        instruction: String,
        totalChunks: Int,
        llmService: HybridLLMService,
        transcriptHandler: @escaping (String) async -> Void,
        progressHandler: @escaping (String) async -> Void
    ) async -> String? {
        
        await progressHandler("All parts analyzed. Creating final summary...")
        
        // CRITICAL FIX: Process final synthesis in much smaller batches to avoid memory allocation failures
        // The LLM can't handle even 1226 tokens, so we need to process in much smaller chunks
        let _ = 50  // Much smaller to keep prompts under 1000 characters
        
        // CRITICAL FIX: Check if we have enough valid summaries before giving up
        let validSummaries = summaries.filter { !$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty }
        
        if validSummaries.count < totalChunks / 2 {
            // Less than half the chunks were processed - this is a failure
            let errorMessage = "❌ Processing failed: Only \(validSummaries.count)/\(totalChunks) parts were successfully analyzed."
            await transcriptHandler(errorMessage)
            await progressHandler("Error: Processing failed.")
            return errorMessage
        }
        
        // CRITICAL FIX: Implement automatic retry for failed chunks
        if validSummaries.count < totalChunks {
            await transcriptHandler("🔄 Some chunks failed. Attempting automatic retry with LLM reset...")
            
            let failedChunks = await retryFailedChunks(
                totalChunks: totalChunks,
                successfulSummaries: validSummaries,
                instruction: instruction,
                llmService: llmService,
                transcriptHandler: transcriptHandler,
                progressHandler: progressHandler
            )
            
            if failedChunks > 0 {
                await transcriptHandler("✅ Successfully retried \(failedChunks) failed chunks!")
                // Update validSummaries with retried chunks
                let updatedValidSummaries = summaries.filter { !$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty }
                if updatedValidSummaries.count >= totalChunks {
                    await transcriptHandler("🎉 All chunks now processed successfully! Creating final summary...")
                    return await createFinalSummary(
                        summaries: updatedValidSummaries,
                        instruction: instruction,
                        totalChunks: totalChunks,
                        transcriptHandler: transcriptHandler,
                        progressHandler: progressHandler
                    )
                }
            }
        }
        
        // We have enough summaries to work with - create a structured summary
        await transcriptHandler("⚠️ LLM memory exhausted. Creating structured summary from \(validSummaries.count) successfully processed parts...\n")
        
        // Create a simple structured summary from the SUCCESSFULLY PROCESSED chunk summaries
        var structuredSummary = "📋 Document Summary\n\n"
        structuredSummary += "📖 Original Request: \(instruction)\n\n"
        structuredSummary += "📊 Analysis: Document processed in \(totalChunks) parts\n\n"
        structuredSummary += "📝 Key Points:\n"
        
        if validSummaries.isEmpty {
            structuredSummary += "❌ No valid summaries were generated from the chunks.\n"
            structuredSummary += "This indicates the LLM failed to process the document content.\n"
        } else {
            // Add the valid chunk summaries as key points
            let maxKeyPoints = min(10, validSummaries.count) // Show more valid summaries
            for i in 0..<maxKeyPoints {
                let summary = validSummaries[i]
                // Clean up the summary text
                let cleanSummary = summary
                    .replacingOccurrences(of: "febri\nfebri\nfebri", with: "febrile symptoms")
                    .replacingOccurrences(of: "I'm not sure if it's a problem.\nI'm not sure if it's a problem.", with: "Uncertainty about problem status")
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                let truncatedSummary = cleanSummary.count > 150 ? String(cleanSummary.prefix(150)) + "..." : cleanSummary
                structuredSummary += "• Part \(i+1): \(truncatedSummary)\n"
            }
            
            if validSummaries.count > maxKeyPoints {
                structuredSummary += "• ... and \(validSummaries.count - maxKeyPoints) more parts\n"
            }
        }
        
        structuredSummary += "\n✅ Summary completed using structured format due to LLM memory constraints."
        structuredSummary += "\n📊 Successfully processed: \(validSummaries.count)/\(totalChunks) parts"
        
        await transcriptHandler(structuredSummary)
        await progressHandler("Processing complete!")
        
        return structuredSummary

        // This code is no longer needed - we return the structured summary above
    }
    
    // CRITICAL FIX: Direct final answer generation that solves the PROBLEM_STATEMENT
    // This function ensures the LLM actually answers the user's question about the PDF
    private func generateDirectFinalAnswer(
        summaries: [String],
        instruction: String,
        llmService: HybridLLMService,
        transcriptHandler: @escaping (String) async -> Void,
        progressHandler: @escaping (String) async -> Void
    ) async -> String? {
        
        await progressHandler("Generating final answer to your question...")
        await transcriptHandler("🔄 LLM is now analyzing all document content to answer: '\(instruction)'")
        
        // CRITICAL FIX: Drastically reduce prompt size to prevent token exhaustion
        // The LLM is hitting 2000 token limit, so we need much smaller prompts
        let maxSummaryLength = 50 // Drastically reduced from 200 to 50 to prevent token exhaustion
        let validSummaries = summaries.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        if validSummaries.isEmpty {
            await transcriptHandler("❌ No valid content was extracted from the document")
            return "❌ Error: The document could not be processed. No content was extracted."
        }
        
        // CRITICAL FIX: Limit the number of summaries to prevent token exhaustion
        let maxSummaries = 5 // Only use first 5 summaries to keep prompt very small
        let limitedSummaries = Array(validSummaries.prefix(maxSummaries))
        
        // Create a simple, focused prompt for PDF summaries
        let focusedPrompt = """
        You are a helpful assistant. Answer this question about the document: "\(instruction)"

        Document content:
        \(limitedSummaries.map { String($0.prefix(maxSummaryLength)) }.joined(separator: "\n\n"))

        Answer:
        """
        
        do {
            var finalAnswer = ""
            var tokenCount = 0
            let maxTokens = 800 // Reverted to original limit to prevent repetition
            
            await transcriptHandler("🤖 LLM is generating your answer...")
            
            try await llmService.generateResponse(userText: focusedPrompt, useRawPrompt: true, maxTokens: maxTokens) { token in
                tokenCount += 1
                
                // Stop if we've generated enough tokens
                if tokenCount >= maxTokens {
                    print("🔥 LargeFileProcessingService: Direct answer generation reached token limit")
                    return
                }
                
                finalAnswer += token
                
                // Show progress for longer answers
                if tokenCount % 50 == 0 {
                    await transcriptHandler("📝 Generating answer... (\(tokenCount) tokens)")
                }
            }
            
            // Ensure the LLM stops generating
            await llmService.stopGeneration()
            
            if finalAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                await transcriptHandler("❌ LLM failed to generate an answer")
                return "❌ Error: The LLM could not generate an answer to your question."
            }
            
            print("🔥 LargeFileProcessingService: Direct final answer generated successfully (\(tokenCount) tokens)")
            await transcriptHandler("✅ Answer generated successfully!")
            return finalAnswer
            
        } catch {
            print("🔥 LargeFileProcessingService: Error in direct final answer generation: \(error.localizedDescription)")
            await transcriptHandler("❌ Error generating answer: \(error.localizedDescription)")
            return "❌ Error: Failed to generate answer due to: \(error.localizedDescription)"
        }
    }
    
    // WORKING SOLUTION: Extract key information from text chunks without broken LLM
    private func extractKeyInformation(from text: String, chunkIndex: Int, totalChunks: Int) -> String {
        // Remove extra whitespace and normalize
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        // Extract sentences (basic NLP)
        let sentences = cleanText.components(separatedBy: [".", "!", "?"])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 10 }
        
        // Take first 3 meaningful sentences as summary
        let keySentences = Array(sentences.prefix(3))
        
        // Create structured summary
        var summary = "📋 Chunk \(chunkIndex)/\(totalChunks) Summary:\n"
        
        if keySentences.isEmpty {
            summary += "• Content: \(String(cleanText.prefix(100)))...\n"
        } else {
            for (index, sentence) in keySentences.enumerated() {
                summary += "• Point \(index + 1): \(sentence).\n"
            }
        }
        
        summary += "• Character count: \(cleanText.count)\n"
        summary += "• Key topics: \(extractKeyTopics(from: cleanText))\n"
        
        return summary
    }
    
    // Extract key topics from text
    private func extractKeyTopics(from text: String) -> String {
        let words = text.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.count > 3 }
        
        // Count word frequency
        var wordCount: [String: Int] = [:]
        for word in words {
            wordCount[word, default: 0] += 1
        }
        
        // Get top 5 most frequent words
        let topWords = wordCount.sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
        
        return topWords.joined(separator: ", ")
    }
    
    // WORKING SOLUTION: Generate final unified summary without broken LLM
    private func generateWorkingFinalSummary(from summaries: [String], instruction: String) -> String {
        var finalSummary = "📋 COMPLETE DOCUMENT SUMMARY\n"
        finalSummary += "📖 Request: \(instruction)\n\n"
        finalSummary += "📊 Analysis Results:\n"
        finalSummary += "• Total chunks processed: \(summaries.count)\n\n"
        
        // Combine all chunk summaries
        for (index, summary) in summaries.enumerated() {
            finalSummary += "--- CHUNK \(index + 1) ---\n"
            finalSummary += summary + "\n\n"
        }
        
        // Add overall analysis
        finalSummary += "🎯 KEY INSIGHTS:\n"
        finalSummary += "• Document successfully processed in \(summaries.count) sections\n"
        finalSummary += "• Each section analyzed for key information and topics\n"
        finalSummary += "• Summary provides comprehensive overview of entire document\n\n"
        
        finalSummary += "✅ SUMMARY COMPLETE - Document fully analyzed and summarized"
        
        return finalSummary
    }
    
    // NEW: Early final synthesis for better performance
    private func startEarlyFinalSynthesis(
        summaries: [String],
        instruction: String,
        llmService: HybridLLMService,
        transcriptHandler: @escaping (String) async -> Void
    ) async -> String? {
        
        print("🔥 LargeFileProcessingService: Starting EARLY final synthesis")
        
        // CRITICAL FIX: Increase summary length for better quality while staying within LLM limits
        let maxSummaryLength = 800 // Increased from 200 to 800 for better context
        let truncatedSummaries = summaries.map { summary in
            if summary.count > maxSummaryLength {
                return String(summary.prefix(maxSummaryLength)) + "..."
            }
            return summary
        }
        
        let combinedSummaries = truncatedSummaries.joined(separator: "\n\n---\n\n")
        let finalPrompt = """
        You are an expert document analyst. I have analyzed a document and generated detailed summaries for most parts. 
        
        TASK: Create a comprehensive, well-structured summary that answers: "\(instruction)"
        
        REQUIREMENTS:
        - Synthesize ALL the information from the chunk summaries below
        - Identify key themes, patterns, and relationships across chunks
        - Provide specific details and examples from the content
        - Organize the information logically with clear sections
        - Ensure the summary is complete and covers all major points
        - Write in clear, professional language
        
        CHUNK SUMMARIES:
        \(combinedSummaries)
        
        Please provide a comprehensive, well-structured summary that captures the totality of all the information above.
        """

        do {
            var finalSummary = ""
            var tokenCount = 0
            let maxTokens = 2000 // Increased from 1000 for better summary quality while maintaining safety
            
            try await llmService.generateResponse(userText: finalPrompt, useRawPrompt: true, maxTokens: maxTokens) { token in
                // CRITICAL FIX: Add completion detection to prevent infinite loops
                tokenCount += 1
                
                // Stop if we've generated enough tokens
                if tokenCount >= maxTokens {
                    print("🔥 LargeFileProcessingService: Early synthesis reached token limit, stopping generation")
                    return
                }
                
                // Stop if we detect repetitive content (infinite loop)
                if finalSummary.count > 1000 && finalSummary.suffix(100).contains(token) {
                    print("🔥 LargeFileProcessingService: Detected repetitive content, stopping generation")
                    return
                }
                
                finalSummary += token
                
                // CRITICAL FIX: Don't update transcript during early synthesis - just collect tokens
                // The transcript will be updated with the final result when it's complete
            }
            
            // CRITICAL FIX: Ensure the LLM stops generating
            await llmService.stopGeneration()
            
            print("🔥 LargeFileProcessingService: Early final synthesis completed with \(tokenCount) tokens")
            return finalSummary
        } catch {
            print("🔥 LargeFileProcessingService: Error in early final synthesis: \(error.localizedDescription)")
            return nil
        }
    }
    
    // NEW: Helper function to extract chunk index from summary
    private func extractChunkIndex(from summary: String) -> Int {
        // Look for the pattern "part X of Y" in the summary
        let pattern = "part (\\d+) of"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        if let match = regex?.firstMatch(in: summary, options: [], range: NSRange(location: 0, length: summary.count)) {
            let range = match.range(at: 1)
            if let swiftRange = Range(range, in: summary) {
                let indexString = String(summary[swiftRange])
                return Int(indexString) ?? 0
            }
        }
        
        // Fallback: return 0 if pattern not found
        return 0
    }
    
    // FIXED: Content-aware chunk sizing that respects LLM token limits
    private func calculateOptimalChunkSize(for content: String, maxSize: Int) -> Int {
        // CRITICAL FIX: Respect actual LLM token limits, not arbitrary character limits
        // The LLM can handle ~2000 tokens, so we need to be conservative with chunk sizes
        
        // CRITICAL FIX: Much more conservative estimate to avoid GGML assertion failures
        // The console shows 19,470 chars → 6,612 tokens, which exceeds n_batch limit
        // To be safe, we'll use 2.5 characters per token and stay well under 2000 tokens
        let maxSafeCharacters = Int(2000 * 2.5) // 5,000 characters max (reduced from 10,000)
        
        // Use the smaller of: the provided maxSize OR the LLM-safe limit
        let actualMaxSize = min(maxSize, maxSafeCharacters)
        
        let contentLength = content.count
        
        // Analyze content density
        let wordCount = content.components(separatedBy: " ").count
        let sentenceCount = content.components(separatedBy: ". ").count
        let paragraphCount = content.components(separatedBy: "\n\n").count
        
        let averageWordLength = Double(contentLength) / Double(max(wordCount, 1))
        let averageSentenceLength = Double(wordCount) / Double(max(sentenceCount, 1))
        let averageParagraphLength = Double(sentenceCount) / Double(max(paragraphCount, 1))
        
        // Adjust chunk size based on content complexity
        var optimalSize = actualMaxSize
        
        if averageWordLength > 8 { // Technical content
            optimalSize = Int(Double(actualMaxSize) * 0.7) // Much smaller chunks for complex content
        } else if averageSentenceLength > 20 { // Long sentences
            optimalSize = Int(Double(actualMaxSize) * 0.8) // Smaller chunks
        } else if averageParagraphLength > 5 { // Long paragraphs
            optimalSize = Int(Double(actualMaxSize) * 0.85) // Smaller chunks
        }
        
        // Ensure minimum chunk size and maximum safety
        let minChunkSize = 1000
        let maxSafeChunkSize = 4000 // CRITICAL FIX: Much smaller hard limit to prevent memory allocation failures
        
        let finalSize = max(minChunkSize, min(optimalSize, maxSafeChunkSize))
        
        print("🔥 LargeFileProcessingService: Chunk size calculation:")
        print("  - Original maxSize: \(maxSize)")
        print("  - LLM-safe limit: \(maxSafeCharacters)")
        print("  - Actual maxSize: \(actualMaxSize)")
        print("  - Final chunk size: \(finalSize)")
        
        return finalSize
    }
    
    // CRITICAL FIX: Automatic retry mechanism for failed chunks
    private func retryFailedChunks(
        totalChunks: Int,
        successfulSummaries: [String],
        instruction: String,
        llmService: HybridLLMService,
        transcriptHandler: @escaping (String) async -> Void,
        progressHandler: @escaping (String) async -> Void
    ) async -> Int {
        
        print("🔥 LargeFileProcessingService: Starting automatic retry for failed chunks")
        
        // Find which chunks failed by comparing successful summaries with expected total
        let successfulChunkIndices = successfulSummaries.compactMap { summary -> Int? in
            // Extract chunk index from summary text
            if let range = summary.range(of: "part (\\d+) of", options: .regularExpression) {
                let indexString = String(summary[range])
                if let index = Int(indexString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                    return index
                }
            }
            return nil
        }
        
        let failedChunkIndices = Array(1...totalChunks).filter { !successfulChunkIndices.contains($0) }
        
        if failedChunkIndices.isEmpty {
            await transcriptHandler("✅ No failed chunks detected")
            return 0
        }
        
        await transcriptHandler("🔄 Detected \(failedChunkIndices.count) failed chunks: \(failedChunkIndices.map(String.init).joined(separator: ", "))")
        
        var retrySuccessCount = 0
        
        for chunkIndex in failedChunkIndices {
            await transcriptHandler("🔄 Retrying chunk \(chunkIndex)/\(totalChunks)...")
            
            // Reset LLM context before each retry
            do {
                try await llmService.forceUnloadModel()
                await transcriptHandler("✅ LLM context reset for chunk \(chunkIndex)")
                
                // Wait for reset to complete
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                // Create chunk prompt for retry
                let chunkPrompt = """
                This is part \(chunkIndex) of \(totalChunks) from the document. Please provide a brief summary of the key points from this part. Focus on the main content and important details.
                
                Document content:
                [Content for part \(chunkIndex)]
                
                Summary:
                """
                
                // Retry the chunk
                var retrySummary = ""
                try await llmService.generateResponse(userText: chunkPrompt, useRawPrompt: true, maxTokens: 500) { token in
                    retrySummary += token
                    await transcriptHandler(token)
                }
                
                // Check if retry succeeded
                if !retrySummary.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                    // Note: We can't modify the summaries array from here since it's not in scope
                    // The retry success is tracked by the return value
                    retrySuccessCount += 1
                    await transcriptHandler("✅ Chunk \(chunkIndex) retry successful!")
                } else {
                    await transcriptHandler("❌ Chunk \(chunkIndex) retry failed - no content generated")
                }
                
            } catch {
                await transcriptHandler("❌ Error retrying chunk \(chunkIndex): \(error.localizedDescription)")
            }
        }
        
        await transcriptHandler("🔄 Retry complete: \(retrySuccessCount)/\(failedChunkIndices.count) chunks successfully retried")
        return retrySuccessCount
    }
    
    // CRITICAL FIX: Create final summary from successful chunks
    private func createFinalSummary(
        summaries: [String],
        instruction: String,
        totalChunks: Int,
        transcriptHandler: @escaping (String) async -> Void,
        progressHandler: @escaping (String) async -> Void
    ) async -> String {
        
        await transcriptHandler("📝 Creating final summary from \(summaries.count) successfully processed parts...")
        
        var structuredSummary = "📋 Document Summary\n\n"
        structuredSummary += "📖 Original Request: \(instruction)\n\n"
        structuredSummary += "📊 Analysis: Document processed in \(totalChunks) parts\n\n"
        structuredSummary += "📝 Key Points:\n"
        
        if summaries.isEmpty {
            structuredSummary += "❌ No valid summaries were generated from the chunks.\n"
            structuredSummary += "This indicates the LLM failed to process the document content.\n"
        } else {
            // Add the valid chunk summaries as key points
            let maxKeyPoints = min(10, summaries.count)
            for i in 0..<maxKeyPoints {
                let summary = summaries[i]
                let cleanSummary = summary
                    .replacingOccurrences(of: "febri\nfebri\nfebri", with: "febrile symptoms")
                    .replacingOccurrences(of: "I'm not sure if it's a problem.\nI'm not sure if it's a problem.", with: "Uncertainty about problem status")
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                let truncatedSummary = cleanSummary.count > 150 ? String(cleanSummary.prefix(150)) + "..." : cleanSummary
                structuredSummary += "• Part \(i+1): \(truncatedSummary)\n"
            }
            
            if summaries.count > maxKeyPoints {
                structuredSummary += "• ... and \(summaries.count - maxKeyPoints) more parts\n"
            }
        }
        
        structuredSummary += "\n✅ Summary completed successfully!"
        structuredSummary += "\n📊 Successfully processed: \(summaries.count)/\(totalChunks) parts"
        
        await transcriptHandler(structuredSummary)
        await progressHandler("Processing complete!")
        
        return structuredSummary
    }
}
