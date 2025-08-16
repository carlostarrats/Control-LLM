import Foundation
import SwiftUI

@MainActor
class VoiceIntegrationService: ObservableObject {
    static let shared = VoiceIntegrationService()
    
    // MARK: - Services
    private let voiceService = VoiceService.shared
    private let voiceChatService = VoiceChatService.shared
    private let gemma3NVoiceService = Gemma3NVoiceService.shared
    private let languageService = LanguageService.shared
    private let modelManager = ModelManager.shared
    
    // MARK: - Published Properties
    @Published var isVoiceModeActive = false
    @Published var currentTranscription = ""
    @Published var isProcessingVoice = false
    @Published var errorMessage: String?
    
    // MARK: - Callbacks
    var onVoiceInputComplete: ((String) -> Void)?
    var onVoiceResponseComplete: (() -> Void)?
    
    // MARK: - Task Management
    private var currentTask: Task<Void, Never>?
    
    private init() {
        setupVoiceServiceCallbacks()
        setupVoiceChatServiceCallbacks()
    }
    
    deinit {
        print("🧹 VoiceIntegrationService: Deinitializing")
        // Note: Cannot call @MainActor methods from deinit
        // Cleanup will be handled by explicit cleanup calls
    }
    
    // MARK: - Setup
    
    private func setupVoiceServiceCallbacks() {
        voiceService.onTranscriptionComplete = { [weak self] transcribedText in
            self?.handleTranscriptionComplete(transcribedText)
        }
        
        voiceService.onSpeechComplete = { [weak self] in
            self?.handleSpeechComplete()
        }
    }
    
    private func setupVoiceChatServiceCallbacks() {
        voiceChatService.onTranscriptionComplete = { [weak self] transcribedText in
            self?.handleTranscriptionComplete(transcribedText)
        }
    }
    
    // MARK: - Public Methods
    
    /// Toggle voice mode for the current model
    func toggleVoiceMode() {
        if isVoiceModeActive {
            stopVoiceMode()
        } else {
            startVoiceMode()
        }
    }
    
    /// Start voice mode
    func startVoiceMode() {
        guard let selectedModel = modelManager.selectedModel else {
            print("❌ VoiceIntegrationService: No model selected")
            return
        }
        
        // Validate model exists and is accessible
        guard !selectedModel.filename.isEmpty else {
            print("❌ VoiceIntegrationService: Invalid model selection")
            return
        }
        
        // Ensure clean state before starting
        if isVoiceModeActive {
            print("⚠️ VoiceIntegrationService: Voice mode already active, stopping first")
            stopVoiceMode()
        }
        
        // Check if current model supports voice
        if isModelVoiceCapable(selectedModel) {
            print("🎤 VoiceIntegrationService: Starting voice mode for \(selectedModel.displayName)")
            startVoiceInput()
        } else {
            print("🎤 VoiceIntegrationService: Model \(selectedModel.displayName) doesn't support voice, using iOS wrapper")
            // For text-only models, we'll use iOS speech wrapper
            startIOSVoiceWrapper()
        }
    }
    
    /// Stop voice mode
    func stopVoiceMode() {
        print("🔇 VoiceIntegrationService: Stopping voice mode")
        
        // Cancel any running tasks
        currentTask?.cancel()
        currentTask = nil
        
        // Stop both voice services
        voiceChatService.stopListening()
        gemma3NVoiceService.stopListening()
        
        // Clear callbacks to prevent memory leaks
        voiceChatService.onTranscriptionComplete = nil
        gemma3NVoiceService.onTranscriptionComplete = nil
        gemma3NVoiceService.onSpeechComplete = nil
        
        // Clear our own callbacks
        onVoiceInputComplete = nil
        onVoiceResponseComplete = nil
        
        isVoiceModeActive = false
        isProcessingVoice = false
        currentTranscription = ""
        
        print("🧹 VoiceIntegrationService: Voice mode stopped and cleaned up")
    }
    
    /// Check if the current model supports voice natively
    func isModelVoiceCapable(_ model: LLMModelInfo) -> Bool {
        // Check if the model is Gemma-3N which supports native voice
        let filename = model.filename.lowercased()
        return filename.contains("gemma-3n-e4b-it") || filename.contains("gemma-3n") || filename.contains("gemma3n")
    }
    
    /// Get the current model's voice capabilities
    func getCurrentModelVoiceCapabilities() -> String {
        guard let selectedModel = modelManager.selectedModel else {
            return "No model selected"
        }
        
        if isModelVoiceCapable(selectedModel) {
            return "Gemma-3N Native Voice"
        } else {
            return "iOS Speech Wrapper"
        }
    }
    
    /// Get the current voice service status
    func getCurrentVoiceServiceStatus() -> String {
        guard let selectedModel = modelManager.selectedModel else {
            return "No model loaded"
        }
        
        if isModelVoiceCapable(selectedModel) {
            if gemma3NVoiceService.isListening {
                return "Gemma-3N Listening..."
            } else if gemma3NVoiceService.isTranscribing {
                return "Gemma-3N Processing..."
            } else {
                return "Gemma-3N Ready"
            }
        } else {
            if voiceChatService.isListening {
                return "iOS Listening..."
            } else if voiceChatService.isTranscribing {
                return "iOS Processing..."
            } else {
                return "iOS Ready"
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func startVoiceInput() {
        // For models with native voice support (like Gemma 3N)
        // Use the model's built-in voice capabilities
        print("🎤 VoiceIntegrationService: Using Gemma-3N native voice capabilities")
        
        // Cancel any existing task before starting new one
        if let existingTask = currentTask {
            existingTask.cancel()
            currentTask = nil
        }
        
        // Set up callbacks for native voice processing
        gemma3NVoiceService.onTranscriptionComplete = { [weak self] transcribedText in
            self?.handleTranscriptionComplete(transcribedText)
        }
        
        gemma3NVoiceService.onSpeechComplete = { [weak self] in
            self?.handleSpeechComplete()
        }
        
        // Start native voice input
        currentTask = Task {
            do {
                try await gemma3NVoiceService.startListening()
                await MainActor.run {
                    self.isVoiceModeActive = true
                }
                print("🎤 VoiceIntegrationService: Started Gemma-3N native voice input")
            } catch {
                print("❌ VoiceIntegrationService: Failed to start native voice input: \(error)")
                await MainActor.run {
                    self.isVoiceModeActive = false
                }
                // Fall back to iOS wrapper if native fails
                print("🔄 VoiceIntegrationService: Falling back to iOS voice wrapper")
                startIOSVoiceWrapper()
                
                // Note: If fallback also fails, the error will be handled in startIOSVoiceWrapper
                // and set in errorMessage for display to the user
            }
        }
    }
    
    private func startIOSVoiceWrapper() {
        // For text-only models, use iOS speech recognition + TTS wrapper
        print("🎤 VoiceIntegrationService: Using iOS voice wrapper")
        
        // Cancel any existing task before starting new one
        if let existingTask = currentTask {
            existingTask.cancel()
            currentTask = nil
        }
        
        // Set up the callback for when transcription completes
        voiceChatService.onTranscriptionComplete = { [weak self] transcribedText in
            self?.handleTranscriptionComplete(transcribedText)
        }
        
        // Start voice chat service for LLM integration
        currentTask = Task {
            do {
                try await voiceChatService.startListening()
                await MainActor.run {
                    self.isVoiceModeActive = true
                }
                print("🎤 VoiceIntegrationService: Started iOS voice wrapper with LLM integration")
            } catch {
                print("❌ VoiceIntegrationService: Failed to start iOS voice wrapper: \(error)")
                await MainActor.run {
                    self.isVoiceModeActive = false
                }
                
                // If both native and iOS wrapper fail, notify user
                await MainActor.run {
                    self.errorMessage = "Voice input failed. Please check microphone permissions and try again."
                }
            }
        }
    }
    
    private func handleTranscriptionComplete(_ transcribedText: String) {
        // Since we're already on MainActor, we can update UI directly
        self.currentTranscription = transcribedText
        self.isProcessingVoice = true
        
        print("📝 VoiceIntegrationService: Transcription complete: \(transcribedText)")
        
        // Send to conversation system
        self.onVoiceInputComplete?(transcribedText)
        
        // Process with LLM and get response
        self.processVoiceInputWithLLM(transcribedText)
        
        // Stop listening after transcription is complete
        // Stop the appropriate service based on which one was active
        // Use a local copy to avoid race conditions
        let gemmaListening = self.gemma3NVoiceService.isListening
        let voiceChatListening = self.voiceChatService.isListening
        
        // Stop the appropriate service based on which one was active
        if gemmaListening {
            self.gemma3NVoiceService.stopListening()
        } else if voiceChatListening {
            self.voiceChatService.stopListening()
        }
        
        // Note: Don't cancel the current task here as it might have already completed
        // The task will be cleaned up when stopVoiceMode() is called
    }
    
    private func processVoiceInputWithLLM(_ inputText: String) {
        print("🤖 VoiceIntegrationService: Processing with LLM: \(inputText)")
        
        // Post notification to add voice input to chat UI
        NotificationCenter.default.post(
            name: NSNotification.Name("voiceInputReceived"),
            object: nil,
            userInfo: ["text": inputText]
        )
        
        // Cancel any existing task before starting new one
        if let existingTask = currentTask {
            existingTask.cancel()
            currentTask = nil
        }
        
        // Process with LLM using existing service
        currentTask = Task {
            do {
                var responseText = ""
                
                // Process with LLM - this will automatically add to conversation history
                try await HybridLLMService.shared.generateResponse(
                    userText: inputText,
                    history: nil, // Let the LLM service use its own history management
                    onToken: { token in
                        responseText += token
                        
                        // Post notification to update response
                        NotificationCenter.default.post(
                            name: NSNotification.Name("voiceResponseToken"),
                            object: nil,
                            userInfo: ["token": token, "inputText": inputText]
                        )
                    }
                )
                
                // Post notification that response is complete
                NotificationCenter.default.post(
                    name: NSNotification.Name("voiceResponseComplete"),
                    object: nil,
                    userInfo: ["response": responseText, "inputText": inputText]
                )
                
                // Speak the complete response
                await MainActor.run {
                    self.speakResponse(responseText)
                }
                
            } catch {
                print("❌ VoiceIntegrationService: LLM processing failed: \(error)")
                
                // Post notification about the error
                NotificationCenter.default.post(
                    name: NSNotification.Name("voiceResponseError"),
                    object: nil,
                    userInfo: ["error": error.localizedDescription, "inputText": inputText]
                )
            }
        }
    }
    
    private func speakResponse(_ responseText: String) {
        guard !responseText.isEmpty else { return }
        
        print("🗣️ VoiceIntegrationService: Speaking response: \(responseText)")
        
        // Check if current model supports native voice
        guard let selectedModel = modelManager.selectedModel else {
            print("❌ VoiceIntegrationService: No model selected for speech")
            return
        }
        
        if isModelVoiceCapable(selectedModel) {
            // Use Gemma-3N's native speech synthesis
            print("🗣️ VoiceIntegrationService: Using Gemma-3N native TTS")
            gemma3NVoiceService.speak(responseText)
        } else {
            // Use iOS TTS for other models
            print("🗣️ VoiceIntegrationService: Using iOS TTS wrapper")
            let languageCode = voiceService.getSpeechRecognitionLanguage(for: languageService.selectedLanguage)
            voiceService.speak(responseText, language: languageCode)
        }
    }
    
    private func handleSpeechComplete() {
        // Since we're already on MainActor, we can update UI directly
        self.isProcessingVoice = false
        self.isVoiceModeActive = false
        
        print("✅ VoiceIntegrationService: Voice response complete")
        
        // Notify completion
        self.onVoiceResponseComplete?()
    }
    

}
