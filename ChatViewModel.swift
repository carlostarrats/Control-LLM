import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var transcript: String = ""
    var messageHistory: [ChatMessage]?
    private var modelLoaded = false
    private var lastLoadedModel: String?
    private var lastSentMessage = ""
    private var isProcessing = false

    func send(_ userText: String) {
        print("🔍 ChatViewModel: send started — \(userText)")
        print("🔍 ChatViewModel: transcript before = '\(transcript)'")
        
        // Check if this is a duplicate message
        let isDuplicate = userText == lastSentMessage
        print("🔍 ChatViewModel: isDuplicate = \(isDuplicate)")
        lastSentMessage = userText
        
        // Allow duplicate messages to be processed
        // Reset processing state to allow new requests
        isProcessing = false
        
        // For duplicate messages, reset transcript to force UI update
        if isDuplicate {
            self.transcript = ""
        }
        
        Task { [weak self] in
            guard let self = self else { return }
            do {
                await MainActor.run { 
                    self.isProcessing = true
                    // Don't reset transcript - let it accumulate naturally
                }
                
                print("🔍 ChatViewModel: calling ensureModel()")
                try await ensureModel()
                print("🔍 ChatViewModel: ensureModel() completed successfully")
                
                print("🔍 ChatViewModel: calling LLMService.shared.chat()")
                // Clear transcript for new assistant response
                await MainActor.run {
                    self.transcript = ""
                }
                
                print("🔍 ChatViewModel: About to call LLMService.shared.chat with text: '\(userText)'")
                try await LLMService.shared.chat(user: userText, history: self.messageHistory) { token in
                    print("🔍 ChatViewModel: received token: '\(token)'")
                    await MainActor.run { 
                        // token is now already a String from LLMService
                        if !token.isEmpty {
                            self.transcript += token 
                        }
                        print("🔍 ChatViewModel: transcript updated to: '\(self.transcript)'")
                    }
                }
                print("🔍 ChatViewModel: LLMService.shared.chat() completed successfully")
                
                // Check if we received any tokens
                await MainActor.run {
                    if self.transcript.isEmpty {
                        print("⚠️ ChatViewModel: No tokens received from LLM")
                        self.transcript = "No response received from the model."
                    }
                }
                // No extra newline needed - let the text end naturally
            } catch {
                let errorMessage = getErrorMessage(for: error)
                await MainActor.run { 
                    self.transcript += "\n⚠️ \(errorMessage)\n" 
                }
            }
            
            await MainActor.run {
                self.isProcessing = false
                print("🔍 ChatViewModel: send completed, transcript = '\(self.transcript)'")
            }
        }
    }

    private func ensureModel() async throws {
        let currentModel = ModelManager.shared.getSelectedModelFilename()
        
        // Reload if model changed or not loaded yet
        if !modelLoaded || lastLoadedModel != currentModel {
            try await LLMService.shared.loadSelectedModel()
            modelLoaded = true
            lastLoadedModel = currentModel
            print("ChatViewModel: Loaded model \(currentModel ?? "unknown")")
        }
    }
    
    /// Force reload the model (useful when user changes model selection)
    func reloadModel() {
        modelLoaded = false
        lastLoadedModel = nil
    }
    
    private func getErrorMessage(for error: Error) -> String {
        if let nsError = error as NSError? {
            switch nsError.code {
            case 7:
                return "Model loading timed out. Please try a smaller model like TinyLlama."
            default:
                return error.localizedDescription
            }
        }
        return error.localizedDescription
    }
}
