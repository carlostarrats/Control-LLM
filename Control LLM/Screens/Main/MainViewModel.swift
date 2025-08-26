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
    
    func sendTextMessage(_ text: String) {
        print("🔍 MainViewModel: sendTextMessage called with text: \(text.prefix(50))...")
        
        // Don't add the user's message to the UI here.
        // The ChatViewModel will add it to its history, and we will sync from there
        // to ensure a single source of truth.
        
        Task {
            do {
                // This call will handle the LLM logic AND add both the user and assistant messages
                // to the llm.messageHistory array, then save it.
                try await llm.send(text)
                
                // After the LLM is done, sync the entire history back to the UI.
                await MainActor.run {
                    if let updatedHistory = self.llm.messageHistory {
                        self.messages = updatedHistory
                        print("🔍 MainViewModel: Synced messages with ChatViewModel history. New count: \(self.messages.count)")
                    }
                }
            } catch {
                print("❌ MainViewModel: Error calling LLM: \(error)")
                // Optionally, display an error message in the UI
            }
        }
        
        donateChainedMessageIntentIfNeeded()
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