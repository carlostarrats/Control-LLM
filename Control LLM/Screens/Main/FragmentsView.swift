import SwiftUI

struct FragmentsView: View {
    @Binding var showingTextModal: Bool
    @ObservedObject var mainViewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isRecording = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
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
                    // Timer and record button
                    HStack {
                        Text(formatTime(elapsedTime))
                            .font(.custom("IBMPlexMono", size: 48))
                            .foregroundColor(Color(hex: "#EEEEEE"))
                        
                        Spacer()
                        
                        // Record/Stop button
                        Button(action: toggleRecording) {
                            Group {
                                if isRecording {
                                    // Square for stop
                                    Rectangle()
                                        .fill(Color(hex: "#FF4444"))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Rectangle()
                                                .stroke(Color(hex: "#CC3333"), lineWidth: 2)
                                        )
                                        .overlay(
                                            // X shape with diagonal lines
                                            GeometryReader { geometry in
                                                Path { path in
                                                    let size = geometry.size
                                                    let centerX = size.width / 2
                                                    let centerY = size.height / 2
                                                    let halfSize: CGFloat = 10 // Half the size of the square
                                                    
                                                    // First diagonal line (top-left to bottom-right)
                                                    path.move(to: CGPoint(x: centerX - halfSize, y: centerY - halfSize))
                                                    path.addLine(to: CGPoint(x: centerX + halfSize, y: centerY + halfSize))
                                                    
                                                    // Second diagonal line (top-right to bottom-left)
                                                    path.move(to: CGPoint(x: centerX + halfSize, y: centerY - halfSize))
                                                    path.addLine(to: CGPoint(x: centerX - halfSize, y: centerY + halfSize))
                                                }
                                                .stroke(Color(hex: "#141414"), lineWidth: 2)
                                            }
                                        )
                                } else {
                                    // Circle for record
                                    Circle()
                                        .fill(Color(hex: "#FF4444"))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color(hex: "#CC3333"), lineWidth: 2)
                                        )
                                }
                            }
                        }
                    }
                    .padding(.top, 2)
                    .padding(.horizontal, 20)
                    
                    // Equalizer component
                    AdvancedEqualizerView(isSpeaking: $mainViewModel.isSpeaking)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .padding(.bottom, 40)
                    
                    // Chat history (placeholder)
                    VStack(spacing: 20) {
                        ForEach(fragmentItems, id: \.id) { item in
                            FragmentItemView(item: item)
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
                        Text("Fragments")
                            .font(.custom("IBMPlexMono", size: 20))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .padding(.horizontal, 20)
                        
                        Spacer()
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
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let hundredths = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d.%02d.%02d", minutes, seconds, hundredths)
    }
    
    private func toggleRecording() {
        if isRecording {
            // Stop recording
            timer?.invalidate()
            timer = nil
            isRecording = false
        } else {
            // Start recording
            elapsedTime = 0
            isRecording = true
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                elapsedTime += 0.01
            }
        }
    }
    
    private var fragmentItems: [FragmentItem] {
        [
            FragmentItem(
                id: "1",
                title: "Audio Processing Pipeline",
                content: "Real-time audio analysis and processing for voice input recognition and enhancement. Includes noise reduction, echo cancellation, and spectral analysis.",
                expandedContent: "Advanced audio processing with multi-band compression, adaptive filtering, and machine learning-based voice activity detection. Optimized for low-latency real-time processing in mobile environments."
            ),
            FragmentItem(
                id: "2", 
                title: "Neural Network Architecture",
                content: "Deep learning model for natural language understanding and response generation. Transformer-based architecture with attention mechanisms.",
                expandedContent: "Multi-layer transformer with 175 billion parameters, fine-tuned for conversational AI. Includes context window management, response generation, and safety filtering systems."
            ),
            FragmentItem(
                id: "3",
                title: "Memory Management System",
                content: "Intelligent memory allocation and conversation history management for maintaining context across sessions.",
                expandedContent: "Hierarchical memory system with short-term working memory, long-term storage, and semantic indexing. Implements efficient retrieval and context reconstruction algorithms."
            )
        ]
    }
}

struct FragmentItem: Identifiable {
    let id: String
    let title: String
    let content: String
    let expandedContent: String
}

struct FragmentItemView: View {
    let item: FragmentItem
    @State private var isExpanded = false
    
    var body: some View {
        HStack(spacing: 10) {
            // Vertical line
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(width: 1)
                .frame(maxHeight: .infinity)
            
            // Main content area
            VStack(spacing: 0) {
                // Main title (clickable)
                HStack {
                    Text(item.title)
                        .font(.custom("IBMPlexMono", size: 14))
                        .foregroundColor(Color(hex: "#EEEEEE"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            Rectangle()
                                .fill(Color(hex: "#333333"))
                        )
                    
                    // Arrow indicator
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                        .padding(.trailing, 8)
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }
                
                // Expanded content
                if isExpanded {
                    VStack(spacing: 10) {
                        Text(item.expandedContent)
                            .font(.custom("IBMPlexMono", size: 14))
                            .foregroundColor(Color(hex: "#EEEEEE"))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                Rectangle()
                                    .fill(Color(hex: "#252525"))
                            )
                        
                        // Non-clickable Continue Chat button
                        HStack {
                            Spacer()
                            Text("Continue Chat")
                                .font(.custom("IBMPlexMono", size: 12))
                                .foregroundColor(Color(hex: "#EEEEEE"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Rectangle()
                                        .fill(Color(hex: "#222222"))
                                )
                                .overlay(
                                    GeometryReader { geometry in
                                        Path { path in
                                            let width = geometry.size.width
                                            let height = geometry.size.height
                                            
                                            // Draw left and bottom as a single continuous path
                                            path.move(to: CGPoint(x: 0, y: 0))
                                            path.addLine(to: CGPoint(x: 0, y: height))
                                            path.addLine(to: CGPoint(x: width, y: height))
                                        }
                                        .stroke(Color(hex: "#444444"), lineWidth: 1)
                                    }
                                )
                        }
                    }
                    .padding(.top, 10)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                        removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                    ))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .clipped()
        .zIndex(isExpanded ? 1 : 0)
    }
} 