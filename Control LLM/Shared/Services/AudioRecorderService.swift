import Foundation
import AVFoundation
import Speech
import UIKit

@MainActor
class AudioRecorderService: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var currentPlaybackTime: TimeInterval = 0
    @Published var recordingDuration: TimeInterval = 0
    @Published var errorMessage: String?
    
    // MARK: - Audio Properties
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private var playbackTimer: Timer?
    
    // MARK: - File Management
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let audioDirectory = "WhisperRecordings"
    
    // MARK: - Speech Recognition
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    override init() {
        super.init()
        setupAudioSession()
        createAudioDirectory()
    }
    
    deinit {
        // Note: Cannot call @MainActor methods from deinit
        // Cleanup will be handled by explicit cleanup calls
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
            errorMessage = "Failed to setup audio session"
        }
    }
    
    private func createAudioDirectory() {
        let audioPath = documentsPath.appendingPathComponent(audioDirectory)
        if !FileManager.default.fileExists(atPath: audioPath.path) {
            do {
                try FileManager.default.createDirectory(at: audioPath, withIntermediateDirectories: true)
            } catch {
                print("Failed to create audio directory: \(error)")
            }
        }
    }
    
    // MARK: - Recording Functions
    func startRecording() {
        guard !isRecording else { return }
        
        // Note: Permission check would go here in production
        // For now, we'll assume permissions are granted
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(audioDirectory)/recording_\(Date().timeIntervalSince1970).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            recordingDuration = 0
            startRecordingTimer()
            
            print("Started recording to: \(audioFilename)")
        } catch {
            print("Failed to start recording: \(error)")
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
        }
    }
    
    func stopRecording() -> URL? {
        guard isRecording else { return nil }
        
        audioRecorder?.stop()
        isRecording = false
        stopRecordingTimer()
        
        let recordingURL = audioRecorder?.url
        audioRecorder = nil
        
        return recordingURL
    }
    
    private func startRecordingTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.recordingDuration += 0.1
            }
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    // MARK: - Playback Functions
    func startPlayback(url: URL) {
        guard !isPlaying else { return }
        
        // Validate file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            errorMessage = "Audio file not found"
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            isPlaying = true
            currentPlaybackTime = 0
            startPlaybackTimer()
            
        } catch {
            print("Failed to start playback: \(error)")
            errorMessage = "Failed to start playback: \(error.localizedDescription)"
        }
    }
    
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        stopPlaybackTimer()
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        currentPlaybackTime = 0
        stopPlaybackTimer()
        audioPlayer = nil
    }
    
    func seekToTime(_ time: TimeInterval) {
        guard let player = audioPlayer else { return }
        currentPlaybackTime = time
        player.currentTime = time
    }
    
    private func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                guard let player = self.audioPlayer else { return }
                self.currentPlaybackTime = player.currentTime
            }
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    // MARK: - File Management
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func getAudioDirectory() -> URL {
        getDocumentsDirectory().appendingPathComponent(audioDirectory)
    }
    
    func getAllAudioFiles() -> [URL] {
        let audioPath = getAudioDirectory()
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: audioPath, includingPropertiesForKeys: [.creationDateKey], options: [])
            return fileURLs.filter { $0.pathExtension == "m4a" }
                .sorted { url1, url2 in
                    let date1 = try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    let date2 = try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                    return date1! > date2!
                }
        } catch {
            print("Failed to get audio files: \(error)")
            return []
        }
    }
    
    func deleteAudioFile(url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            print("Failed to delete audio file: \(error)")
            errorMessage = "Failed to delete audio file"
            return false
        }
    }
    
    func getFileSize(url: URL) -> String {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            return ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
        } catch {
            return "Unknown size"
        }
    }
    
    // MARK: - Transcription Functions
    func transcribeAudio(url: URL, completion: @escaping (String?) -> Void) {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            completion(nil)
            return
        }
        
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                guard authStatus == .authorized else {
                    completion(nil)
                    return
                }
                
                self?.performTranscription(url: url, completion: completion)
            }
        }
    }
    
    private func performTranscription(url: URL, completion: @escaping (String?) -> Void) {
        guard let speechRecognizer = speechRecognizer else {
            completion(nil)
            return
        }
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        
        recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Transcription error: \(error)")
                    completion(nil)
                    return
                }
                
                if let result = result, result.isFinal {
                    completion(result.bestTranscription.formattedString)
                }
            }
        }
    }
    
    // MARK: - Utility Functions
    private func cleanupTimers() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecorderService: @preconcurrency AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            Task { @MainActor in
                self.errorMessage = "Recording failed"
            }
        }
    }
    
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            Task { @MainActor in
                self.errorMessage = "Recording error: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioRecorderService: @preconcurrency AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.isPlaying = false
            self.currentPlaybackTime = 0
            self.stopPlaybackTimer()
        }
    }
    
    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            Task { @MainActor in
                self.errorMessage = "Playback error: \(error.localizedDescription)"
            }
        }
        Task { @MainActor in
            self.isPlaying = false
            self.stopPlaybackTimer()
        }
    }
}
