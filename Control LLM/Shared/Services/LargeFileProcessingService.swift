import Foundation

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

    private init() {}

    func process(
        fileContent: FileContent,
        instruction: String,
        maxContentLength: Int,
        llmService: HybridLLMService,
        progressHandler: @escaping (String) async -> Void,
        transcriptHandler: @escaping (String) async -> Void
    ) async -> String? {
        
        print("🔥 LargeFileProcessingService: Starting process for file '\(fileContent.fileName)'")
        print("🔥 LargeFileProcessingService: Content length: \(fileContent.content.count) characters")
        print("🔥 LargeFileProcessingService: Max content length: \(maxContentLength)")
        print("🔥 LargeFileProcessingService: Instruction: '\(instruction)'")
        
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
        
        // CRITICAL FIX: Account for prompt overhead AND memory constraints in chunk sizing
        // The actual prompt includes instruction text + formatting, so we need smaller chunks
        // Also need to account for LLM memory limitations to prevent allocation failures
        let promptOverhead = 500  // Account for instruction text and formatting
        let memorySafeLimit = 4000  // Reduce from 10000 to 4000 to prevent memory allocation failures
        let optimalChunkSize = calculateOptimalChunkSize(for: fileContent.content, maxSize: min(maxContentLength - 1500 - promptOverhead, memorySafeLimit))
        let totalChunks = Int(ceil(Double(fileContent.content.count) / Double(optimalChunkSize)))
        
        print("🔥 LargeFileProcessingService: Optimal chunk size: \(optimalChunkSize), Total chunks: \(totalChunks)")
        
        // NEW: Use parallel processing for better performance
        if totalChunks > 1 {
            await progressHandler("Processing \(totalChunks) parts simultaneously...")
            return await processChunksInParallel(
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
    
    // NEW: Parallel processing implementation
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
                        
                        let startIndex = (chunkIndex - 1) * chunkSize
                        let endIndex = min(startIndex + chunkSize, fileContent.content.count)
                        let chunk = String(fileContent.content[fileContent.content.index(fileContent.content.startIndex, offsetBy: startIndex)..<fileContent.content.index(fileContent.content.startIndex, offsetBy: endIndex)])
                        
                        let chunkPrompt = """
                        This is part \(chunkIndex) of \(totalChunks) from the document '\(fileContent.fileName)'.
                        Summarize the key points from ONLY this part of the document. Do not mention that this is a part of a larger document. Focus only on the content provided below:

                        --- PART \(chunkIndex)/\(totalChunks) CONTENT ---
                        \(chunk)
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
                                
                                try await llmService.generateResponse(userText: chunkPrompt, useRawPrompt: true) { token in
                                    chunkSummary += token
                                    // CRITICAL FIX: Make transcript updates actually different each time
                                    // Show real progress with unique content to ensure UI updates
                                    if chunkSummary.count % 10 == 0 {
                                        let progress = chunkSummary.count
                                        // Calculate percentage based on actual chunk size that was created
                                        let actualChunkSize = chunk.count
                                        let percentage = min(100, Int((Double(progress) / Double(actualChunkSize)) * 100))
                                        await transcriptHandler("Processing chunk \(chunkIndex)/\(totalChunks)... \(progress)/\(actualChunkSize) characters (\(percentage)% complete)")
                                    }
                                }
                                
                                // CRITICAL FIX: Show when chunk actually completes
                                await transcriptHandler("✅ Chunk \(chunkIndex)/\(totalChunks) completed!")
                            } catch {
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
                                    
                                    // NEW: Start early synthesis when threshold is reached
                                    if currentCompleted >= synthesisThreshold && !earlySynthesisStarted {
                                        earlySynthesisStarted = true
                                        await progressHandler("Most parts analyzed. Starting final synthesis...")
                                        
                                        // Start final synthesis in background
                                        Task {
                                            if summaries.count == totalChunks {
                                                await startEarlyFinalSynthesis(
                                                    summaries: summaries,
                                                    instruction: instruction,
                                                    llmService: llmService,
                                                    transcriptHandler: transcriptHandler
                                                )
                                            }
                                        }
                                    }
                                    
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
        
        // Create final synthesis
        return await createFinalSynthesis(
            summaries: summaries,
            instruction: instruction,
            totalChunks: totalChunks,
            llmService: llmService,
            transcriptHandler: transcriptHandler,
            progressHandler: progressHandler
        )
    }
    
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
            
            let startIndex = (chunkIndex - 1) * chunkSize
            let endIndex = min(startIndex + chunkSize, fileContent.content.count)
            let chunk = String(fileContent.content[fileContent.content.index(fileContent.content.startIndex, offsetBy: startIndex)..<fileContent.content.index(fileContent.content.startIndex, offsetBy: endIndex)])
            
            let chunkPrompt = """
            This is part \(chunkIndex) of \(totalChunks) from the document '\(fileContent.fileName)'.
            Summarize the key points from ONLY this part of the document. Do not mention that this is a part of a larger document. Focus only on the content provided below:

            --- PART \(chunkIndex)/\(totalChunks) CONTENT ---
            \(chunk)
            """

                do {
                    var chunkSummary = ""
                                                                         try await llmService.generateResponse(userText: chunkPrompt, useRawPrompt: true) { token in
                     chunkSummary += token
                     // CRITICAL FIX: Make transcript updates actually different each time
                     // Show real progress with unique content to ensure UI updates
                     if chunkSummary.count % 10 == 0 {
                         let progress = chunkSummary.count
                         // Calculate percentage based on actual chunk size, not arbitrary 1000
                         let chunkSize = chunkSize // Use the chunkSize parameter passed to this function
                         let percentage = min(100, Int((Double(progress) / Double(chunkSize)) * 100))
                         await transcriptHandler("Processing chunk \(chunkIndex)/\(totalChunks)... \(progress)/\(chunkSize) characters (\(percentage)% complete)")
                     }
                 }
                    summaries.append(chunkSummary)
                } catch {
                    let errorMessage = "Error processing part \(chunkIndex)/\(totalChunks): \(error.localizedDescription)"
                    await progressHandler("Error: Processing failed.")
                    return nil  // Return nil on failure, not the error message
                }

            // Give the UI a moment to update
            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds (4x less frequent for better performance)
        }
        
        // Create final synthesis
        return await createFinalSynthesis(
            summaries: summaries,
            instruction: instruction,
            totalChunks: totalChunks,
            llmService: llmService,
            transcriptHandler: transcriptHandler,
            progressHandler: progressHandler
        )
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
        
        let combinedSummaries = summaries.joined(separator: "\n\n---\n\n")
        let finalPrompt = """
        I have analyzed a document in \(totalChunks) parts and generated a summary for each part. Now, please synthesize these individual summaries into a single, cohesive final summary that answers the user's original question: "\(instruction)"

        Here are the summaries of the parts:
        \(combinedSummaries)

        Please provide the final, synthesized answer.
        """

        do {
            print("🔥 LargeFileProcessingService: Starting final LLM call with prompt length: \(finalPrompt.count)")
            print("🔥 LargeFileProcessingService: Final prompt content: '\(finalPrompt)'")
            
            // CRITICAL FIX: Collect the final summary text instead of just streaming to transcript
            var finalSummary = ""
            try await llmService.generateResponse(userText: finalPrompt, useRawPrompt: true) { token in
                print("🔥 LargeFileProcessingService: Received token: '\(token)'")
                finalSummary += token
                // Still update transcript for real-time feedback
                await transcriptHandler(token)
            }
            
            print("🔥 LargeFileProcessingService: Final LLM call completed successfully")
            await progressHandler("Processing complete!")
            
            // CRITICAL FIX: Return the actual summary text, not just "SUCCESS"
            return finalSummary
        } catch {
            let errorMessage = "Error creating final summary: \(error.localizedDescription)"
            print("🔥 LargeFileProcessingService: Error in final LLM call: \(errorMessage)")
            await progressHandler("Error: Processing failed.")
            return errorMessage
        }
    }
    
    // NEW: Early final synthesis for better performance
    private func startEarlyFinalSynthesis(
        summaries: [String],
        instruction: String,
        llmService: HybridLLMService,
        transcriptHandler: @escaping (String) async -> Void
    ) async {
        
        print("🔥 LargeFileProcessingService: Starting EARLY final synthesis")
        
        let combinedSummaries = summaries.joined(separator: "\n\n---\n\n")
        let finalPrompt = """
        I have analyzed a document and generated summaries for most parts. Please synthesize these summaries into a cohesive answer to: "\(instruction)"

        Here are the summaries:
        \(combinedSummaries)

        Please provide a comprehensive answer based on the available information.
        """

        do {
            try await llmService.generateResponse(userText: finalPrompt, useRawPrompt: true) { token in
                await transcriptHandler(token)
            }
            print("🔥 LargeFileProcessingService: Early final synthesis completed")
        } catch {
            print("🔥 LargeFileProcessingService: Error in early final synthesis: \(error.localizedDescription)")
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
        // The LLM can handle ~8000 tokens, so we need to be conservative with chunk sizes
        
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
}
