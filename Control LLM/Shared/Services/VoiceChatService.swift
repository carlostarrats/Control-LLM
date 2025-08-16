import Foundation
import Speech
import AVFoundation
import SwiftUI

@MainActor
final class VoiceChatService: ObservableObject {
    static let shared = VoiceChatService()
    
    @Published var isListening = false
    @Published var isTranscribing = false
    @Published var transcribedText = ""
    @Published var errorMessage: String?
    @Published var permissionGranted = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // MARK: - Task Management
    private var currentTask: Task<Void, Never>?
    
    private init() {
        checkPermissions()
    }
    
    deinit {
        print("🧹 VoiceChatService: Deinitializing")
        // Note: Cannot call @MainActor methods from deinit
        // Cleanup will be handled by explicit cleanup calls
    }
    
    // MARK: - Permissions
    
    func checkPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                self?.permissionGranted = status == .authorized
                if status != .authorized {
                    self?.errorMessage = "Speech recognition permission not granted"
                }
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            Task { @MainActor in
                if !granted {
                    self?.errorMessage = "Microphone permission not granted"
                }
            }
        }
    }
    
    // MARK: - Voice Input
    
    func startListening() async throws {
        guard permissionGranted else {
            throw VoiceChatError.permissionDenied
        }
        
        guard !isListening else {
            throw VoiceChatError.alreadyListening
        }
        
        // Reset state
        transcribedText = ""
        errorMessage = nil
        
        // Configure audio session
        try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
        try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw VoiceChatError.recognitionRequestFailed
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
        try audioEngine.start()
        
        // Start recognition
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                Task { @MainActor in
                    self.errorMessage = error.localizedDescription
                    self.stopListening()
                }
                return
            }
            
            if let result = result {
                Task { @MainActor in
                    self.transcribedText = result.bestTranscription.formattedString
                }
                
                if result.isFinal {
                    Task { @MainActor in
                        // Call the callback with the final transcription
                        self.onTranscriptionComplete?(self.transcribedText)
                        self.stopListening()
                    }
                }
            }
        }
        
        // Assign the recognition task to currentTask for proper management
        currentTask = Task {
            // Wait for recognition to complete or be cancelled
            while isListening {
                do {
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                } catch {
                    // Task was cancelled, break out of the loop
                    break
                }
            }
        }
        
        isListening = true
        print("🎤 VoiceChatService: Started listening")
    }
    
    func stopListening() {
        guard isListening else { return }
        
        // Cancel any running tasks
        currentTask?.cancel()
        currentTask = nil
        
        // Stop audio engine
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // Stop recognition
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        
        // Reset audio session
        try? AVAudioSession.sharedInstance().setActive(false)
        
        isListening = false
        print("🎤 VoiceChatService: Stopped listening")
    }
    
    // MARK: - Chat Integration
    
    // Callback for when transcription is complete
    var onTranscriptionComplete: ((String) -> Void)?
    
    func sendVoiceMessage() async throws -> String {
        guard !transcribedText.isEmpty else {
            throw VoiceChatError.noTranscribedText
        }
        
        let message = transcribedText
        transcribedText = ""
        
        print("🎤 VoiceChatService: Sending voice message: \(message)")
        return message
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        // Cancel any running tasks
        currentTask?.cancel()
        currentTask = nil
        
        stopListening()
        transcribedText = ""
        errorMessage = nil
        onTranscriptionComplete = nil // Clear callback to prevent memory leaks
    }
}

// MARK: - Error Types

enum VoiceChatError: Error, LocalizedError {
    case permissionDenied
    case alreadyListening
    case recognitionRequestFailed
    case noTranscribedText
    case audioSessionError
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Speech recognition permission not granted"
        case .alreadyListening:
            return "Already listening for voice input"
        case .recognitionRequestFailed:
            return "Failed to create speech recognition request"
        case .noTranscribedText:
            return "No transcribed text to send"
        case .audioSessionError:
            return "Failed to configure audio session"
        }
    }
}
