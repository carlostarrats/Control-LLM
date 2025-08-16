import Foundation
import AVFoundation
@preconcurrency import AVFAudio
import SwiftUI

// Import the native bridge functions
// These functions are defined in LlamaCppBridge.mm and exposed through the bridging header

@MainActor
class Gemma3NVoiceService: ObservableObject {
    static let shared = Gemma3NVoiceService()
    
    // MARK: - Published Properties
    @Published var isListening = false
    @Published var isTranscribing = false
    @Published var transcribedText = ""
    @Published var errorMessage: String?
    @Published var permissionGranted = false
    
    // MARK: - Audio Properties
    private var audioEngine: AVAudioEngine?
    private var audioInputNode: AVAudioInputNode?
    private var audioBuffers: [AVAudioPCMBuffer] = []
    private let maxBufferCount = 50 // Limit memory usage
    private let audioBufferQueue = DispatchQueue(label: "com.controlllm.audiobuffer", qos: .userInitiated)
    
    // MARK: - Task Management
    private var currentTask: Task<Void, Never>?
    private var playbackTask: Task<Void, Never>?
    
    // MARK: - Callbacks
    var onTranscriptionComplete: ((String) -> Void)?
    var onSpeechComplete: (() -> Void)?
    
    // MARK: - Constants
    private let sampleRate: Double = 16000.0
    private let bufferSize: AVAudioFrameCount = 1024
    
    private init() {
        checkPermissions()
    }
    
    deinit {
        print("🧹 Gemma3NVoiceService: Deinitializing")
        // Note: Cannot call @MainActor methods from deinit
        // Cleanup will be handled by explicit cleanup calls
    }
    
    // MARK: - Permission Management
    
    private func checkPermissions() {
        // Check microphone permission using modern API
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                Task { @MainActor in
                    self?.permissionGranted = granted
                    if !granted {
                        self?.errorMessage = "Microphone access required for voice input"
                    }
                }
            }
        } else {
            // Fallback for older iOS versions
            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                Task { @MainActor in
                    self?.permissionGranted = granted
                    if !granted {
                        self?.errorMessage = "Microphone access required for voice input"
                    }
                }
            }
        }
    }
    
    // MARK: - Voice Input Methods
    
    /// Start listening for voice input using Gemma-3N's native capabilities
    func startListening() async throws {
        guard permissionGranted else {
            throw VoiceError.permissionDenied
        }
        
        guard !isListening else {
            print("🎤 Gemma3NVoiceService: Already listening")
            return
        }
        
        print("🎤 Gemma3NVoiceService: Starting native voice input")
        
        // Configure audio session for recording
        try configureAudioSession()
        
        // Initialize audio engine
        try setupAudioEngine()
        
        // Start audio processing
        try startAudioProcessing()
        
        isListening = true
        isTranscribing = true
        transcribedText = ""
        errorMessage = nil
        
        print("✅ Gemma3NVoiceService: Native voice input started")
    }
    
    /// Stop listening and process the voice input
    func stopListening() {
        guard isListening else { return }
        
        print("🔇 Gemma3NVoiceService: Stopping native voice input")
        
        // Cancel any running tasks
        currentTask?.cancel()
        currentTask = nil
        playbackTask?.cancel()
        playbackTask = nil
        
        // Stop audio processing
        stopAudioProcessing()
        
        // Process the collected audio with Gemma-3N
        processAudioWithGemma3N()
        
        isListening = false
    }
    
    // MARK: - Audio Configuration
    
    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    private func setupAudioEngine() throws {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            throw VoiceError.audioEngineSetupFailed
        }
        
        audioInputNode = audioEngine.inputNode
        guard let audioInputNode = audioInputNode else {
            throw VoiceError.audioInputNodeNotFound
        }
        
        // Configure audio format for Gemma-3N (16kHz, mono, 32-bit float)
        let audioFormat = AVAudioFormat(
            standardFormatWithSampleRate: sampleRate,
            channels: 1
        )
        
        guard let audioFormat = audioFormat else {
            throw VoiceError.audioFormatUnsupported
        }
        
        // Install tap on input node to capture audio
        audioInputNode.installTap(onBus: 0, bufferSize: bufferSize, format: audioFormat) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }
        
        // Prepare audio engine
        audioEngine.prepare()
    }
    
    private func startAudioProcessing() throws {
        guard let audioEngine = audioEngine else {
            throw VoiceError.audioEngineNotInitialized
        }
        
        try audioEngine.start()
        print("🎤 Gemma3NVoiceService: Audio engine started")
    }
    
    private func stopAudioProcessing() {
        audioEngine?.stop()
        audioInputNode?.removeTap(onBus: 0)
        
        // Clear audio buffers to free memory
        cleanupAudioBuffers()
        
        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        
        print("🔇 Gemma3NVoiceService: Audio processing stopped")
    }
    
    private func cleanupAudioBuffers() {
        // Use serial queue to prevent race conditions
        audioBufferQueue.sync {
            // Ensure all audio buffers are properly released
            for buffer in audioBuffers {
                // Force release of buffer data
                buffer.frameLength = 0
            }
            audioBuffers.removeAll()
            print("🧹 Gemma3NVoiceService: Audio buffers cleaned up")
        }
    }
    
    // MARK: - Audio Processing
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // Store audio buffer for processing with Gemma-3N
        // In a real implementation, this would send audio data to the model
        
        // Use serial queue to prevent race conditions
        audioBufferQueue.async {
            Task { @MainActor in
                // Add buffer to collection (with memory management)
                if self.audioBuffers.count < self.maxBufferCount {
                    self.audioBuffers.append(buffer)
                } else {
                    // Remove oldest buffer to maintain memory limit
                    self.audioBuffers.removeFirst()
                    self.audioBuffers.append(buffer)
                }
                
                // Log buffer collection for debugging (only in debug builds)
                #if DEBUG
                print("🎤 Gemma3NVoiceService: Collected audio buffer, total: \(self.audioBuffers.count)")
                #endif
                
                // Trigger processing when we have enough buffers or when we reach max capacity
                if self.audioBuffers.count >= self.maxBufferCount {
                    print("🎤 Gemma3NVoiceService: Buffer limit reached, triggering processing")
                    self.processAudioWithGemma3N()
                } else if self.audioBuffers.count >= 10 {
                    // Also process when we have a reasonable amount of audio (10+ buffers)
                    // This ensures shorter voice inputs get processed
                    print("🎤 Gemma3NVoiceService: Sufficient audio collected (\(self.audioBuffers.count) buffers), triggering processing")
                    self.processAudioWithGemma3N()
                }
            }
        }
    }
    

    
    private func processAudioWithGemma3N() {
        // Process collected audio buffers with Gemma-3N's native voice recognition
        Task { @MainActor in
            print("🤖 Gemma3NVoiceService: Processing \(self.audioBuffers.count) audio buffers with Gemma-3N")
            
            guard !self.audioBuffers.isEmpty else {
                print("❌ Gemma3NVoiceService: No audio buffers to process")
                self.isTranscribing = false
                self.cleanupAudioBuffers()
                return
            }
            
            // Use the new audio conversion function
            let audioData = self.convertAudioBuffersToFloatArray()
            
            guard !audioData.isEmpty else {
                print("❌ Gemma3NVoiceService: No audio data to process")
                self.isTranscribing = false
                self.cleanupAudioBuffers()
                return
            }
        
            print("🎤 Gemma3NVoiceService: Sending \(audioData.count) audio samples to Gemma-3N")
            
            // Process audio with Gemma-3N's native voice recognition
            // Since we're already on MainActor, we can assign directly
            self.currentTask = Task {
                do {
                    let transcription = try await self.processAudioWithNativeVoice(audioData)
                    
                    await MainActor.run {
                        self.transcribedText = transcription
                        self.isTranscribing = false
                        
                        // Clear audio buffers after processing
                        self.cleanupAudioBuffers()
                        
                        // Notify that transcription is complete
                        self.onTranscriptionComplete?(transcription)
                    }
                    
                } catch {
                    print("❌ Gemma3NVoiceService: Voice recognition failed: \(error)")
                    
                    await MainActor.run {
                        self.errorMessage = "Voice recognition failed: \(error.localizedDescription)"
                        self.isTranscribing = false
                        self.cleanupAudioBuffers()
                    }
                }
            }
        }
    }
    
    /// Convert collected audio buffers to float array for native processing
    private func convertAudioBuffersToFloatArray() -> [Float] {
        var audioData: [Float] = []
        
        // Use serial queue to prevent race conditions
        audioBufferQueue.sync {
            for buffer in audioBuffers {
                guard let channelData = buffer.floatChannelData else { continue }
                
                // Get the first channel (mono) or mix all channels
                let channelCount = Int(buffer.format.channelCount)
                let frameCount = Int(buffer.frameLength)
                
                if channelCount == 1 {
                    // Mono audio - copy directly
                    for i in 0..<frameCount {
                        audioData.append(channelData[0][i])
                    }
                } else {
                    // Multi-channel audio - mix to mono
                    for i in 0..<frameCount {
                        var sample: Float = 0
                        for channel in 0..<channelCount {
                            sample += channelData[channel][i]
                        }
                        sample /= Float(channelCount) // Average the channels
                        audioData.append(sample)
                    }
                }
            }
        }
        
        print("🎤 Gemma3NVoiceService: Converted \(audioData.count) float samples from audio buffers")
        return audioData
    }
    
    private func processAudioWithNativeVoice(_ audioData: [Float]) async throws -> String {
        // Call the native llama.cpp bridge to process audio with Gemma-3N
        print("🤖 Gemma3NVoiceService: Calling native voice recognition for \(audioData.count) audio samples")
        
        // Convert Swift array to C array for bridge call
        let audioDataPointer = UnsafeMutablePointer<Float>.allocate(capacity: audioData.count)
        defer { audioDataPointer.deallocate() }
        
        // Copy audio data to C array
        for (index, sample) in audioData.enumerated() {
            audioDataPointer[index] = sample
        }
        
        // Prepare output buffer
        let maxOutputLength = 1024
        let outputBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: maxOutputLength)
        defer { outputBuffer.deallocate() }
        
        // Call native bridge function
        let result = llm_bridge_process_audio_voice_recognition(
            audioDataPointer,
            Int32(audioData.count),
            outputBuffer,
            Int32(maxOutputLength)
        )
        
        guard result > 0 else {
            print("❌ Gemma3NVoiceService: Native voice recognition failed with result: \(result)")
            throw VoiceError.voiceRecognitionFailed
        }
        
        // Convert C string back to Swift string
        let transcription = String(cString: outputBuffer)
        print("✅ Gemma3NVoiceService: Native voice recognition completed: '\(transcription)'")
        
        return transcription
    }
    

    
    private func generateSpeechWithNativeVoice(_ text: String) async throws -> [Float] {
        // Call the native llama.cpp bridge to generate speech with Gemma-3N
        print("🤖 Gemma3NVoiceService: Calling native speech synthesis for text: '\(text)'")
        
        // Prepare output buffer for audio data
        let maxAudioLength = 16000 * 10 // 10 seconds at 16kHz
        let audioOutputBuffer = UnsafeMutablePointer<Float>.allocate(capacity: maxAudioLength)
        defer { audioOutputBuffer.deallocate() }
        
        // Prepare output parameter for actual audio length
        var actualAudioLength: Int32 = 0
        
        // Call native bridge function
        let result = llm_bridge_generate_speech_synthesis(
            text,
            audioOutputBuffer,
            Int32(maxAudioLength),
            &actualAudioLength
        )
        
        guard result > 0 else {
            print("❌ Gemma3NVoiceService: Native speech synthesis failed with result: \(result)")
            throw VoiceError.speechSynthesisFailed
        }
        
        guard actualAudioLength > 0 else {
            print("❌ Gemma3NVoiceService: No audio data generated from speech synthesis")
            throw VoiceError.speechSynthesisFailed
        }
        
        // Convert C array back to Swift array
        var audioData: [Float] = []
        for i in 0..<Int(actualAudioLength) {
            audioData.append(audioOutputBuffer[i])
        }
        
        print("✅ Gemma3NVoiceService: Native speech synthesis completed, generated \(audioData.count) audio samples")
        
        return audioData
    }
    
    private func playGeneratedAudio(_ audioData: [Float]) async {
        // Play the generated audio using AVAudioEngine
        print("🔊 Gemma3NVoiceService: Playing generated audio (\(audioData.count) samples)")
        
        guard !audioData.isEmpty else {
            print("⚠️ Gemma3NVoiceService: No audio data to play")
            return
        }
        
        do {
            // Set up audio session for playback
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            
            // Create audio format for playback (16kHz, mono, 32-bit float)
            let sampleRate: Double = 16000.0
            let channels: AVAudioChannelCount = 1
            let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channels)
            
            guard let audioFormat = format else {
                print("❌ Gemma3NVoiceService: Failed to create audio format")
                return
            }
            
            // Create audio buffer from float array
            let frameCount = AVAudioFrameCount(audioData.count)
            let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCount)!
            audioBuffer.frameLength = frameCount
            
            // Copy float data to buffer
            let channelData = audioBuffer.floatChannelData![0]
            for (index, sample) in audioData.enumerated() {
                channelData[index] = sample
            }
            
            // Set up audio engine for playback
            let playbackEngine = AVAudioEngine()
            let outputNode = playbackEngine.outputNode
            let inputFormat = outputNode.inputFormat(forBus: 0)
            
            // Create a player node to handle the audio buffer
            let playerNode = AVAudioPlayerNode()
            playbackEngine.attach(playerNode)
            
            // Connect player to output
            playbackEngine.connect(playerNode, to: outputNode, format: inputFormat)
            
            // Prepare and start playback engine
            playbackEngine.prepare()
            try playbackEngine.start()
            
            // Schedule the audio buffer for playback with completion handler
            playerNode.scheduleBuffer(audioBuffer, at: nil, options: [], completionHandler: {
                print("✅ Gemma3NVoiceService: Audio buffer playback completed")
                
                // Stop and clean up playback engine
                playbackEngine.stop()
                
                // Notify speech completion
                Task { @MainActor in
                    self.onSpeechComplete?()
                }
            })
            
            // Start playing the audio
            playerNode.play()
            
            print("✅ Gemma3NVoiceService: Audio playback started")
            
            // Wait for playback to complete (with timeout)
            let playbackDuration = Double(audioData.count) / 16000.0 // Duration in seconds
            let timeoutDuration = playbackDuration + 1.0 // Add 1 second buffer
            
            try await Task.sleep(nanoseconds: UInt64(timeoutDuration * 1_000_000_000))
            
            // If we reach here, playback should have completed via completion handler
            // But if not, clean up anyway
            if playbackEngine.isRunning {
                playbackEngine.stop()
                print("⚠️ Gemma3NVoiceService: Playback timeout, forcing cleanup")
            }
            
        } catch {
            print("❌ Gemma3NVoiceService: Audio playback failed: \(error)")
            
            // Notify speech completion even on error
            await MainActor.run {
                self.onSpeechComplete?()
            }
        }
    }
    
    // MARK: - Speech Synthesis
    
    /// Speak the given text using Gemma-3N's native speech synthesis
    func speak(_ text: String) {
        guard !text.isEmpty else { return }
        
        print("🗣️ Gemma3NVoiceService: Starting native speech synthesis for: '\(text)'")
        
        // Cancel any existing playback task
        playbackTask?.cancel()
        playbackTask = nil
        
        // Start speech synthesis in background
        playbackTask = Task {
            do {
                // Generate speech using native voice synthesis
                let audioData = try await generateSpeechWithNativeVoice(text)
                
                // Play the generated audio
                await playGeneratedAudio(audioData)
                
            } catch {
                print("❌ Gemma3NVoiceService: Speech synthesis failed: \(error)")
                
                // Notify completion even on error
                await MainActor.run {
                    self.onSpeechComplete?()
                }
            }
        }
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        // Cancel all running tasks
        currentTask?.cancel()
        currentTask = nil
        playbackTask?.cancel()
        playbackTask = nil
        
        stopListening()
        transcribedText = ""
        errorMessage = nil
        onTranscriptionComplete = nil
        onSpeechComplete = nil
        
        // Force cleanup of audio resources
        audioEngine?.stop()
        audioEngine = nil
        audioInputNode = nil
        
        // Final cleanup of audio buffers
        cleanupAudioBuffers()
        
        print("🧹 Gemma3NVoiceService: Cleanup completed")
    }
}

// MARK: - Error Types

enum VoiceError: Error, LocalizedError {
    case permissionDenied
    case audioEngineSetupFailed
    case audioInputNodeNotFound
    case audioFormatUnsupported
    case audioEngineNotInitialized
    case voiceRecognitionFailed
    case speechSynthesisFailed
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Microphone permission denied"
        case .audioEngineSetupFailed:
            return "Failed to setup audio engine"
        case .audioInputNodeNotFound:
            return "Audio input node not found"
        case .audioFormatUnsupported:
            return "Audio format not supported"
        case .audioEngineNotInitialized:
            return "Audio engine not initialized"
        case .voiceRecognitionFailed:
            return "Voice recognition failed"
        case .speechSynthesisFailed:
            return "Speech synthesis failed"
        }
    }
}
