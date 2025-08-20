import Foundation
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    @Published var lastMessage: String?
    @Published var messages: [ChatMessage] = []
    
    // Add ChatViewModel instance for LLM operations
    let llm = ChatViewModel()
    
    // All voice functionality removed
    
    // Speaking functionality removed
    
    func sendTextMessage(_ text: String) {
        let userMessage = ChatMessage(content: text, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
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