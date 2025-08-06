import SwiftUI

struct WhisperView: View {
    @Binding var showingTextModal: Bool
    @ObservedObject var mainViewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isRecording = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var recordingStartTime: Date?
    @State private var expandedItemId: String? = nil

    @State private var whisperItems: [WhisperItem] = [
        WhisperItem(
            id: "1",
            title: "Audio Processing Pipeline",
            content: "Real-time audio analysis and processing for voice input recognition and enhancement. Includes noise reduction, echo cancellation, and spectral analysis.",
            expandedContent: "Advanced audio processing with multi-band compression, adaptive filtering, and machine learning-based voice activity detection. Optimized for low-latency real-time processing in mobile environments.",
            timestamp: Date(),
            duration: 45 // 45 seconds
        ),
        WhisperItem(
            id: "2", 
            title: "Neural Network Architecture",
            content: "Deep learning model for natural language understanding and response generation. Transformer-based architecture with attention mechanisms.",
            expandedContent: "Multi-layer transformer with 175 billion parameters, fine-tuned for conversational AI. Includes context window management, response generation, and safety filtering systems.",
            timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            duration: 60 // 1 minute
        ),
        WhisperItem(
            id: "3",
            title: "Memory Management System",
            content: "Intelligent memory allocation and conversation history management for maintaining context across sessions.",
            expandedContent: "Hierarchical memory system with short-term working memory, long-term storage, and semantic indexing. Implements efficient retrieval and context reconstruction algorithms.",
            timestamp: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            duration: 90 // 1 minute 30 seconds
        )
    ]
    
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
                    
                    // Chat history (placeholder)
                    VStack(spacing: 20) {
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
                                    }
                                }
                            )
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
        .onDisappear {
            // Stop recording if sheet is dismissed while recording
            if isRecording {
                timer?.invalidate()
                timer = nil
                isRecording = false
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
            timer?.invalidate()
            timer = nil
            isRecording = false
            
            // Add the new recording to the list
            let newRecording = WhisperItem(
                id: UUID().uuidString,
                title: "Tap to edit title",
                content: "Voice recording",
                expandedContent: "This is a new voice recording captured using the Whisper interface.",
                timestamp: Date(),
                duration: elapsedTime
            )
            
            // Add to the beginning of the list (most recent first)
            whisperItems.insert(newRecording, at: 0)
            
            // Reset elapsed time for next recording
            elapsedTime = 0
        } else {
            // Start recording immediately
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
}

struct WhisperItemView: View {
    @Binding var item: WhisperItem
    let formatDate: (Date) -> String
    let formatDuration: (TimeInterval) -> String
    let isExpanded: Bool
    let onExpand: (String) -> Void
    let onDelete: () -> Void
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
                        .foregroundColor(Color(hex: "#F8C762"))
                    
                    // Recording time under the date
                    Text(formatDuration(item.duration))
                        .font(.custom("IBMPlexMono", size: 10))
                        .foregroundColor(Color(hex: "#FF6B6B"))
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
                                .foregroundColor(Color(hex: "#FF6B6B"))
                            
                            Spacer()
                            
                            Text("-\(formatTime(item.duration - currentTime))")
                                .font(.custom("IBMPlexMono", size: 14))
                                .foregroundColor(Color(hex: "#FF6B6B"))
                        }
                        .padding(.horizontal, 4)
                        
                        // Playback controls
                        ZStack {
                            // Centered playback controls group
                            HStack(spacing: 20) {
                                // Rewind 15 seconds
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentTime = max(0, currentTime - 15)
                                    }
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "#141414"))
                                            .frame(width: 70, height: 70)
                                        
                                        Image(systemName: "gobackward.15")
                                            .font(.system(size: 26))
                                            .foregroundColor(Color(hex: "#BBBBBB"))
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Play button
                                Button(action: togglePlayback) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "#141414"))
                                            .frame(width: 70, height: 70)
                                        
                                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                            .font(.system(size: 51))
                                            .foregroundColor(Color(hex: "#BBBBBB"))
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Fast forward 15 seconds
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentTime = min(item.duration, currentTime + 15)
                                    }
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "#141414"))
                                            .frame(width: 70, height: 70)
                                        
                                        Image(systemName: "goforward.15")
                                            .font(.system(size: 26))
                                            .foregroundColor(Color(hex: "#BBBBBB"))
                                    }
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
                                        .foregroundColor(Color(hex: "#F8C762"))
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
                                        .foregroundColor(Color(hex: "#FF6B6B"))
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
                                            .animation(.linear(duration: 0.1), value: item.transcriptionProgress)
                                    }
                                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 2)
                                }
                                
                                // Status text
                                Text(item.isTranscribing ? "Transcription In Progress [\(Int(item.transcriptionProgress * 100))%]" : "Transcribed")
                                    .font(.custom("IBMPlexMono", size: 10))
                                    .foregroundColor(item.isTranscribing ? Color(hex: "#F8C762") : Color(hex: "#3EBBA5"))
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
            }
            .onChange(of: isExpanded) { _, newValue in
                if !newValue && isPlaying {
                    stopPlayback()
                }
            }
            .sheet(isPresented: $showingWhisperOptions) {
                WhisperOptionsView(item: $item)
                    .presentationDetents([.height(250)])
            }
            .sheet(isPresented: $showingDeleteSheet) {
                DeleteWhisperItemSheet(onDelete: onDelete)
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
        isPlaying = true
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if currentTime < item.duration {
                currentTime += 0.1
            } else {
                stopPlayback()
            }
        }
    }
    
    private func pausePlayback() {
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func stopPlayback() {
        isPlaying = false
        currentTime = 0
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
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
                // TODO: Implement audio download
                dismiss()
            }, color: Color(hex: "#BBBBBB"))
        ]
        
        if item.isTranscribed {
            // Show download transcription and delete options
            items.append(WhisperOptionsItem(title: "Transcription Download", icon: "square.and.arrow.down", action: {
                // TODO: Implement transcription download
                dismiss()
            }, color: Color(hex: "#BBBBBB")))
            items.append(WhisperOptionsItem(title: "Delete Transcription", icon: "trash", action: {
                item.isTranscribed = false
                item.transcriptionProgress = 0.0
                dismiss()
            }, color: Color(hex: "#FF6B6B")))
        } else if item.isTranscribing {
            // Show download transcription option
            items.append(WhisperOptionsItem(title: "Transcription Download", icon: "square.and.arrow.down", action: {
                // TODO: Implement transcription download
                dismiss()
            }, color: Color(hex: "#BBBBBB")))
        } else {
            // Show transcribe option
            items.append(WhisperOptionsItem(title: "Transcribe Audio", icon: "sparkles", action: {
                startTranscription()
            }, color: Color(hex: "#BBBBBB")))
        }
        
        return items
    }
    
    private func startTranscription() {
        item.isTranscribing = true
        item.transcriptionProgress = 0.0
        dismiss()
        
        // Simulate transcription progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if item.transcriptionProgress < 1.0 {
                item.transcriptionProgress += 0.01
            } else {
                item.isTranscribing = false
                item.isTranscribed = true
                timer.invalidate()
            }
        }
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