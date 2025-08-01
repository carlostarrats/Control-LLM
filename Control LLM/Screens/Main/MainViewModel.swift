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
        // Don't clear existing messages - just add a context indicator
        // Load the chat context from the history entry
        // This would typically load the actual conversation history
        // For now, we'll create a placeholder message indicating the context
        let contextMessage = ChatMessage(
            content: "Continuing conversation from \(chatEntry.date): \(chatEntry.chats.first?.summary ?? "Previous chat")",
            isUser: false,
            timestamp: Date()
        )
        messages.append(contextMessage)
        
        // TODO: Load actual conversation history from persistent storage
        // This would involve loading the full conversation that matches this history entry
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
        
        // TODO: Implement actual LLM integration
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let response = ChatMessage(
                content: "This is a placeholder response to: \(text)",
                isUser: false,
                timestamp: Date()
            )
            self.messages.append(response)
            self.lastMessage = response.content
        }
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

enum MessageType {
    case text
    case file
}

struct ChatMessage: Identifiable {
    let id: String
    let content: String
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