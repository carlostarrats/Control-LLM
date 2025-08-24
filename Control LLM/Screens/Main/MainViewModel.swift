import Foundation
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    @Published var lastMessage: String?
    @Published var messages: [ChatMessage] = []
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
        
        // Trigger the LLM response through ChatViewModel
        Task {
            do {
                try await llm.send(text)
            } catch {
                print("❌ MainViewModel: Error calling LLM: \(error)")
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
        let prompt = "Analyze this text (keep under 8000 tokens): \(text)"
        
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