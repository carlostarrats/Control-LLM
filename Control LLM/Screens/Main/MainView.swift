import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    
    init() {
        NSLog("🔍 MainView init")
    }
    @State private var showingTextModal = false
    @State private var showingHistoryView = false // Added state for History sheet
    @State private var showingWhisperView = false // Added state for Whisper sheet
    @State private var showingSettingsView = false // Added state for Settings sheet
    @State private var isChatMode = false
    @State private var blobScale: CGFloat = 1.0
    @State private var textOpacity: Double = 1.0
    @State private var manualInputButtonScale: CGFloat = 1.0
    @State private var manualInputButtonRotation: Double = 0
    @State private var manualInputOpacity: Double = 1.0
    @State private var chatModeTimer: Timer?
    @State private var backgroundOpacity: Double = 1.0
    @State private var blobColorOpacity: Double = 1.0
    @State private var hueShift: Double = 0.90 // 0.90 = current configuration
    @State private var saturationLevel: Double = 0.12 // 0.12 = current configuration
    @State private var brightnessLevel: Double = 0.3 // 0.3 = 30% brightness for non-active state
    
    var body: some View {
        let _ = NSLog("🔍 MainView body executing!")
        
        // Computed property for stable nav button visibility
        let shouldShowNavButtons = !viewModel.isVoiceDetected && !viewModel.isActivated && !viewModel.isInVoiceFlow
        
        ZStack {
            // Background gradient - stays dark
            LinearGradient(
                colors: [
                    Color(hex: "#1D1D1D"),  // Lighter color at top
                    Color(hex: "#141414")   // Darker color at bottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Main content
            ZStack {
                // Top navigation buttons - NOW EMPTY
                VStack {
                    Spacer()
                }

                // Central visual design element with tabs - fixed center position
                VisualizerTabView(isSpeaking: $viewModel.isActivated, hueShift: hueShift, saturationLevel: saturationLevel, brightnessLevel: brightnessLevel, onTap: handleBlobTap)
                        .scaleEffect(blobScale)
                        .accessibilityLabel("Voice recording button")
                        .accessibilityHint("Double tap to start or stop voice recording")
                    .opacity(blobColorOpacity)
                    .animation(.easeInOut(duration: 0.8), value: blobColorOpacity)



                // Bottom navigation buttons with voice interaction flow
                VStack {
                    Spacer()
                    
                    // ZStack to prevent button movement - both buttons occupy same space
                    ZStack {
                        // Navigation buttons (always present, fade out when voice detected)
                        HStack(spacing: 0) { // No spacing between buttons
                            // Group of three buttons on the left
                            Button(action: {
                                showingHistoryView = true
                            }) {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#1D1D1D"))
                                    .frame(width: 48, height: 48) // Fixed square size
                                    .background(Color(hex: "#FF6B6B"))
                                    .cornerRadius(4, corners: [.topLeft, .bottomLeft]) // Only left corners
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contentShape(Rectangle()) // Ensure full area is tappable

                            Button(action: {
                                showingWhisperView = true
                            }) {
                                Image(systemName: "waveform")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#1D1D1D"))
                                    .frame(width: 48, height: 48) // Fixed square size
                                    .background(Color(hex: "#F8C762"))
                                    .cornerRadius(0) // No corners
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contentShape(Rectangle()) // Ensure full area is tappable
                            
                            Button(action: {
                                showingSettingsView = true
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#1D1D1D"))
                                    .frame(width: 48, height: 48) // Fixed square size
                                    .background(Color(hex: "#94A8E1"))
                                    .cornerRadius(4, corners: [.topRight, .bottomRight]) // Only right corners
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contentShape(Rectangle()) // Ensure full area is tappable

                            Spacer() // Pushes keyboard button to the right

                            // Control Button on the right
                            Button(action: {
                                showingTextModal = true
                            }) {
                                Image(systemName: "keyboard")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#BBBBBB"))
                                    .frame(width: 48, height: 48) // Fixed square size
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color(hex: "#BBBBBB"), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contentShape(Rectangle()) // Ensure full area is tappable
                        }
                        .padding(.bottom, 50)
                        .padding(.horizontal, 20)
                        .opacity(shouldShowNavButtons ? 1.0 : 0.0) // Use computed property for stable visibility
                        
                        // X button (always present, fade in when voice detected)
                        Button(action: {
                            viewModel.processVoiceMessage()
                        }) {
                            Image(systemName: "paperplane") // Paper airplane symbol
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#1D1D1D"))
                                .frame(width: 48, height: 48) // Fixed square size
                                .background(Color(hex: "#3EBBA5"))
                                .cornerRadius(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Rectangle()) // Ensure full area is tappable
                        .padding(.bottom, 50)
                        .padding(.horizontal, 20)
                        .opacity(viewModel.isVoiceDetected ? 1.0 : 0.0) // Fade in when voice detected, use fixed opacity
                        .animation(.easeInOut(duration: 0.8), value: viewModel.isVoiceDetected) // Smooth fade in and out
                    }
                }
            }
        }
        .sheet(isPresented: $showingTextModal) {
            TextModalView(viewModel: viewModel, isPresented: $showingTextModal, messageHistory: viewModel.messages)
                .onDisappear {
                    showingTextModal = false
                    viewModel.deactivateVoiceInputMode()
                }
        }
        .sheet(isPresented: $showingHistoryView) {
            HistoryView(
                showingTextModal: $showingTextModal,
                mainViewModel: viewModel
            )
        }
        .sheet(isPresented: $showingWhisperView) {
            WhisperView(
                showingTextModal: $showingTextModal,
                mainViewModel: viewModel
            )
        }
        .sheet(isPresented: $showingSettingsView) {
            SettingsView(
                showingTextModal: $showingTextModal,
                mainViewModel: viewModel
            )
        }
        .onChange(of: viewModel.isActivated) { _, isActivated in
            if isActivated {
                // Trigger the same visual effects as activateControlSequence
                withAnimation(.easeOut(duration: 0.8)) {
                    textOpacity = 0.0 // Fade all text away
                    manualInputOpacity = 0.0 // Fade manual input away
                    blobColorOpacity = 1.0 // Keep blob fully visible
                    
                    // Set activated state values (copy of main state but full brightness)
                    hueShift = 0.90
                    saturationLevel = 0.12
                    brightnessLevel = 1.0
                }
            } else {
                // Return to normal state
                withAnimation(.easeInOut(duration: 0.8)) {
                    blobColorOpacity = 1.0 // Restore blob colors
                    brightnessLevel = 0.3
                }
                
                // Then, after a delay, start the text fade-in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        textOpacity = 1.0 // Restore text
                        manualInputOpacity = 1.0 // Restore manual input
                    }
                }
            }
        }
    }

    private func activateChatMode() {
        withAnimation(.easeInOut(duration: 0.6)) {
            isChatMode = true
            textOpacity = 0.3 // Fade text but don't disappear
            manualInputOpacity = 0.3 // Fade manual input but don't disappear
        }

        // Transform manual input button to X
        withAnimation(.easeInOut(duration: 0.4).delay(0.2)) {
            manualInputButtonScale = 0.8
            manualInputButtonRotation = 90
        }

        // Start the timer to deactivate chat mode after 3 seconds
        chatModeTimer?.invalidate() // Invalidate any existing timer
        chatModeTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            self.deactivateChatMode()
        }
    }

    private func deactivateChatMode() {
        withAnimation(.easeInOut(duration: 0.6)) {
            isChatMode = false
            textOpacity = 1.0
            manualInputOpacity = 1.0
            manualInputButtonScale = 1.0
            manualInputButtonRotation = 0
        }
        chatModeTimer?.invalidate() // Invalidate the timer
    }

    private func handleBlobTap() {
        if !viewModel.isActivated && !isChatMode {
            // Start voice detection flow instead of immediate activation
            viewModel.voiceDetected()
        }
    }

    private func activateControlSequence() {
        print("🔥 CONTROL ACTIVATED - Starting activation sequence")

        // Start activation sequence
        withAnimation(.easeOut(duration: 0.8)) {
            viewModel.isActivated = true
            textOpacity = 0.0 // Fade all text away
            manualInputOpacity = 0.0 // Fade manual input away
            blobColorOpacity = 1.0 // Keep blob fully visible

            // Set activated state values (copy of main state but full brightness)
            hueShift = 0.90
            saturationLevel = 0.12
            brightnessLevel = 1.0
        }

        // Return to normal state after 3 seconds with delayed text fade-in
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print("🔥 CONTROL SEQUENCE COMPLETE - Returning to normal state")

            // First, start the visualizer transition
            withAnimation(.easeInOut(duration: 0.8)) {
                viewModel.isActivated = false
                blobColorOpacity = 1.0 // Restore blob colors
                brightnessLevel = 0.3
            }
            
            // Then, after a delay, start the text fade-in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    textOpacity = 1.0 // Restore text
                    manualInputOpacity = 1.0 // Restore manual input
                }
            }
        }
    }
}



struct NavigationButton: View {
    let title: String
    let action: () -> Void
    let icon: String?
    
    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            if let icon = icon {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                    
                    Text(title)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                        .tracking(0)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 8)
            } else {
                                    Text(title)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                        .tracking(0)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 8)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(title)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: true)
    }
}

struct DashedLineAboveText: View {
    let text: String
    
    var body: some View {
        // Calculate total width including icon and spacing
        let iconWidth: CGFloat = 14 // keyboard icon width
        let spacing: CGFloat = 8 // spacing between icon and text
        let extraPadding: CGFloat = 6 // small extra padding for visual balance
        let textWidth = textWidth(for: text)
        let totalWidth = iconWidth + spacing + textWidth + extraPadding

        let dashLength: CGFloat = 4
        let gapLength: CGFloat = 2
        let totalPatternLength = dashLength + gapLength

        // Calculate how many complete patterns fit within the total width
        let completePatterns = Int(totalWidth / totalPatternLength)
        let remainingWidth = totalWidth - CGFloat(completePatterns) * totalPatternLength

        Path { path in
            var currentX: CGFloat = 0

            // Draw complete patterns
            for _ in 0..<completePatterns {
                path.move(to: CGPoint(x: currentX, y: 0))
                path.addLine(to: CGPoint(x: currentX + dashLength, y: 0))
                currentX += totalPatternLength
            }

            // If there's enough remaining space for a full dash, add it
            if remainingWidth >= dashLength {
                path.move(to: CGPoint(x: currentX, y: 0))
                path.addLine(to: CGPoint(x: currentX + dashLength, y: 0))
            }
        }
        .stroke(Color(hex: "#BBBBBB"), lineWidth: 1)
        .frame(width: totalWidth, height: 1)
        .frame(maxWidth: .infinity, alignment: .center) // Center the dashed line
    }

    private func textWidth(for text: String) -> CGFloat {
        let font = UIFont.monospacedSystemFont(ofSize: 16, weight: .medium)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return size.width
    }
}







#Preview {
    MainView()
        .preferredColorScheme(.dark)
} 