import Foundation
import SwiftUI
import AVFoundation

@MainActor
class MainViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var isSpeaking = false
    @Published var isVoiceInputMode = false
    @Published var isActivated = false
    @Published var isVoiceDetected = false // New state for when user is talking
    @Published var isInVoiceFlow = false // New state to track entire voice interaction flow
    @Published var lastMessage: String?
    @Published var messages: [ChatMessage] = []
    
    // Add ChatViewModel instance for LLM operations
    let llm = ChatViewModel()
    
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
                self.isInVoiceFlow = false // End voice flow when LLM is done
            }
        }
    }
    
    func deactivateVoiceInputMode() {
        isVoiceInputMode = false
    }
    
    // MARK: - Voice Interaction Flow
    
    func voiceDetected() {
        // User started talking - fade out navigation buttons first, then show paperplane button
        print("🔍 voiceDetected() called - setting isInVoiceFlow = true first")
        withAnimation(.easeInOut(duration: 0.5)) {
            isInVoiceFlow = true // Start voice flow - this fades out navigation buttons
        }
        
        // Delay the paperplane button appearance to create visual separation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [self] in // 0.8 second delay
            print("🔍 Delayed setting isVoiceDetected = true")
            withAnimation(.easeInOut(duration: 0.5)) {
                self.isVoiceDetected = true // This fades in the paperplane button
            }
        }
    }

    func voiceStopped() {
        // User stopped talking - hide X button and return to normal state
        print("🔍 voiceStopped() called - setting isVoiceDetected = false")
        withAnimation(.easeInOut(duration: 0.5)) { // Restored withAnimation
            isVoiceDetected = false
            isInVoiceFlow = false // End voice flow
        }
    }

    func processVoiceMessage() {
        // User tapped X button - process the voice input and activate LLM
        print("🔍 processVoiceMessage() called - setting isVoiceDetected = false")
        withAnimation(.easeInOut(duration: 0.5)) { // Restored withAnimation
            isVoiceDetected = false
            // Keep isInVoiceFlow = true until LLM is done
        }
        
        // Acquire actual voice transcription when integrated
        let voiceInput = "".trimmingCharacters(in: .whitespacesAndNewlines)
        guard !voiceInput.isEmpty else {
            print("🔇 No voice transcript available — skipping processing")
            return
        }

        // Donate user's action to Shortcuts
        ShortcutsIntegrationHelper.shared.donateMessageSent(message: voiceInput)

        // Add user voice message to chat
        let userMessage = ChatMessage(content: voiceInput, isUser: true, timestamp: Date())
        messages.append(userMessage)

        // Send to LLM and get response
        Task {
            do {
                // Use the correct async method from ChatViewModel
                try await llm.send(voiceInput)
                
                // Wait for response to complete
                while llm.isProcessing {
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                }
                
                let responseText = llm.transcript
                
                // Add assistant response to chat
                let assistantMessage = ChatMessage(content: responseText, isUser: false, timestamp: Date())
                await MainActor.run {
                    self.messages.append(assistantMessage)
                }
                
                // Speak the response
                await MainActor.run {
                    TTSService.shared.speak(responseText)
                }
                
                // Activate main screen after response is complete
                await MainActor.run {
                    self.activateMainScreen()
                }
                
            } catch {
                print("❌ Error processing voice message: \(error)")
                await MainActor.run {
                    self.activateMainScreen()
                }
            }
        }
    }
    
    // MARK: - Test Methods (for development)
    
    func testVoiceStopped() {
        // Simulate user stopping talking - for testing
        voiceStopped()
    }
    
        private func startRecording() {
        // TODO: Implement actual voice recording
        print("Started recording...")
    }

    private func stopRecording() {
        // TODO: Implement actual voice recording stop and processing
        print("Stopped recording...")
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
            
            // Donate chained message intent after response
            self.donateChainedMessageIntentIfNeeded()
        }
    }

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