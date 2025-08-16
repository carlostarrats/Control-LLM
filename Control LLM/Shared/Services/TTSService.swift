import Foundation
import AVFoundation

/// Simple TTS service that exposes installed iOS voices and stores a selected voice.
final class TTSService: ObservableObject {
    static let shared = TTSService()

    @Published private(set) var selectedVoiceIdentifier: String?

    private let synthesizer = AVSpeechSynthesizer()
    private let userDefaults = UserDefaults.standard
    private let selectedVoiceKey = "selected_voice_identifier"

    private init() {
        selectedVoiceIdentifier = userDefaults.string(forKey: selectedVoiceKey)
        
        // If no voice is selected, automatically select the first available English voice
        if selectedVoiceIdentifier == nil {
            if let englishVoice = availableVoices().first(where: { $0.language.starts(with: "en") }) {
                selectedVoiceIdentifier = englishVoice.identifier
                userDefaults.set(englishVoice.identifier, forKey: selectedVoiceKey)
            }
        }
    }

    func availableVoices() -> [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .sorted { ($0.language, $0.name) < ($1.language, $1.name) }
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


