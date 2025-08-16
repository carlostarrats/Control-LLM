import Foundation
import Speech
import AVFoundation
import SwiftUI

@MainActor
class VoiceService: NSObject, ObservableObject {
    static let shared = VoiceService()
    
    // MARK: - Published Properties
    @Published var isListening = false
    @Published var isProcessing = false
    @Published var transcribedText = ""
    @Published var errorMessage: String?
    
    // MARK: - Speech Recognition
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // MARK: - Text-to-Speech
    private let synthesizer = AVSpeechSynthesizer()
    
    // MARK: - Silence Detection
    private var silenceTimer: Timer?
    private let silenceThreshold: TimeInterval = 3.0 // 3 seconds of silence
    
    // MARK: - Callbacks
    var onTranscriptionComplete: ((String) -> Void)?
    var onSpeechComplete: (() -> Void)?
    
    private override init() {
        super.init()
        setupSpeechRecognition()
        setupTextToSpeech()
    }
    
    // MARK: - Setup Methods
    
    private func setupSpeechRecognition() {
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            Task { @MainActor in
                switch authStatus {
                case .authorized:
                    print("✅ VoiceService: Speech recognition authorized")
                case .denied:
                    self?.errorMessage = "Speech recognition access denied"
                case .restricted:
                    self?.errorMessage = "Speech recognition restricted on this device"
                case .notDetermined:
                    self?.errorMessage = "Speech recognition not determined"
                @unknown default:
                    self?.errorMessage = "Speech recognition authorization unknown"
                }
            }
        }
    }
    
    private func setupTextToSpeech() {
        synthesizer.delegate = self
    }
    
    // MARK: - Public Methods
    
    /// Start listening for voice input
    func startListening() {
        guard !isListening else { return }
        
        // Reset state
        transcribedText = ""
        errorMessage = nil
        
        // Request microphone permission using modern API
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                Task { @MainActor in
                    if granted {
                        self?.startSpeechRecognition()
                    } else {
                        self?.errorMessage = "Microphone access denied"
                    }
                }
            }
        } else {
            // Fallback for older iOS versions
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                Task { @MainActor in
                    if granted {
                        self?.startSpeechRecognition()
                    } else {
                        self?.errorMessage = "Microphone access denied"
                    }
                }
            }
        }
    }
    
    /// Stop listening and processing
    func stopListening() {
        stopSpeechRecognition()
        stopSilenceTimer()
        isListening = false
        isProcessing = false
    }
    
    /// Speak the given text
    func speak(_ text: String, language: String = "en-US") {
        guard !text.isEmpty else { return }
        
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        // Create utterance
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Speak
        synthesizer.speak(utterance)
    }
    
    /// Get the language code for speech recognition based on selected language
    func getSpeechRecognitionLanguage(for language: String) -> String {
        switch language {
        case "English": return "en-US"
        case "Spanish": return "es-ES"
        case "French": return "fr-FR"
        case "German": return "de-DE"
        case "Italian": return "it-IT"
        case "Portuguese": return "pt-PT"
        case "Korean": return "ko-KR"
        case "Japanese": return "ja-JP"
        case "Dutch": return "nl-NL"
        case "Russian": return "ru-RU"
        case "Arabic": return "ar-SA"
        case "Chinese (Simplified)": return "zh-CN"
        case "Chinese (Traditional)": return "zh-TW"
        default: return "en-US"
        }
    }
    
    // MARK: - Private Methods
    
    private func startSpeechRecognition() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition not available"
            return
        }
        
        // Configure audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Failed to configure audio session: \(error.localizedDescription)"
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Failed to create recognition request"
            return
        }
        recognitionRequest.shouldReportPartialResults = true
        
        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            errorMessage = "Failed to start audio engine: \(error.localizedDescription)"
            return
        }
        
        // Start recognition
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Recognition error: \(error.localizedDescription)"
                    self?.stopSpeechRecognition()
                    return
                }
                
                if let result = result {
                    let transcribedText = result.bestTranscription.formattedString
                    self?.transcribedText = transcribedText
                    
                    // Check for silence (no new transcription for 3 seconds)
                    self?.resetSilenceTimer()
                    
                    // If final result, complete transcription
                    if result.isFinal {
                        self?.onTranscriptionComplete?(transcribedText)
                        self?.stopSpeechRecognition()
                    }
                }
            }
        }
        
        isListening = true
        print("🎤 VoiceService: Started listening")
    }
    
    private func stopSpeechRecognition() {
        // Stop audio engine
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // Stop recognition
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        // Reset
        recognitionRequest = nil
        recognitionTask = nil
        
        isListening = false
        print("🎤 VoiceService: Stopped listening")
    }
    
    private func resetSilenceTimer() {
        stopSilenceTimer()
        
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceThreshold, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.handleSilenceDetected()
            }
        }
    }
    
    private func stopSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = nil
    }
    
    private func handleSilenceDetected() {
        guard isListening else { return }
        
        print("🔇 VoiceService: Silence detected, processing transcription")
        isProcessing = true
        
        // Complete transcription if we have text
        if !transcribedText.isEmpty {
            onTranscriptionComplete?(transcribedText)
        }
        
        // Stop listening
        stopSpeechRecognition()
    }
}

// MARK: - SFSpeechRecognizerDelegate

extension VoiceService: SFSpeechRecognizerDelegate {
    nonisolated func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        Task { @MainActor in
            if !available {
                self.errorMessage = "Speech recognition became unavailable"
                self.stopListening()
            }
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension VoiceService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.onSpeechComplete?()
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.onSpeechComplete?()
        }
    }
}
