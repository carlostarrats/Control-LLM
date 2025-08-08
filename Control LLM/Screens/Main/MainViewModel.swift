import Foundation
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var isSpeaking = false
    @Published var isVoiceInputMode = false
    @Published var isActivated = false
    @Published var lastMessage: String?
    @Published var messages: [ChatMessage] = []
    
    func toggleRecording() {
        isRecording.toggle()
        
        if isRecording {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    func loadChatContext(from chatEntry: ChatHistoryEntry) {
        // Clear existing messages
        messages.removeAll()
        
        // Load the actual conversation history from the chat entry
        if let firstChat = chatEntry.chats.first {
            // Create a context message indicating we're continuing the conversation
            let contextMessage = ChatMessage(
                content: "Continuing conversation from \(chatEntry.date): \(firstChat.summary)",
                isUser: false,
                timestamp: Date()
            )
            messages.append(contextMessage)
            
            // TODO: Load the actual message history from the ChatSession
            // For now, we'll just show the context message
            // In a full implementation, you would load the messages from the ChatSession
        }
    }
    
    func activateVoiceInputMode() {
        isVoiceInputMode = true
        isActivated = true
        
        // Clear any existing messages and add a prompt
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let promptMessage = ChatMessage(
                content: "What can I help you with?",
                isUser: false,
                timestamp: Date()
            )
            self.messages.append(promptMessage)
            self.lastMessage = promptMessage.content
        }
        
        // Return to normal state after 3 seconds (same as visualizer tap)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.8)) {
                self.isActivated = false
            }
        }
    }
    
    func activateMainScreen() {
        // Activate the main screen interface with the same sequence as tapping the visualizer
        withAnimation(.easeInOut(duration: 0.8)) {
            isActivated = true
        }
        
        // Return to normal state after 3 seconds (same as the visualizer tap)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.8)) {
                self.isActivated = false
            }
        }
    }
    
    func deactivateVoiceInputMode() {
        isVoiceInputMode = false
    }
    
        private func startRecording() {
        // TODO: Implement actual voice recording
        print("Started recording...")
    }

    private func stopRecording() {
        // TODO: Implement actual voice recording stop and processing
        print("Stopped recording...")
        
        // Simulate processing and response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.processVoiceInput("Hello, this is a placeholder voice message")
        }
        
        // Simulate LLM speaking response
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.startSpeaking()
        }
    }
    
    private func startSpeaking() {
        isSpeaking = true
        print("LLM started speaking...")
        
        // Simulate speaking duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.stopSpeaking()
        }
    }
    
    private func stopSpeaking() {
        isSpeaking = false
        print("LLM stopped speaking...")
    }
    
    func sendTextMessage(_ text: String) {
        let userMessage = ChatMessage(content: text, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        // Use ChatViewModel for LLM integration
        // The actual LLM response will be handled by the TextModalView through ChatViewModel
        // This is just for adding the user message to the conversation
    }
    
    func saveChatSession(title: String, summary: String) {
        let session = ChatSession(
            id: UUID().uuidString,
            title: title,
            summary: summary,
            date: Date(),
            messages: messages
        )
        
        ChatHistoryService.shared.addChatSession(session)
        
        // Clear current messages after saving
        messages.removeAll()
    }
    
    private func processVoiceInput(_ text: String) {
        let userMessage = ChatMessage(content: text, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        // TODO: Implement actual LLM integration
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let response = ChatMessage(
                content: "Voice message received: \(text). This is a placeholder response.",
                isUser: false,
                timestamp: Date()
            )
            self.messages.append(response)
            self.lastMessage = response.content
        }
    }
}

enum MessageType: Codable {
    case text
    case file
}

struct ChatMessage: Identifiable, Codable {
    let id: String
    var content: String
    let isUser: Bool
    let timestamp: Date
    let messageType: MessageType
    let fileName: String?
    let fileURL: URL?
    
    init(content: String, isUser: Bool, timestamp: Date, messageType: MessageType = .text, fileName: String? = nil, fileURL: URL? = nil) {
        self.id = UUID().uuidString
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.messageType = messageType
        self.fileName = fileName
        self.fileURL = fileURL
    }
} 