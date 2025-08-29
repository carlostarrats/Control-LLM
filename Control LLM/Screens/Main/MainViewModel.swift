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
    
    // All voice functionality removed
    
    // Speaking functionality removed
    
    func sendTextMessage(_ text: String) {
        print("🔍 MainViewModel: sendTextMessage called with text: \(text.prefix(50))...")
        print("🔍 MainViewModel: Current messages count: \(messages.count)")
        
        // Create user message immediately for UI display
        let userMessage = ChatMessage(
            content: text,
            isUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        print("🔍 MainViewModel: User message added. New count: \(messages.count)")
        
        // Force UI update to show user message immediately
        DispatchQueue.main.async {
            // Trigger UI refresh
            self.objectWillChange.send()
        }
        
        // Check if there's a file to process
        if let fileUrl = selectedFileUrl {
            print("🔍 MainViewModel: File detected, processing with LargeFileProcessingService")
            
            // Set file processing state
            isFileProcessing = true
            fileProcessingError = nil
            
            // Process the file through LargeFileProcessingService
            Task {
                do {
                    // Extract the file content using FileProcessingService (already returns FileContent)
                    let fileContent = try await FileProcessingService.shared.processFile(fileUrl)
                    
                    // Process with LargeFileProcessingService (returns String?, not throwing)
                    let result = await LargeFileProcessingService.shared.process(
                        fileContent: fileContent,
                        instruction: text,
                        maxContentLength: 1000000,
                        llmService: HybridLLMService.shared,
                        progressHandler: { progressMessage in
                            print("🔍 MainViewModel: Progress: \(progressMessage)")
                        },
                        transcriptHandler: { [self] transcript in
                            print("🔍 MainViewModel: Transcript: \(transcript)")
                            // CRITICAL FIX: Actually update the transcript that TextModalView is polling
                            // MainViewModel is already @MainActor, so no need for Task wrapper
                            llm.transcript = transcript
                        }
                    )
                    
                    print("🔍 MainViewModel: File processing completed with result: \(result ?? "nil")")
                    
                    // Check if processing failed
                    if result == nil {
                        print("❌ MainViewModel: File processing failed - result is nil")
                        
                        // Set error state
                        await MainActor.run {
                            isFileProcessing = false
                            fileProcessingError = "Processing failed - no result returned"
                        }
                        
                        // Send error message to user
                        let errorMessage = ChatMessage(
                            content: "❌ Error processing file: Processing failed - no result returned",
                            isUser: false,
                            timestamp: Date()
                        )
                        
                        await MainActor.run {
                            messages.append(errorMessage)
                        }
                    } else {
                        // Processing succeeded
                        print("✅ MainViewModel: File processing succeeded")
                        
                        // Clear the file URL after processing
                        selectedFileUrl = nil
                        
                        // Reset file processing state
                        await MainActor.run {
                            isFileProcessing = false
                            fileProcessingError = nil
                        }
                    }
                    
                } catch {
                    print("❌ MainViewModel: Error in FileProcessingService: \(error)")
                    
                    // Set error state
                    await MainActor.run {
                        isFileProcessing = false
                        fileProcessingError = error.localizedDescription
                    }
                    
                    // Send error message to user
                    let errorMessage = ChatMessage(
                        content: "❌ Error processing file: \(error.localizedDescription)",
                        isUser: false,
                        timestamp: Date()
                    )
                    
                    await MainActor.run {
                        messages.append(errorMessage)
                    }
                }
            }
        } else {
            // No file, just send text as normal
            print("🔍 MainViewModel: No file detected, sending text normally")
            
            Task {
                do {
                    try await llm.send(text)
                } catch {
                    print("❌ MainViewModel: Error calling LLM: \(error)")
                }
            }
        }
        
        donateChainedMessageIntentIfNeeded()
    }
    
    // Chat session saving functionality removed
    
    func clearMessages() {
        messages.removeAll()
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
    
    private func handleClipboardTextProcessing(_ text: String) {
        // Prevent multiple simultaneous clipboard processing calls
        guard !isProcessingClipboard else {
            print("🔍 MainViewModel: Clipboard processing already in progress, ignoring duplicate call")
            return
        }
        
        isProcessingClipboard = true
        print("🔍 MainViewModel: handleClipboardTextProcessing called with text: \(text.prefix(100))...")
        
        // Create the analysis prompt (focused on analysis only, not summary)
        let prompt = String(format: NSLocalizedString("Analyze this text (keep under 8000 tokens): %@", comment: ""), text)
        
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