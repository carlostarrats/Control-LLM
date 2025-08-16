import Foundation
import SwiftUI

class VoiceIntegrationService: ObservableObject {
    static let shared = VoiceIntegrationService()
    
    // MARK: - Services
    private let voiceService = VoiceService.shared
    private let languageService = LanguageService.shared
    private let modelManager = ModelManager.shared
    
    // MARK: - Published Properties
    @Published var isVoiceModeActive = false
    @Published var currentTranscription = ""
    @Published var isProcessingVoice = false
    
    // MARK: - Callbacks
    var onVoiceInputComplete: ((String) -> Void)?
    var onVoiceResponseComplete: (() -> Void)?
    
    private init() {
        setupVoiceServiceCallbacks()
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
        
        // Check if current model supports voice
        if isModelVoiceCapable(selectedModel) {
            print("🎤 VoiceIntegrationService: Starting voice mode for \(selectedModel.displayName)")
            startVoiceInput()
        } else {
            print("❌ VoiceIntegrationService: Model \(selectedModel.displayName) doesn't support voice")
            // For text-only models, we'll use iOS speech wrapper
            startIOSVoiceWrapper()
        }
    }
    
    /// Stop voice mode
    func stopVoiceMode() {
        print("🔇 VoiceIntegrationService: Stopping voice mode")
        
        voiceService.stopListening()
        isVoiceModeActive = false
        isProcessingVoice = false
        currentTranscription = ""
    }
    
    /// Check if the current model supports voice natively
    func isModelVoiceCapable(_ model: LLMModelInfo) -> Bool {
        // Currently only Gemma 3N supports voice natively
        return model.filename.lowercased().contains("gemma-3n-e4b-it")
    }
    
    /// Get the current model's voice capabilities
    func getCurrentModelVoiceCapabilities() -> String {
        guard let selectedModel = modelManager.selectedModel else {
            return "No model selected"
        }
        
        if isModelVoiceCapable(selectedModel) {
            return "Native voice support"
        } else {
            return "iOS speech wrapper"
        }
    }
    
    // MARK: - Private Methods
    
    private func startVoiceInput() {
        // For models with native voice support (like Gemma 3N)
        // This would integrate with the model's built-in voice capabilities
        print("🎤 VoiceIntegrationService: Using native voice capabilities")
        
        // TODO: Implement native voice integration for Gemma 3N
        // For now, fall back to iOS wrapper
        startIOSVoiceWrapper()
    }
    
    private func startIOSVoiceWrapper() {
        // For text-only models, use iOS speech recognition + TTS wrapper
        print("🎤 VoiceIntegrationService: Using iOS speech wrapper")
        
        // Set language for speech recognition
        let languageCode = voiceService.getSpeechRecognitionLanguage(for: languageService.selectedLanguage)
        
        // Start listening
        voiceService.startListening()
        isVoiceModeActive = true
        
        print("🎤 VoiceIntegrationService: Started iOS voice wrapper with language: \(languageCode)")
    }
    
    private func handleTranscriptionComplete(_ transcribedText: String) {
        DispatchQueue.main.async {
            self.currentTranscription = transcribedText
            self.isProcessingVoice = true
            
            print("📝 VoiceIntegrationService: Transcription complete: \(transcribedText)")
            
            // Send to conversation system
            self.onVoiceInputComplete?(transcribedText)
            
            // Process with LLM and get response
            self.processVoiceInputWithLLM(transcribedText)
        }
    }
    
    private func processVoiceInputWithLLM(_ inputText: String) {
        // TODO: Integrate with existing LLM processing
        // This should use the same path as text input but with voice output
        
        print("🤖 VoiceIntegrationService: Processing with LLM: \(inputText)")
        
        // For now, simulate a response
        let simulatedResponse = "This is a simulated response to: \(inputText)"
        
        // Speak the response
        speakResponse(simulatedResponse)
    }
    
    private func speakResponse(_ responseText: String) {
        guard !responseText.isEmpty else { return }
        
        print("🗣️ VoiceIntegrationService: Speaking response: \(responseText)")
        
        // Get language code for TTS
        let languageCode = voiceService.getSpeechRecognitionLanguage(for: languageService.selectedLanguage)
        // Speak the response
        voiceService.speak(responseText, language: languageCode)
    }
    
    private func handleSpeechComplete() {
        DispatchQueue.main.async {
            self.isProcessingVoice = false
            self.isVoiceModeActive = false
            
            print("✅ VoiceIntegrationService: Voice response complete")
            
            // Notify completion
            self.onVoiceResponseComplete?()
        }
    }
}

// MARK: - Model Voice Capability Extensions

extension LLMModelInfo {
    /// Check if this model supports voice natively
    var supportsVoice: Bool {
        return self.filename.lowercased().contains("gemma-3n-e4b-it")
    }
    
    /// Get voice capability description
    var voiceCapabilityDescription: String {
        if supportsVoice {
            return "Native voice support"
        } else {
            return "iOS speech wrapper"
        }
    }
}
