import Foundation
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    @Published var lastMessage: String?
    @Published var messages: [ChatMessage] = []
    
    // Add ChatViewModel instance for LLM operations
    let llm = ChatViewModel()
    
    // Voice recording functionality removed
    
    func loadChatContext(from chatEntry: ChatHistoryEntry) {
        // Clear existing messages
        messages.removeAll()
        
        // Find the actual ChatSession and load its messages
        if let firstChat = chatEntry.chats.first,
           let session = ChatHistoryService.shared.getChatSession(byId: firstChat.id) {
            
            // Load the actual message history from the ChatSession
            if let sessionMessages = session.messages {
                messages = sessionMessages
                // Also set the LLM history so the next request uses this context
                llm.messageHistory = sessionMessages
            } else {
                // Fallback: create a context message if no messages available
                let contextMessage = ChatMessage(
                    content: "Continuing conversation: \(firstChat.summary)",
                    isUser: false,
                    timestamp: Date()
                )
                messages.append(contextMessage)
                llm.messageHistory = messages
            }
        }
    }
    
    // All voice functionality removed
    
    // Speaking functionality removed
    
    func sendTextMessage(_ text: String) {
        let userMessage = ChatMessage(content: text, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        // Use ChatViewModel for LLM integration
        // The actual LLM response will be handled by the TextModalView through ChatViewModel
        // This is just for adding the user message to the conversation
        donateChainedMessageIntentIfNeeded()
    }
    
    func saveChatSession(title: String? = nil, summary: String? = nil) {
        print("📝 Attempting to save chat session...")
        print("   Messages count: \(messages.count)")
        print("   User messages: \(messages.filter { $0.isUser }.count)")
        print("   Assistant messages: \(messages.filter { !$0.isUser }.count)")
        print("   Non-empty assistant messages: \(messages.filter { !$0.isUser && !$0.content.isEmpty }.count)")
        
        // Only save if there are meaningful messages (at least one user and one assistant message)
        guard messages.count >= 2,
              messages.contains(where: { $0.isUser }),
              messages.contains(where: { !$0.isUser && !$0.content.isEmpty }) else {
            print("❌ Save failed: Not enough meaningful messages")
            return
        }
        
        let chatHistoryService = ChatHistoryService.shared
        let generatedTitle = title ?? chatHistoryService.generateChatTitle(from: messages)
        let generatedSummary = summary ?? chatHistoryService.generateChatSummary(from: messages)
        
        print("   Generated title: '\(generatedTitle)'")
        print("   Generated summary: '\(generatedSummary)'")
        
        let session = ChatSession(
            id: UUID().uuidString,
            title: generatedTitle,
            summary: generatedSummary,
            date: messages.first?.timestamp ?? Date(),
            messages: messages
        )
        
        chatHistoryService.addChatSession(session)
        print("✅ Chat session saved successfully!")
    }
    
    func clearMessages() {
        messages.removeAll()
        hasAutoSaved = false // Reset auto-save flag for new conversation
    }
    
    private var hasAutoSaved = false
    
    func autoSaveIfNeeded() {
        // Only save when conversation has meaningful content (multiple exchanges)
        let userMessageCount = messages.filter { $0.isUser }.count
        let assistantMessageCount = messages.filter { !$0.isUser && !$0.content.isEmpty }.count
        
        print("🔄 AutoSave check: \(userMessageCount) user messages, \(assistantMessageCount) assistant messages")
        print("   Has already auto-saved: \(hasAutoSaved)")
        
        // Save after first complete exchange (1 user + 1 assistant) but only once per conversation
        if userMessageCount >= 1 && assistantMessageCount >= 1 && !hasAutoSaved {
            print("💾 Auto-saving conversation...")
            saveChatSession()
            hasAutoSaved = true
        }
    }
    
    // Voice input functionality removed

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