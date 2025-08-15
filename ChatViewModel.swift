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
                try await HybridLLMService.shared.forceUnloadModel()
                
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

        // Prevent duplicate submissions
        let isDuplicate = userText == lastSentMessage && lastLoadedModel != nil
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
                    self.transcript = ""
                }
                
                // Ensure the correct model is loaded via the hybrid service
                try await HybridLLMService.shared.loadSelectedModel()

                let historyToSend = buildSafeHistory(from: messageHistory ?? [])
                
                // Use the HybridLLMService to generate the response
                try await HybridLLMService.shared.generateResponse(
                    userText: userText,
                    history: historyToSend
                ) { [weak self] partialResponse in
                    Task { @MainActor in
                        self?.transcript += partialResponse
                    }
                }
                
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

        // Use the HybridLLMService to manage model state
        if !(await HybridLLMService.shared.isModelLoaded) {
            print("🔍 ChatViewModel: Model not loaded, loading selected model via Hybrid Service")
            try await HybridLLMService.shared.loadSelectedModel()
        } else {
            let engineInfo = await HybridLLMService.shared.getCurrentEngineInfo()
            print("🔍 ChatViewModel: Model already loaded: \(engineInfo)")
        }
        
        // Sync local state for UI purposes by fetching async properties first
        let isLoaded = await HybridLLMService.shared.isModelLoaded
        let filename = await HybridLLMService.shared.currentModelFilename
        
        await MainActor.run {
            self.modelLoaded = isLoaded
            self.lastLoadedModel = filename
        }
    }
}