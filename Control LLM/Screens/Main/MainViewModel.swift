import Foundation
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    @Published var lastMessage: String?
    @Published var messages: [ChatMessage] = []
    @Published var shouldNavigateToChat = false
    @Published var pendingClipboardPrompt: String?
    
    // Link to the ChatViewModel for LLM operations and persistence
    let llm = ChatViewModel()
    
    // Clipboard processing
    private var clipboardObserver: NSObjectProtocol?
    private var isProcessingClipboard = false
    
    init() {
        // When the app starts, load the persisted message history
        print("🔍 MainViewModel: init - Loading persisted messages...")
        loadPersistedMessages()
    }
    
    private func loadPersistedMessages() {
        // The actual history is in ChatViewModel's messageHistory, which is loaded from UserDefaults.
        // We sync it to our local 'messages' array which the UI uses.
        if let persistedMessages = llm.messageHistory, !persistedMessages.isEmpty {
            self.messages = persistedMessages
            print("🔍 MainViewModel: Loaded \(messages.count) persisted messages successfully.")
        } else {
            print("🔍 MainViewModel: No persisted messages found or history was empty.")
        }
    }
    
    func sendTextMessage(_ text: String) async {
        // 1. Add user message and placeholder to UI immediately
        let userMessage = ChatMessage(content: text, isUser: true, timestamp: Date())
        let placeholder = ChatMessage(content: "", isUser: false, timestamp: Date())
        
        await MainActor.run {
            messages.append(userMessage)
            messages.append(placeholder)
        }
        
        do {
            // 2. Call the LLM, telling it NOT to add a duplicate user message
            try await llm.send(text, addUserMessageToHistory: false)
            
            // 3. When done, find the final assistant message from the history
            if let assistantMessage = llm.messageHistory?.last(where: { !$0.isUser }) {
                // 4. On the main thread, find the placeholder and replace it with the final message
                await MainActor.run {
                    if let placeholderIndex = self.messages.firstIndex(where: { $0.id == placeholder.id }) {
                        self.messages[placeholderIndex] = assistantMessage
                    }
                }
            }
        } catch {
            // Handle errors by replacing the placeholder with an error message
            let errorMessage = ChatMessage(content: "Error: \(error.localizedDescription)", isUser: false, timestamp: Date(), messageType: .error)
            await MainActor.run {
                if let placeholderIndex = self.messages.firstIndex(where: { $0.id == placeholder.id }) {
                    self.messages[placeholderIndex] = errorMessage
                }
            }
            print("❌ MainViewModel: Error sending message: \(error)")
        }
    }
    
    func clearMessages() {
        // Clear the UI messages
        messages.removeAll()
        
        // Tell ChatViewModel to clear its persisted history
        llm.clearConversation()
        print("🔍 MainViewModel: Cleared messages and initiated clearing of ChatViewModel history.")
    }
    
    // MARK: - Clipboard Processing
    
    func setupClipboardProcessingObserver() {
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
        guard !isProcessingClipboard else {
            print("🔍 MainViewModel: Clipboard processing already in progress, ignoring duplicate call")
            return
        }
        
        isProcessingClipboard = true
        print("🔍 MainViewModel: handleClipboardTextProcessing called with text: \(text.prefix(100))...")
        
        let prompt = "Analyze this text (keep under 8000 tokens): \(text)"
        
        DispatchQueue.main.async {
            self.pendingClipboardPrompt = prompt
            self.shouldNavigateToChat = true
            self.isProcessingClipboard = false
        }
    }
    
    private func donateChainedMessageIntentIfNeeded() {
        let chainThreshold = 4
        guard messages.count >= chainThreshold else { return }
        
        let recentMessages = Array(messages.suffix(chainThreshold))
        
        var isChain = true
        for (index, message) in recentMessages.enumerated() {
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