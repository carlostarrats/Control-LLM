import Foundation
import SwiftUI

@Observable
class ChatViewModel: ObservableObject {
    var transcript: String = ""
    var isProcessing: Bool = false
    var modelLoaded: Bool = false
    var lastLoadedModel: String? = nil
    var lastSentMessage: String? = nil
    var messageHistory: [ChatMessage]? = []
    
    private var modelChangeObserver: NSObjectProtocol?
    private var updateTimer: Timer?
    
    init() {
        print("🔍 ChatViewModel: init")
        setupModelChangeObserver()
    }
    
    deinit {
        if let observer = modelChangeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        updateTimer?.invalidate()
    }
    
    private func setupModelChangeObserver() {
        modelChangeObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ModelSelectionChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleModelChange()
        }
    }
    
    private func handleModelChange() {
        print("ChatViewModel: Model changed, reloading...")
        DispatchQueue.main.async {
            self.modelLoaded = false
            self.lastLoadedModel = nil
        }
    }
    
    func send(_ userText: String) {
        print("🔍 ChatViewModel: send started — \(userText)")
        
        // Check if this is a duplicate message
        let isDuplicate = userText == lastSentMessage
        
        if isDuplicate {
            print("🔍 ChatViewModel: Duplicate message detected, ignoring")
            return
        }
        
        lastSentMessage = userText
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                await MainActor.run {
                    self.isProcessing = true
                }
                
                // Check if model has changed and force reload if needed
                let currentModel = await ModelManager.shared.getSelectedModelFilename()
                let modelSwitched = self.lastLoadedModel != currentModel
                
                if modelSwitched {
                    print("🔍 ChatViewModel: Model switch detected: \(self.lastLoadedModel ?? "nil") -> \(currentModel ?? "nil")")
                    
                    // Force unload and reload the model
                    try await LLMService.shared.forceUnloadModel()
                    try await LLMService.shared.loadSelectedModel()
                    
                    await MainActor.run {
                        self.lastLoadedModel = currentModel
                        self.messageHistory = [] // Clear history for fresh responses
                    }
                    
                    print("🔍 ChatViewModel: Model switched and reloaded successfully")
                }
                
                // Always use empty history to ensure different responses from different models
                let historyToSend: [ChatMessage] = []
                
                // Use throttled transcript updates to prevent console flooding
                var pendingTranscript = ""
                
                // Use the correct LLMService method signature
                try await LLMService.shared.chat(
                    user: userText,
                    history: historyToSend,
                    onToken: { [weak self] partialResponse in
                        // Store the response but don't update UI immediately
                        pendingTranscript = partialResponse
                        
                        // Throttle UI updates to prevent flooding
                        DispatchQueue.main.async {
                            // Invalidate previous timer
                            self?.updateTimer?.invalidate()
                            
                            // Set new timer to update UI after a brief delay
                            self?.updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                                self?.transcript = pendingTranscript
                            }
                        }
                    }
                )
                
                await MainActor.run {
                    self.isProcessing = false
                }
                
            } catch {
                await MainActor.run {
                    print("❌ ChatViewModel: Error in send: \(error)")
                    self.isProcessing = false
                    self.transcript = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func clearConversation() {
        DispatchQueue.main.async {
            self.transcript = ""
            self.messageHistory = []
            self.lastSentMessage = nil
            print("🔍 ChatViewModel: Conversation cleared")
        }
    }
}