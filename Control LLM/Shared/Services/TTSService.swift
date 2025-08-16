import Foundation
import AVFoundation

/// Simple TTS service that exposes installed iOS voices and stores a selected voice.
final class TTSService: ObservableObject {
    static let shared = TTSService()

    @Published private(set) var selectedVoiceIdentifier: String?
    @Published private(set) var availableVoices: [AVSpeechSynthesisVoice] = []

    private let synthesizer = AVSpeechSynthesizer()
    private let userDefaults = UserDefaults.standard
    private let selectedVoiceKey = "selected_voice_identifier"
    private var voicesLoaded = false

    private init() {
        selectedVoiceIdentifier = userDefaults.string(forKey: selectedVoiceKey)
        loadAvailableVoices()
        
        // If no voice is selected, automatically select the first available English voice
        if selectedVoiceIdentifier == nil {
            if let englishVoice = availableVoices.first(where: { $0.language.starts(with: "en") }) {
                selectedVoiceIdentifier = englishVoice.identifier
                userDefaults.set(englishVoice.identifier, forKey: selectedVoiceKey)
            }
        }
    }

    private func loadAvailableVoices() {
        guard !voicesLoaded else { return }
        
        // Get all available voices
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        // Filter for only pre-installed system voices
        let systemVoices = allVoices.filter { voice in
            // Only include voices that are:
            // 1. Built-in system voices (not third-party or downloadable)
            // 2. Have a valid identifier that starts with "com.apple.ttsbundle"
            // 3. Are not marked as requiring download
            
            // Check if it's a built-in Apple voice bundle
            let isSystemVoice = voice.identifier.hasPrefix("com.apple.ttsbundle")
            
            // Additional safety check - ensure it's not a downloadable voice
            let isNotDownloadable = !voice.identifier.contains("download") && 
                                   !voice.identifier.contains("Download") &&
                                   !voice.identifier.contains("premium") &&
                                   !voice.identifier.contains("Premium")
            
            return isSystemVoice && isNotDownloadable
        }
        
        // Sort by language and name for consistent display
        availableVoices = systemVoices.sorted { ($0.language, $0.name) < ($1.language, $1.name) }
        voicesLoaded = true
    }

    func refreshAvailableVoices() {
        voicesLoaded = false
        loadAvailableVoices()
    }

    func setSelectedVoice(identifier: String?) {
        selectedVoiceIdentifier = identifier
        if let id = identifier {
            userDefaults.set(id, forKey: selectedVoiceKey)
        } else {
            userDefaults.removeObject(forKey: selectedVoiceKey)
        }
    }

    func speak(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let utterance = AVSpeechUtterance(string: text)
        if let id = selectedVoiceIdentifier, let voice = AVSpeechSynthesisVoice(identifier: id) {
            utterance.voice = voice
        }
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }
}


