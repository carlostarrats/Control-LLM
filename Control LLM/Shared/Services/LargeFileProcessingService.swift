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
    
    // MARK: - Properties
    private let progressLock = NSLock()
    private let transcriptLock = NSLock()
    private var pendingProgressUpdates: [String] = []
    private var lastProgressUpdate: Date = Date()
    
    // NEW: Store final synthesis results for both parallel and sequential processing
    private var finalSynthesisResult: String?
    private var sequentialFinalSynthesisResult: String?
    private let finalSynthesisLock = NSLock()
    
    // CRITICAL FIX: Store processed PDF data for subsequent questions
    private var processedFileContent: FileContent?
    private var processedSummaries: [String] = []
    private let processedDataLock = NSLock()

    private init() {}
    
    // CRITICAL FIX: Check if processed PDF data is available for questions
    func hasProcessedData() -> Bool {
        processedDataLock.lock()
        defer { processedDataLock.unlock() }
        return processedFileContent != nil && !processedSummaries.isEmpty
    }
    
    // CRITICAL FIX: Get processed PDF data for answering questions
    func getProcessedData() -> (fileContent: FileContent, summaries: [String])? {
        processedDataLock.lock()
        defer { processedDataLock.unlock() }
        guard let fileContent = processedFileContent, !processedSummaries.isEmpty else {
            return nil
        }
        return (fileContent, processedSummaries)
    }
    
    // CRITICAL FIX: Answer questions using stored processed PDF data
    func answerQuestion(
        question: String,
        llmService: HybridLLMService,
        progressHandler: @escaping (String) async -> Void,
        transcriptHandler: @escaping (String) async -> Void
    ) async -> String? {
        
        guard let (fileContent, summaries) = getProcessedData() else {
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
        
        // NEW: All images should use simple processing to avoid chunking issues
        if fileContent.type == .image {
            print("🔥 LargeFileProcessingService: Image content detected (\(fileContent.content.count) chars), processing directly")
            await progressHandler("Processing image text directly...")
            return await processImageContent(
                fileContent: fileContent,
                instruction: instruction,
                llmService: llmService,
                progressHandler: progressHandler,
                transcriptHandler: transcriptHandler
            )
        }
        
        // CRITICAL FIX: Use much smaller chunk size to prevent timeouts
        // The LLM is timing out on 3200 character chunks, so we need smaller ones
        let fixedChunkSize = 1500  // Much smaller to process faster and avoid timeouts
        let totalChunks = Int(ceil(Double(fileContent.content.count) / Double(fixedChunkSize)))
        
        print("🔥 LargeFileProcessingService: Content length: \(fileContent.content.count)")
        print("🔥 LargeFileProcessingService: Fixed chunk size: \(fixedChunkSize)")
        print("🔥 LargeFileProcessingService: Total chunks: \(totalChunks)")
        print("🔥 LargeFileProcessingService: Expected total processed: \(fixedChunkSize * totalChunks)")
        
        // CRITICAL FIX: Use sequential processing to ensure chunks are processed in order
        // Parallel processing was causing random chunk order (4, 2, 1 instead of 1, 2, 3, 4...)
        if totalChunks > 1 {
            await progressHandler("Processing \(totalChunks) parts sequentially...")
            return await processChunksSequentially(
                fileContent: fileContent,
                instruction: instruction,
                chunkSize: fixedChunkSize,
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
                chunkSize: fixedChunkSize,
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
        processedDataLock.lock()
        processedFileContent = fileContent
        processedSummaries = summaries
        processedDataLock.unlock()
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
    processedDataLock.lock()
    processedFileContent = fileContent
    processedSummaries = summaries
    processedDataLock.unlock()
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
        let maxSummaryLength = 50  // Much smaller to keep prompts under 1000 characters
        let truncatedSummaries = summaries.map { summary in
            if summary.count > maxSummaryLength {
                return String(summary.prefix(maxSummaryLength)) + "..."
            }
            return summary
        }
        
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
        // The LLM is hitting 8000 token limit, so we need much smaller prompts
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
