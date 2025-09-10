import Foundation
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    @Published var lastMessage: String?
    @Published var messages: [ChatMessage] = []
    @Published var selectedFileUrl: URL?
    @Published var isFileProcessing: Bool = false
    @Published var fileProcessingError: String? = nil
    @Published var shouldNavigateToChat = false
    @Published var pendingClipboardPrompt: String?
    
    // Add ChatViewModel instance for LLM operations
    let llm = ChatViewModel()
    
    // Clipboard processing
    private var clipboardObserver: NSObjectProtocol?
    private var isProcessingClipboard = false
    
    // PDF processing task cancellation
    private var currentFileProcessingTask: Task<Void, Never>?
    
    // All voice functionality removed
    
    // Speaking functionality removed
    
    func sendTextMessage(_ text: String) async {
        
        // Create user message immediately for UI display
        let userMessage = ChatMessage(
            content: text,
            isUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        
        // PERFORMANCE FIX: Batch UI updates to reduce main thread blocking
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
        
        // CRITICAL FIX: Check if there's processed PDF data available for questions
        if await LargeFileProcessingService.shared.hasProcessedData() {
            
            // Answer the question using stored processed data
            Task {
                let result = await LargeFileProcessingService.shared.answerQuestion(
                    question: text,
                    llmService: HybridLLMService.shared,
                    progressHandler: { [self] progressMessage in
                        // CRITICAL FIX: Show progress to user in the transcript
                        llm.transcript = progressMessage
                    },
                                            transcriptHandler: { [self] transcript in
                            // CRITICAL FIX: Batch transcript updates to prevent UI refresh loops
                            // Only update every 10 characters to reduce UI refreshes
                            if transcript.count % 10 == 0 || transcript.hasSuffix(".") || transcript.hasSuffix("!") || transcript.hasSuffix("?") {
                                llm.transcript = transcript
                            }
                        }
                )
                
                if let result = result {
                    // Add the answer to messages
                    let answerMessage = ChatMessage(
                        content: result,
                        isUser: false,
                        timestamp: Date()
                    )
                    
                    await MainActor.run {
                        messages.append(answerMessage)
                    }
                } else {
                    // Add error message
                    let errorMessage = ChatMessage(
                        content: "❌ Failed to answer question using processed PDF data",
                        isUser: false,
                        timestamp: Date()
                    )
                    
                    await MainActor.run {
                        messages.append(errorMessage)
                    }
                }
            }
            return
        }
        
        // Check if there's a file to process
        if let fileUrl = selectedFileUrl {
            
            // Set file processing state
            isFileProcessing = true
            fileProcessingError = nil
            
            // CRITICAL FIX: Also set LLM processing state so input box shows "Generating response..."
            llm.isProcessing = true
            
            // Process the file through LargeFileProcessingService
            currentFileProcessingTask = Task {
                do {
                    // Check if task was cancelled before starting
                    if Task.isCancelled {
                        return
                    }
                    
                    // Extract the file content using FileProcessingService (already returns FileContent)
                    let fileContent = try await FileProcessingService.shared.processFile(fileUrl)
                    
                    // Check if task was cancelled after file extraction
                    if Task.isCancelled {
                        return
                    }
                    
                    // Process with LargeFileProcessingService (returns String?, not throwing)
                    let result = await LargeFileProcessingService.shared.process(
                        fileContent: fileContent,
                        instruction: text,
                        maxContentLength: 1000000,
                        llmService: HybridLLMService.shared,
                        progressHandler: { [self] progressMessage in
                            // Show progress in a separate area, not transcript
                            await MainActor.run {
                                // Create a progress message that doesn't overwrite user input
                                let progressMessage = ChatMessage(
                                    content: "🔄 \(progressMessage)",
                                    isUser: false,
                                    timestamp: Date()
                                )
                                messages.append(progressMessage)
                            }
                        },
                        transcriptHandler: { [self] transcript in
                            // CRITICAL FIX: Actually update the transcript that TextModalView is polling
                            // MainViewModel is already @MainActor, so no need for Task wrapper
                            // CRITICAL FIX: Batch transcript updates to prevent UI refresh loops
                            // Only update every 10 characters to reduce UI refreshes
                            if transcript.count % 10 == 0 || transcript.hasSuffix(".") || transcript.hasSuffix("!") || transcript.hasSuffix("?") {
                                llm.transcript = transcript
                            }
                        }
                    )
                    
                    // Check if task was cancelled after processing
                    if Task.isCancelled {
                        return
                    }
                    
                    
                    // Check if processing failed
                    if result == nil {
                        
                        // Set error state
                        isFileProcessing = false
                        fileProcessingError = "Processing failed - no result returned"
                        // CRITICAL FIX: Reset LLM processing state on failure
                        llm.isProcessing = false
                        // CRITICAL FIX: DO NOT clear transcript on failure - keep any partial content
                        
                        
                        // Send error message to user
                        let errorMessage = ChatMessage(
                            content: "❌ Error processing file: Processing failed - no result returned",
                            isUser: false,
                            timestamp: Date()
                        )
                        
                        messages.append(errorMessage)
                        
                        // Clean up task reference
                        currentFileProcessingTask = nil
                    } else {
                        // Processing succeeded - add the result to messages
                        
                        // Add the result to chat messages
                        let resultMessage = ChatMessage(
                            content: result ?? "No content generated",
                            isUser: false,
                            timestamp: Date()
                        )
                        
                        // CRITICAL FIX: MainViewModel is already @MainActor, no need for await MainActor.run
                        messages.append(resultMessage)
                        isFileProcessing = false
                        fileProcessingError = nil
                        // CRITICAL FIX: Reset LLM processing state
                        llm.isProcessing = false
                        // CRITICAL FIX: DO NOT clear transcript - keep generated content
                        // Clear the file URL after processing
                        selectedFileUrl = nil
                        
                        
                        // Clean up task reference
                        currentFileProcessingTask = nil
                    }
                    
                } catch {
                    
                    // Set error state
                    isFileProcessing = false
                    fileProcessingError = error.localizedDescription
                    // CRITICAL FIX: Reset LLM processing state on error
                    llm.isProcessing = false
                    // CRITICAL FIX: DO NOT clear transcript on error - keep any partial content
                    
                    
                    // Send error message to user
                    let errorMessage = ChatMessage(
                        content: "❌ Error processing file: \(error.localizedDescription)",
                        isUser: false,
                        timestamp: Date()
                    )
                    
                    messages.append(errorMessage)
                    
                    // Clean up task reference
                    currentFileProcessingTask = nil
                }
            }
        } else {
            // No file, just send text as normal
            
            // CRITICAL FIX: LLM processing state is now set in TextModalView before calling this function
            
            Task {
                do {
                    try await llm.send(text)
                    // CRITICAL FIX: Reset processing state but DO NOT clear transcript after LLM completes
                    llm.isProcessing = false
                    // CRITICAL FIX: Keep transcript content visible for user
                } catch {
                    // CRITICAL FIX: Reset processing state but DO NOT clear transcript on error
                    llm.isProcessing = false
                    // CRITICAL FIX: Keep any partial content visible
                }
            }
        }
        
        donateChainedMessageIntentIfNeeded()
    }
    
    // Chat session saving functionality removed
    
    func clearMessages() {
        messages.removeAll()
    }
    
    // MARK: - PDF Processing Cancellation
    
    func cancelFileProcessing() {
        
        // Cancel the PDF processing task
        currentFileProcessingTask?.cancel()
        currentFileProcessingTask = nil
        
        // Reset UI state
        isFileProcessing = false
        fileProcessingError = nil
        llm.isProcessing = false
        // CRITICAL FIX: DO NOT clear transcript - keep generated content visible
        selectedFileUrl = nil
        
    }
    
    // MARK: - Clipboard Processing
    
    func setupClipboardProcessingObserver() {
        // Remove any existing observer first
        if let observer = clipboardObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
                clipboardObserver = NotificationCenter.default.addObserver(
            forName: .processClipboardText,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let clipboardText = notification.object as? String {
                Task { @MainActor in
                    self?.handleClipboardTextProcessing(clipboardText)
                }
            }
        }
}
    
    func cleanupClipboardObserver() {
        if let observer = clipboardObserver {
            NotificationCenter.default.removeObserver(observer)
            clipboardObserver = nil
        }
    }
    
    deinit {
        // PERFORMANCE FIX: Clean up resources without main actor isolation
        if let observer = clipboardObserver {
            NotificationCenter.default.removeObserver(observer)
            clipboardObserver = nil
        }
        currentFileProcessingTask?.cancel()
        currentFileProcessingTask = nil
    }
    
    private func handleClipboardTextProcessing(_ text: String) {
        // Prevent multiple simultaneous clipboard processing calls
        guard !isProcessingClipboard else {
            return
        }
        
        isProcessingClipboard = true
        
        // Create the analysis prompt (focused on analysis only, not summary)
        let prompt = String(format: NSLocalizedString("Analyze this text (keep under 2000 tokens): %@", comment: ""), text)
        
        // Set pending prompt for TextModalView to process and trigger navigation
        DispatchQueue.main.async {
            self.pendingClipboardPrompt = prompt
            self.shouldNavigateToChat = true
            self.isProcessingClipboard = false
        }
    }
    
    // Auto-save functionality removed

    private func donateChainedMessageIntentIfNeeded() {
        // A "chain" is at least two back-and-forth exchanges (user -> assistant -> user -> assistant)
        let chainThreshold = 4
        
        // Ensure there are enough messages to form a chain
        guard messages.count >= chainThreshold else { return }
        
        // Check if the last `chainThreshold` messages form a valid chain
        let recentMessages = Array(messages.suffix(chainThreshold))
        
        var isChain = true
        for (index, message) in recentMessages.enumerated() {
            // User messages should be at even indices (0, 2), assistant at odd (1, 3)
            if (index % 2 == 0 && !message.isUser) || (index % 2 != 0 && message.isUser) {
                isChain = false
                break
            }
        }
        
        if isChain {
            let messageContents = recentMessages.map { $0.content }
            ShortcutsIntegrationHelper.shared.donateMessagesChained(messages: messageContents)
        }
    }
}

enum MessageType: Codable {
    case text
    case file
    case error
}

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: String
    var content: String
    let isUser: Bool
    let timestamp: Date
    let messageType: MessageType
    
    init(content: String, isUser: Bool, timestamp: Date, messageType: MessageType = .text) {
        self.id = UUID().uuidString
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.messageType = messageType
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let processClipboardText = Notification.Name("processClipboardText")
    static let startStreamingForClipboardMessage = Notification.Name("startStreamingForClipboardMessage")
}