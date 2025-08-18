import SwiftUI
import AVFoundation
import Speech
import UIKit

struct WhisperView: View {
    @Binding var showingTextModal: Bool
    @ObservedObject var mainViewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isRecording = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var recordingStartTime: Date?
    @State private var expandedItemId: String? = nil
    
    // New services
    @StateObject var audioRecorderService = AudioRecorderService()
    @StateObject var transcriptionService = TranscriptionService()
    
    // MARK: - Lifecycle and Data Management
    private func loadExistingRecordings() {
        let audioFiles = audioRecorderService.getAllAudioFiles()
        whisperItems = audioFiles.compactMap { audioURL in
            guard let attributes = try? FileManager.default.attributesOfItem(atPath: audioURL.path),
                  let creationDate = attributes[.creationDate] as? Date,
                  let fileSize = attributes[.size] as? Int64 else {
                return nil
            }
            
            // Check if transcription exists
            let transcriptionURL = transcriptionService.getTranscriptionFileURL(for: audioURL)
            let hasTranscription = FileManager.default.fileExists(atPath: transcriptionURL.path)
            
            return WhisperItem(
                id: audioURL.lastPathComponent,
                title: "\(creationDate.formatted(date: .abbreviated, time: .shortened))",
                content: "Audio recording",
                expandedContent: "Audio recording captured on \(creationDate.formatted())",
                timestamp: creationDate,
                duration: 0, // Will be updated when played
                transcriptionProgress: 0.0,
                isTranscribing: false,
                isTranscribed: hasTranscription,
                audioFileURL: audioURL,
                transcriptionText: nil,
                transcriptionFileURL: hasTranscription ? transcriptionURL : nil,
                fileSize: ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
            )
        }
    }
    
    private func saveRecordingToDisk(audioURL: URL, duration: TimeInterval) {
        // Create WhisperItem for the new recording
        let newRecording = WhisperItem(
            id: audioURL.lastPathComponent,
            title: "\(Date().formatted(date: .abbreviated, time: .shortened))",
            content: "Audio recording",
            expandedContent: "Audio recording captured on \(Date().formatted())",
            timestamp: Date(),
            duration: duration,
            transcriptionProgress: 0.0,
            isTranscribing: false,
            isTranscribed: false,
            audioFileURL: audioURL,
            transcriptionText: nil,
            transcriptionFileURL: nil,
            fileSize: audioRecorderService.getFileSize(url: audioURL)
        )
        
        // Add to the beginning of the list
        whisperItems.insert(newRecording, at: 0)
        
        // Save to UserDefaults for persistence
        saveWhisperItemsToUserDefaults()
    }
    
    private func saveWhisperItemsToUserDefaults() {
        // Convert WhisperItems to a serializable format
        let serializableItems = whisperItems.map { item in
            [
                "id": item.id,
                "title": item.title,
                "content": item.content,
                "expandedContent": item.expandedContent,
                "timestamp": item.timestamp.timeIntervalSince1970,
                "duration": item.duration,
                "audioFileURL": item.audioFileURL?.path ?? "",
                "transcriptionText": item.transcriptionText ?? "",
                "transcriptionFileURL": item.transcriptionFileURL?.path ?? "",
                "fileSize": item.fileSize ?? "",
                "isTranscribed": item.isTranscribed
            ]
        }
        
        UserDefaults.standard.set(serializableItems, forKey: "WhisperItems")
    }
    
    private func loadWhisperItemsFromUserDefaults() {
        guard let serializableItems = UserDefaults.standard.array(forKey: "WhisperItems") as? [[String: Any]] else {
            return
        }
        
        whisperItems = serializableItems.compactMap { dict in
            guard let id = dict["id"] as? String,
                  let title = dict["title"] as? String,
                  let content = dict["content"] as? String,
                  let expandedContent = dict["expandedContent"] as? String,
                  let timestamp = dict["timestamp"] as? TimeInterval,
                  let duration = dict["duration"] as? TimeInterval else {
                return nil
            }
            
            let audioFileURL = (dict["audioFileURL"] as? String).flatMap { URL(fileURLWithPath: $0) }
            let transcriptionText = dict["transcriptionText"] as? String
            let transcriptionFileURL = (dict["transcriptionFileURL"] as? String).flatMap { URL(fileURLWithPath: $0) }
            let fileSize = dict["fileSize"] as? String
            let isTranscribed = dict["isTranscribed"] as? Bool ?? false
            
            // Verify the audio file still exists
            if let audioURL = audioFileURL, !FileManager.default.fileExists(atPath: audioURL.path) {
                return nil
            }
            
            return WhisperItem(
                id: id,
                title: title,
                content: content,
                expandedContent: expandedContent,
                timestamp: Date(timeIntervalSince1970: timestamp),
                duration: duration,
                transcriptionProgress: 0.0,
                isTranscribing: false,
                isTranscribed: isTranscribed,
                audioFileURL: audioFileURL,
                transcriptionText: transcriptionText,
                transcriptionFileURL: transcriptionFileURL,
                fileSize: fileSize
            )
        }
    }

    @State private var whisperItems: [WhisperItem] = []
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "#1D1D1D"),  // Lighter color at top
                    Color(hex: "#141414")   // Darker color at bottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 8) {
                    // Test duration and record button
                    HStack {
                        Text(formatTime(elapsedTime))
                            .font(.custom("IBMPlexMono", size: 48))
                            .foregroundColor(Color.red)
                        
                        Spacer()
                            .frame(width: UIScreen.main.bounds.width * 0.15) // 15% of screen width for spacing
                        
                        // Record/Stop button (acts as test button for audio visualization)
                        Button(action: toggleRecording) {
                            Group {
                                if isRecording {
                                    // Stop button - circle with square inside, matching record button style
                                    ZStack {
                                        // Outer circle (3px gap from inner) - same as record button
                                        Circle()
                                            .stroke(Color(hex: "#CC3333"), lineWidth: 2)
                                            .frame(width: 46, height: 46)
                                        
                                        // Inner square - traditional red, no corner radius
                                        Rectangle()
                                            .fill(Color.red)
                                            .frame(width: 20, height: 20)
                                    }
                                } else {
                                    // Circle for record - traditional red
                                    ZStack {
                                        // Outer circle (3px gap from inner)
                                        Circle()
                                            .stroke(Color(hex: "#CC3333"), lineWidth: 2)
                                            .frame(width: 46, height: 46)
                                        
                                        // Inner red circle - traditional red
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 40, height: 40)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 2)
                    
                    // Audio level meters and equalizer
                    HStack(spacing: 10) {
                        AudioLevelMeter(
                            title: "INPUT",
                            isOutput: false,
                            isRecording: $isRecording
                        )
                        
                        AdvancedEqualizerView(isSpeaking: $isRecording)
                            .frame(height: 200)
                        
                        AudioLevelMeter(
                            title: "OUTPUT",
                            isOutput: true,
                            isRecording: $isRecording
                        )
                    }
                    .padding(.bottom, 20)
                    

                    
                    // Audio header
                    HStack {
                        Image(systemName: "speaker.wave.2")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#EEEEEE"))
                        
                        Text("All Audio")
                            .font(.custom("IBMPlexMono", size: 16))
                            .foregroundColor(Color(hex: "#EEEEEE"))
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Audio recordings list
                    VStack(spacing: 20) {
                        if whisperItems.isEmpty {
                            // Placeholder text when no audio recordings exist
                            HStack {
                                Text("No Saved Audio")
                                    .font(.custom("IBMPlexMono", size: 16))
                                    .foregroundColor(Color(hex: "#666666"))
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            ForEach($whisperItems, id: \.id) { $item in
                                WhisperItemView(
                                    item: $item, 
                                    formatDate: formatDate,
                                    formatDuration: formatDuration,
                                    isExpanded: expandedItemId == item.id,
                                    onExpand: { itemId in
                                        if expandedItemId == itemId {
                                            // If clicking the same item, close it
                                            expandedItemId = nil
                                        } else {
                                            // If clicking a different item, switch to it
                                            expandedItemId = itemId
                                        }
                                    },
                                    onDelete: {
                                        // Remove the item from the array
                                        if let index = whisperItems.firstIndex(where: { $0.id == item.id }) {
                                            whisperItems.remove(at: index)
                                            // Save updated list to UserDefaults
                                            saveWhisperItemsToUserDefaults()
                                        }
                                    },
                                    onItemUpdated: {
                                        // Save updated item to UserDefaults
                                        saveWhisperItemsToUserDefaults()
                                    },
                                    audioRecorderService: audioRecorderService,
                                    transcriptionService: transcriptionService
                                )
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
            }
            
            .safeAreaInset(edge: .top) {
                // iOS standard header overlay
                VStack(spacing: 0) {
                    // Grab bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(hex: "#666666"))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
                    // Header
                    HStack {
                        HStack(spacing: 0) {
                            Image(systemName: "waveform")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .animation(nil, value: true)
                                .padding(.trailing, 8)
                            
                            Text("Whisper")
                                .font(.custom("IBMPlexMono", size: 20))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                        }
                        
                        Spacer()

                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    
                    // Buffer space below header
                    Spacer()
                        .frame(height: 18)
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
        .onAppear {
            // Load existing recordings from disk and UserDefaults
            loadExistingRecordings()
            loadWhisperItemsFromUserDefaults()
        }
        .onDisappear {
            // Save current state to UserDefaults
            saveWhisperItemsToUserDefaults()
            
            // Stop recording if sheet is dismissed while recording
            if isRecording {
                timer?.invalidate()
                timer = nil
                isRecording = false
                _ = audioRecorderService.stopRecording()
            }
        }

    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func toggleRecording() {
        if isRecording {
            // Stop recording
            FeedbackService.shared.playSound(.endRecord)
            timer?.invalidate()
            timer = nil
            isRecording = false
            
            // Stop recording using the service
            if let recordingURL = audioRecorderService.stopRecording() {
                // Save the recording to disk with persistence
                saveRecordingToDisk(audioURL: recordingURL, duration: elapsedTime)
            }
            
            // Reset elapsed time for next recording
            elapsedTime = 0
        } else {
            // Start recording using the service
            audioRecorderService.startRecording()
            FeedbackService.shared.playSound(.beginRecord)
            isRecording = true
            recordingStartTime = Date()
            elapsedTime = 0
            
            // Start timer immediately
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if let startTime = self.recordingStartTime {
                    self.elapsedTime = Date().timeIntervalSince(startTime)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let today = Date()
        let daysDiff = calendar.dateComponents([.day], from: date, to: today).day ?? 0
        
        let dateFormatter = DateFormatter()
        
        if daysDiff == 0 {
            return "TODAY"
        } else if daysDiff == 1 {
            return "YESTERDAY"
        } else if daysDiff <= 7 {
            // Last 7 days: "THURSDAY, DEC 23"
            dateFormatter.dateFormat = "EEEE, MMM d"
            return dateFormatter.string(from: date).uppercased()
        } else {
            // Past 7 days: "DEC 15"
            dateFormatter.dateFormat = "MMM d"
            return dateFormatter.string(from: date).uppercased()
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    

    

}

struct WhisperItem: Identifiable {
    let id: String
    var title: String
    let content: String
    let expandedContent: String
    let timestamp: Date
    let duration: TimeInterval
    var transcriptionProgress: Double = 0.0
    var isTranscribing: Bool = false
    var isTranscribed: Bool = false
    
    // New properties for enhanced functionality
    var audioFileURL: URL?
    var transcriptionText: String?
    var transcriptionFileURL: URL?
    var fileSize: String?
}

struct WhisperItemView: View {
    @Binding var item: WhisperItem
    let formatDate: (Date) -> String
    let formatDuration: (TimeInterval) -> String
    let isExpanded: Bool
    let onExpand: (String) -> Void
    let onDelete: () -> Void
    let onItemUpdated: () -> Void
    let audioRecorderService: AudioRecorderService
    let transcriptionService: TranscriptionService
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var playbackTimer: Timer?
    @State private var isDragging = false
    @State private var isPressed = false
    @State private var isEditingTitle = false
    @State private var editedTitle = ""
    @State private var showingWhisperOptions = false
    @State private var showingDeleteSheet = false
    @State private var transcriptionTimer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            // 1px line above summary
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(height: 1)
            
            // 4px spacing under the line
            Spacer()
                .frame(height: 4)
            
            // Main title (clickable)
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    // Title container with fixed height to prevent layout shifts
                    ZStack(alignment: .leading) {
                        // Background placeholder to maintain consistent height
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 40)
                        
                        if isEditingTitle {
                            TextField("Enter title", text: $editedTitle)
                                .font(.custom("IBMPlexMono", size: 16))
                                .foregroundColor(Color(hex: "#EEEEEE"))
                                .textFieldStyle(PlainTextFieldStyle())
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 0)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 40)
                                .onSubmit {
                                    item.title = editedTitle
                                    isEditingTitle = false
                                    onItemUpdated()
                                }
                                .onAppear {
                                    editedTitle = item.title
                                }
                        } else {
                            Text(item.title)
                                .font(.custom("IBMPlexMono", size: 16))
                                .foregroundColor(Color(hex: "#EEEEEE"))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 0)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 40)
                                .onTapGesture {
                                    if isExpanded {
                                        isEditingTitle = true
                                    } else {
                                        onExpand(item.id)
                                    }
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 40) // Fixed height to prevent layout shifts
                    
                    // Date
                    Text(formatDate(item.timestamp))
                        .font(.custom("IBMPlexMono", size: 10))
                        .foregroundColor(ColorManager.shared.orangeColor)
                    
                    // Recording time under the date
                    Text(formatDuration(item.duration))
                        .font(.custom("IBMPlexMono", size: 10))
                        .foregroundColor(ColorManager.shared.redColor)
                    
                    // File size display
                    if let fileSize = item.fileSize {
                        Text(fileSize)
                            .font(.custom("IBMPlexMono", size: 8))
                            .foregroundColor(Color(hex: "#888888"))
                    }
                }
                
                // Arrow indicator
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "#BBBBBB"))
                    .padding(.trailing, 8)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if isEditingTitle {
                    // Do nothing when editing
                } else if isExpanded {
                    // When expanded, close the item (except when tapping on the title text)
                    onExpand(item.id)
                } else {
                    // When closed, open the item
                    onExpand(item.id)
                }
            }
                
                // Expanded content
                if isExpanded {
                    VStack(spacing: 0) {
                        // 15px spacing above progress bar
                        Spacer()
                            .frame(height: 15)
                        
                        // Progress bar with scrubber
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(hex: "#333333"))
                                .frame(height: 2)
                            
                            Rectangle()
                                .fill(Color(hex: "#BBBBBB"))
                                .frame(width: UIScreen.main.bounds.width * 0.8 * CGFloat(currentTime / item.duration), height: 2)
                                .animation(.linear(duration: 0.1), value: currentTime)
                            
                            // Scrubber (vertical line)
                            Rectangle()
                                .fill(Color(hex: "#BBBBBB"))
                                .frame(width: isPressed ? 4 : 2, height: isPressed ? 16 : 12)
                                .offset(x: (UIScreen.main.bounds.width * 0.8 * CGFloat(currentTime / item.duration)) - (isPressed ? 2 : 1), y: isPressed ? -2 : 0)
                                .animation(.easeInOut(duration: 0.2), value: isPressed)
                                .animation(.linear(duration: 0.1), value: currentTime)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 16)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    isPressed = true
                                    isDragging = true
                                    let maxWidth = UIScreen.main.bounds.width * 0.8
                                    let clampedX = max(0, min(maxWidth, value.location.x))
                                    let progress = clampedX / maxWidth
                                    let newTime = progress * item.duration
                                    currentTime = newTime
                                }
                                .onEnded { _ in
                                    isPressed = false
                                    isDragging = false
                                }
                        )
                        
                        // Time indicators
                        HStack {
                            Text(formatTime(currentTime))
                                .font(.custom("IBMPlexMono", size: 14))
                                .foregroundColor(ColorManager.shared.redColor)
                            
                            Spacer()
                            
                            Text("-\(formatTime(item.duration - currentTime))")
                                .font(.custom("IBMPlexMono", size: 14))
                                .foregroundColor(ColorManager.shared.redColor)
                        }
                        .padding(.horizontal, 4)
                        
                        // Playback controls
                        ZStack {
                            // Centered playback controls group
                            HStack(spacing: 40) {
                                // Rewind 15 seconds
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentTime = max(0, currentTime - 15)
                                        audioRecorderService.seekToTime(currentTime)
                                    }
                                }) {
                                    Image(systemName: "gobackward.15")
                                        .font(.system(size: 26))
                                        .foregroundColor(Color(hex: "#BBBBBB"))
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Play button
                                Button(action: togglePlayback) {
                                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 51))
                                        .foregroundColor(Color(hex: "#BBBBBB"))
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Fast forward 15 seconds
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentTime = min(item.duration, currentTime + 15)
                                        audioRecorderService.seekToTime(currentTime)
                                    }
                                }) {
                                    Image(systemName: "goforward.15")
                                        .font(.system(size: 26))
                                        .foregroundColor(Color(hex: "#BBBBBB"))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Three dots button (left aligned)
                            HStack {
                                Button(action: {
                                    showingWhisperOptions = true
                                }) {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 16))
                                        .foregroundColor(ColorManager.shared.orangeColor)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Spacer()
                            }
                            
                            // Delete button (right aligned)
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    showingDeleteSheet = true
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16))
                                        .foregroundColor(ColorManager.shared.redColor)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 4)
                        
                        // Transcription progress bar and status
                        if item.isTranscribing || item.isTranscribed {
                            VStack(spacing: 4) {
                                // Progress bar (only show when transcribing)
                                if item.isTranscribing {
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color(hex: "#333333"))
                                            .frame(height: 2)
                                        
                                        Rectangle()
                                            .fill(Color(hex: "#F8C762"))
                                            .frame(width: UIScreen.main.bounds.width * 0.8 * CGFloat(item.transcriptionProgress), height: 2)
                                            .foregroundColor(ColorManager.shared.orangeColor)
                                            .animation(.linear(duration: 0.1), value: item.transcriptionProgress)
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 2)
                                }
                                
                                // Status text
                                Text(item.isTranscribing ? "Transcription In Progress [\(Int(item.transcriptionProgress * 100))%]" : "Transcribed")
                                    .font(.custom("IBMPlexMono", size: 10))
                                    .foregroundColor(item.isTranscribing ? ColorManager.shared.orangeColor : ColorManager.shared.greenColor)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, item.isTranscribing ? 4 : 0)
                                    .animation(.easeInOut(duration: 0.5), value: item.isTranscribing)
                            }
                            .padding(.horizontal, 4)
                            .padding(.top, 8)
                        }
                    }
                    .padding(.top, 10)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                        removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                    ))
                }
            }
            .clipped()
            .contentShape(Rectangle())
            .zIndex(isExpanded ? 1 : 0)

            .onDisappear {
                stopPlayback()
                // Clean up transcription timer
                transcriptionTimer?.invalidate()
                transcriptionTimer = nil
            }
            .onChange(of: isExpanded) { _, newValue in
                if !newValue && isPlaying {
                    stopPlayback()
                }
            }
            .sheet(isPresented: $showingWhisperOptions) {
                                        WhisperOptionsView(
                            item: $item,
                            audioRecorderService: audioRecorderService,
                            transcriptionService: transcriptionService,
                            onItemUpdated: onItemUpdated
                        )
                    .presentationDetents([.height(250)])
            }
            .sheet(isPresented: $showingDeleteSheet) {
                DeleteWhisperItemSheet(
                    item: item,
                    onDelete: {
                        deleteAudioFile()
                        onDelete()
                    }
                )
                .presentationDetents([.height(250)])
            }

    }
    
    private func togglePlayback() {
        if isPlaying {
            pausePlayback()
        } else {
            startPlayback()
        }
    }
    
    private func startPlayback() {
        guard let audioURL = item.audioFileURL else { return }
        
        // Use the passed audio service for playback
        audioRecorderService.startPlayback(url: audioURL)
        isPlaying = true
        currentTime = 0
        
        // Start local timer to sync with service
        startLocalPlaybackTimer()
    }
    
    private func pausePlayback() {
        audioRecorderService.pausePlayback()
        isPlaying = false
        stopLocalPlaybackTimer()
    }
    
    private func stopPlayback() {
        audioRecorderService.stopPlayback()
        isPlaying = false
        currentTime = 0
        stopLocalPlaybackTimer()
    }
    
    private func startLocalPlaybackTimer() {
        stopLocalPlaybackTimer()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                self.currentTime = self.audioRecorderService.currentPlaybackTime
                // Sync playing state with service
                if self.audioRecorderService.isPlaying != self.isPlaying {
                    self.isPlaying = self.audioRecorderService.isPlaying
                }
            }
        }
    }
    
    private func stopLocalPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func deleteAudioFile() {
        guard let audioURL = item.audioFileURL else { return }
        
        // Delete the audio file using the service
        _ = audioRecorderService.deleteAudioFile(url: audioURL)
        
        // Also delete transcription if it exists
        if let transcriptionURL = item.transcriptionFileURL {
            _ = transcriptionService.deleteTranscriptionFile(url: transcriptionURL)
        }
    }
}

struct AudioLevelMeter: View {
    let title: String
    let isOutput: Bool
    @Binding var isRecording: Bool
    @State private var currentLevel: Double = -60 // Start at -60dB
    @State private var peakLevel: Double = -60
    @State private var rmsLevel: Double = -60
    @State private var levelTimer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            // Title and controls - align with equalizer's top
            VStack(spacing: 2) {
                Text(title)
                    .font(.custom("IBMPlexMono", size: 8))
                    .foregroundColor(Color(hex: "#BBBBBB"))
                
                if isOutput {
                    // AUTO button for OUTPUT
                    Button(action: {}) {
                        Text("AUTO")
                            .font(.custom("IBMPlexMono", size: 6))
                            .foregroundColor(Color(hex: "#141414"))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color(hex: "#BBBBBB"))
                            .cornerRadius(2)
                    }
                } else {
                    // Level display for INPUT
                    Text("0.0 dB")
                        .font(.custom("IBMPlexMono", size: 6))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                        .frame(width: 32, alignment: .center)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .overlay(
                            RoundedRectangle(cornerRadius: 1)
                                .stroke(Color(hex: "#BBBBBB"), lineWidth: 0.5)
                        )
                }
                
                // Peak and RMS readings
                VStack(alignment: .leading, spacing: 0) {
                    Text("Peak \(formatLevel(peakLevel))")
                        .font(.custom("IBMPlexMono", size: 6))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                        .frame(width: 45, alignment: .leading)
                    
                    Text("RMS \(formatLevel(rmsLevel))")
                        .font(.custom("IBMPlexMono", size: 6))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                        .frame(width: 45, alignment: .leading)
                }
            }
            .padding(.bottom, 8) // 8px gap
            
            // Vertical meter - align with equalizer bars
            HStack(spacing: 1) {
                // 80s style equalizer bars
                VStack(spacing: 0.5) {
                    ForEach(0..<33, id: \.self) { i in
                        let barHeight = 3
                        let levelThreshold = Double(i) * 1.82 // 60dB / 33 bars = 1.82dB per bar
                        let isActive = currentLevel > (-60 + levelThreshold)
                        
                        Rectangle()
                            .fill(isActive ? Color(hex: "#EEEEEE") : Color(hex: "#333333"))
                            .frame(width: 8, height: CGFloat(barHeight))
                            .animation(.easeInOut(duration: 0.1), value: currentLevel)
                    }
                }
                .frame(height: 115) // Reduced by 5px from 120
            
                // dB scale
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach([0, -6, -12, -24, -40, -60], id: \.self) { db in
                        Text("\(db)dB")
                            .font(.custom("IBMPlexMono", size: 4))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .frame(height: 20, alignment: .trailing)
                    }
                }
            }
            .padding(.top, 0) // No gap
        }
        .onAppear {
            startLevelSimulation()
        }
        .onDisappear {
            stopLevelSimulation()
        }
    }
    
    private func formatLevel(_ level: Double) -> String {
        if level <= -60 {
            return "−∞"
        } else {
            return String(format: "%.1f", level)
        }
    }
    
    private func startLevelSimulation() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            self.updateAudioLevels()
        }
    }
    
    private func stopLevelSimulation() {
        levelTimer?.invalidate()
        levelTimer = nil
    }
    
    private func updateAudioLevels() {
        guard isRecording else {
            // Reset to idle state
            currentLevel = -60
            peakLevel = -60
            rmsLevel = -60
            return
        }
        
        // Simulate random audio levels
        let randomLevel = Double.random(in: -60...0)
        currentLevel = randomLevel
        
        // Update peak and RMS
        if randomLevel > peakLevel {
            peakLevel = randomLevel
        }
        
        rmsLevel = randomLevel * 0.7 // RMS is typically lower than peak
        
        // Decay peak over time
        if peakLevel > -60 {
            peakLevel -= 0.5
        }
    }
}

struct WhisperOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var item: WhisperItem
    @ObservedObject var audioRecorderService: AudioRecorderService
    @ObservedObject var transcriptionService: TranscriptionService
    let onItemUpdated: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 8) {
                    // Options list
                    VStack(spacing: 0) {
                        ForEach(whisperOptionsItems, id: \.title) { item in
                            WhisperOptionsItemView(item: item)
                        }
                    }
                    .padding(.top, 0)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
            .safeAreaInset(edge: .top) {
                // iOS standard header overlay
                VStack(spacing: 0) {
                    // Grab bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(hex: "#666666"))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
                    // Header
                    HStack {
                        Text("Whisper Options")
                            .font(.custom("IBMPlexMono", size: 20))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .padding(.leading, 20)
                        
                        Spacer()

                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 20)
                    }
                    
                    // Buffer space below header
                    Spacer()
                        .frame(height: 18)
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
    }
    
    private var whisperOptionsItems: [WhisperOptionsItem] {
        var items: [WhisperOptionsItem] = [
            WhisperOptionsItem(title: "Audio Download", icon: "square.and.arrow.down", action: {
                downloadAudio()
            }, color: Color(hex: "#BBBBBB"))
        ]
        
        if item.isTranscribed {
            // Show download transcription and delete options
            items.append(WhisperOptionsItem(title: "Transcription Download", icon: "square.and.arrow.down", action: {
                downloadTranscription()
            }, color: Color(hex: "#BBBBBB")))
            items.append(WhisperOptionsItem(title: "Delete Transcription", icon: "trash", action: {
                deleteTranscription()
            }, color: Color(hex: "#FF6B6B")))
        } else if item.isTranscribing {
            // Show transcription in progress
            items.append(WhisperOptionsItem(title: "Transcribing...", icon: "clock", action: {
                // No action while transcribing
            }, color: Color(hex: "#FFA500")))
        } else {
            // Show transcribe option
            items.append(WhisperOptionsItem(title: "Transcribe Audio", icon: "sparkles", action: {
                startTranscription()
            }, color: Color(hex: "#BBBBBB")))
        }
        
        return items
    }
    
    private func startTranscription() {
        guard let audioURL = item.audioFileURL else {
            FeedbackService.shared.playHaptic(.heavy)
            return
        }
        
        item.isTranscribing = true
        item.transcriptionProgress = 0.0
        dismiss()
        
        // Start actual transcription
        audioRecorderService.transcribeAudio(url: audioURL) { transcription in
            DispatchQueue.main.async {
                if let transcription = transcription {
                    self.item.transcriptionText = transcription
                    self.item.isTranscribing = false
                    self.item.isTranscribed = true
                    self.item.transcriptionProgress = 1.0
                    
                    // Generate PDF transcription
                    if let pdfURL = self.transcriptionService.generateTranscriptionPDF(
                        audioTitle: self.item.title,
                        transcription: transcription,
                        timestamp: self.item.timestamp
                    ) {
                        self.item.transcriptionFileURL = pdfURL
                    }
                    
                    FeedbackService.shared.playSound(.endRecord)
                    FeedbackService.shared.playHaptic(.light)
                    onItemUpdated()
                } else {
                    self.item.isTranscribing = false
                    self.item.transcriptionProgress = 0.0
                    // Show error feedback
                    FeedbackService.shared.playHaptic(.heavy)
                    // Set error message for user feedback
                    self.item.title = "Transcription Failed - Tap to retry"
                }
            }
        }
        
        // Simulate progress for better UX
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.item.transcriptionProgress < 0.9 {
                self.item.transcriptionProgress += 0.01
            } else {
                timer.invalidate()
            }
        }
    }
    
    private func downloadAudio() {
        guard let audioURL = item.audioFileURL else {
            FeedbackService.shared.playHaptic(.heavy)
            return
        }
        
        let activityViewController = transcriptionService.shareFile(url: audioURL)
        
        // Present the share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
        
        FeedbackService.shared.playHaptic(.light)
        dismiss()
    }
    
    private func downloadTranscription() {
        guard let transcriptionURL = item.transcriptionFileURL else {
            FeedbackService.shared.playHaptic(.heavy)
            return
        }
        
        let activityViewController = transcriptionService.shareFile(url: transcriptionURL)
        
        // Present the share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityViewController, animated: true)
        }
        
        FeedbackService.shared.playHaptic(.light)
        dismiss()
    }
    
    private func deleteTranscription() {
        if let transcriptionURL = item.transcriptionFileURL {
            _ = transcriptionService.deleteTranscriptionFile(url: transcriptionURL)
        }
        
        item.isTranscribed = false
        item.transcriptionProgress = 0.0
        item.transcriptionText = nil
        item.transcriptionFileURL = nil
        
        FeedbackService.shared.playHaptic(.light)
        dismiss()
        onItemUpdated()
    }
}

struct WhisperOptionsItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let action: () -> Void
    let color: Color
}

struct WhisperOptionsItemView: View {
    let item: WhisperOptionsItem
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: item.action) {
                HStack {
                    Image(systemName: item.icon)
                        .font(.system(size: 16))
                        .foregroundColor(item.color)
                        .frame(width: 20)
                    
                    Text(item.title)
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(item.color)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            
            // Horizontal line under each item
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(height: 1)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DeleteWhisperItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    let item: WhisperItem
    let onDelete: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 8) {
                                    // Content
                VStack(spacing: 8) {
                                            Text("This action can't be undone.")
                            .font(.custom("IBMPlexMono", size: 16))
                            .foregroundColor(Color(hex: "#EEEEEE"))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 0)
                    
                    // Stacked buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            FeedbackService.shared.playHaptic(.light)
                            onDelete()
                            dismiss()
                        }) {
                            Text("Delete Audio")
                                .font(.custom("IBMPlexMono", size: 16))
                                .foregroundColor(Color(hex: "#FF6B6B"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#2A2A2A"))
                                .cornerRadius(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Cancel")
                                .font(.custom("IBMPlexMono", size: 16))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#2A2A2A"))
                                .cornerRadius(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                }
                .padding(.bottom, 20)
            }
            .safeAreaInset(edge: .top) {
                // iOS standard header overlay
                VStack(spacing: 0) {
                    // Grab bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(hex: "#666666"))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
                    // Header
                    HStack {
                        Text("Delete Audio")
                            .font(.custom("IBMPlexMono", size: 20))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .padding(.leading, 20)
                        
                        Spacer()

                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 20)
                    }
                    
                    // Buffer space below header
                    Spacer()
                        .frame(height: 18)
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
    }
}