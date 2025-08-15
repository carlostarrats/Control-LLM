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
        // FIXED: Listen for the correct notification name that ModelManager posts
        modelChangeObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("modelDidChange"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleModelChange()
        }
    }
    
    private func handleModelChange() {
        print("🔍 ChatViewModel: handleModelChange called")
        
        // Don't clear messageHistory to preserve conversation context
        // Only clear the transcript and model state
        
        Task { [weak self] in
            guard let self = self else { return }
            
            // Clear transcript but preserve message history
            await MainActor.run {
                self.transcript = ""
                self.modelLoaded = false
                self.lastLoadedModel = nil
            }
            
            // Clear duplicate message state to allow re-sending
            self.clearDuplicateMessageState()
            
            // Force unload and reload the model
            do {
                print("🔍 ChatViewModel: Force unloading previous model")
                try await LLMService.shared.forceUnloadModel()
                
                print("🔍 ChatViewModel: Loading new model")
                try await self.ensureModel()
                
                print("🔍 ChatViewModel: Model switch completed successfully")
            } catch {
                print("❌ ChatViewModel: Error during model switch: \(error)")
                await MainActor.run {
                    self.modelLoaded = false
                }
            }
        }
    }
    
    func send(_ userText: String) async throws {
        print("🔍 ChatViewModel: send started — \(userText)")
        
        // Check if this is a duplicate message to the same model
        let currentModel = lastLoadedModel ?? "unknown"
        let isDuplicate = userText == lastSentMessage && lastLoadedModel != nil
        
        if isDuplicate {
            print("🔍 ChatViewModel: Duplicate message detected for model \(currentModel), ignoring")
            return
        }
        
        lastSentMessage = userText
        
        Task { [weak self] in
            guard let self = self else { return }
            
            do {
                await MainActor.run {
                    self.isProcessing = true
                    // Start a fresh transcript for this request
                    self.transcript = ""
                }
                
                // Check if model has changed and force reload if needed
                let currentModel = ModelManager.shared.getSelectedModelFilename()
                let modelSwitched = self.lastLoadedModel != currentModel
                
                if modelSwitched {
                    print("🔍 ChatViewModel: Model switch detected during send: \(self.lastLoadedModel ?? "nil") -> \(currentModel ?? "nil")")
                    
                    // Don't switch models during an active chat operation - this can cause crashes
                    print("⚠️ WARNING: Model switch detected during active chat operation. Completing current operation first.")
                    
                    // Continue with the current model for this message
                    print("🔍 ChatViewModel: Continuing with current model to avoid crash")
                }
                
                // Use any loaded conversation context from history, with safeguards
                let historyToSend: [ChatMessage] = buildSafeHistory(from: messageHistory ?? [])
                
                // Use the correct LLMService method signature
                try await LLMService.shared.chat(
                    user: userText,
                    history: historyToSend,
                    onToken: { [weak self] partialResponse in
                        print("🔍 ChatViewModel: onToken called with response length: \(partialResponse.count)")
                        print("🔍 ChatViewModel: Response content: '\(partialResponse)'")
                        
                        // Update transcript immediately for non-streaming responses
                        Task { @MainActor in
                            print("🔍 ChatViewModel: Appending to transcript: '\(partialResponse)'")
                            self?.transcript += partialResponse
                            print("🔍 ChatViewModel: Transcript append successful")
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

    // MARK: - History Safeguard
    private func buildSafeHistory(from fullHistory: [ChatMessage]) -> [ChatMessage] {
        // Limits to prevent overwhelming the prompt
        let maxMessages = 20
        let maxCharacters = 4000

        // Take the most recent messages up to maxMessages
        var trimmed = Array(fullHistory.suffix(maxMessages))

        // If still too long, trim from the oldest in this window until below character cap
        func totalChars(_ msgs: [ChatMessage]) -> Int {
            msgs.reduce(0) { $0 + $1.content.count }
        }

        while totalChars(trimmed) > maxCharacters && !trimmed.isEmpty {
            trimmed.removeFirst()
        }

        return trimmed
    }
    
    func clearConversation() {
        DispatchQueue.main.async {
            self.transcript = ""
            self.messageHistory = []
            self.lastSentMessage = nil
            print("🔍 ChatViewModel: Conversation cleared")
        }
    }
    
    func clearDuplicateMessageState() {
        DispatchQueue.main.async {
            self.lastSentMessage = nil
            print("🔍 ChatViewModel: Duplicate message state cleared")
        }
    }
    
    func ensureModel() async throws {
        print("🔍 ChatViewModel: ensureModel called")
        
        // Check if we need to load a model
        if !modelLoaded || lastLoadedModel == nil {
            print("🔍 ChatViewModel: Model not loaded, loading selected model")
            try await LLMService.shared.loadSelectedModel()
            
            // Get the new model filename
            let newModel = ModelManager.shared.getSelectedModelFilename()
            await MainActor.run {
                self.lastLoadedModel = newModel
                self.modelLoaded = true
            }
            
            print("🔍 ChatViewModel: Model loaded successfully: \(newModel ?? "unknown")")
        } else {
            print("🔍 ChatViewModel: Model already loaded: \(lastLoadedModel ?? "unknown")")
        }
    }
}