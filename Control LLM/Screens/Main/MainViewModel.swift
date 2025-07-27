import Foundation
import SwiftUI

@MainActor
class MainViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var isSpeaking = false
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

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
} 