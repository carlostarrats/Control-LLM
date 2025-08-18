import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @EnvironmentObject var colorManager: ColorManager
    
    init() {
        NSLog("🔍 MainView init")
    }
    @State private var showingTextModal = false
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
    // Page navigation: 0 = Settings, 1 = Home, 2 = Chat
    @State private var currentPage: Int = 1
    
    var body: some View {
        // REMOVED ALL DEBUG - app is working now
        
        // Simplified nav button visibility - always show for now
        let shouldShowNavButtons = true
        
        ZStack {
            // Global background gradient that covers everything
            LinearGradient(
                colors: [
                    Color(hex: "#1D1D1D"),
                    Color(hex: "#141414")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all)
            
            TabView(selection: $currentPage) {
                // Page 0: Settings
                SettingsPage(currentPage: $currentPage, viewModel: viewModel)
                    .tag(0)
                
                // Page 1: Home
                HomePage(
                    shouldShowNavButtons: shouldShowNavButtons,
                    blobScale: $blobScale,
                    blobColorOpacity: $blobColorOpacity,
                    hueShift: hueShift,
                    saturationLevel: saturationLevel,
                    brightnessLevel: brightnessLevel,
                    onSettings: { currentPage = 0 },
                    onChat: { currentPage = 2 }
                )
                .tag(1)
                
                // Page 2: Chat
                ChatPage(currentPage: $currentPage, viewModel: viewModel)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
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
}

// MARK: - Settings Page
struct SettingsPage: View {
    @Binding var currentPage: Int
    let viewModel: MainViewModel
    
    var body: some View {
        VStack {
            SettingsView(
                showingTextModal: .constant(false),
                mainViewModel: viewModel
            )
        }
    }
}

// MARK: - Home Page
struct HomePage: View {
    @EnvironmentObject var colorManager: ColorManager
    let shouldShowNavButtons: Bool
    @Binding var blobScale: CGFloat
    @Binding var blobColorOpacity: Double
    let hueShift: Double
    let saturationLevel: Double
    let brightnessLevel: Double
    let onSettings: () -> Void
    let onChat: () -> Void
    
    var body: some View {
        // Main content
        ZStack {
            // Top navigation buttons - NOW EMPTY
            VStack {
                Spacer()
            }

            // Central visual design element with tabs - RESTORED ORIGINAL
            VisualizerTabView(
                hueShift: hueShift,
                saturationLevel: saturationLevel,
                brightnessLevel: brightnessLevel
            )
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
                        // Settings button on the left
                        Button(action: {
                            FeedbackService.shared.playHaptic(.light)
                            onSettings()
                        }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "#1D1D1D"))
                                .frame(width: 60, height: 60) // Increased to 60x60
                                .background(colorManager.greenColor)
                                .cornerRadius(4) // Full corner radius for single button
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Rectangle()) // Ensure full area is tappable
                    
                        Spacer() // Pushes keyboard button to the right
                    
                        // Control Button on the right
                        Button(action: {
                            FeedbackService.shared.playHaptic(.light)
                            onChat()
                        }) {
                            Image(systemName: "keyboard")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(width: 60, height: 60) // Increased to 60x60
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
                    
                    // Process button (always present, fade in when voice detected)
                    Button(action: {
                        FeedbackService.shared.playHaptic(.light)
                        // Voice processing removed for now
                    }) {
                        ZStack {
                            // Outer circle with stroke
                            Circle()
                                .stroke(Color(hex: "#666666"), lineWidth: 2)
                                .frame(width: 60, height: 60)
                            
                            // Inner filled circle
                            Circle()
                                .fill(Color(hex: "#666666"))
                                .frame(width: 52, height: 52)
                            
                            // Sparkle icon centered
                            Image(systemName: "sparkles")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "#1D1D1D"))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contentShape(Rectangle()) // Ensure full area is tappable
                    .padding(.bottom, 50)
                    .padding(.horizontal, 20)
                    .opacity(0.0) // Voice detection removed for now
                    .animation(.easeInOut(duration: 0.8), value: 0.0) // Fixed value for now
                }
            }
        }
    }
}

// MARK: - Chat Page
struct ChatPage: View {
    @Binding var currentPage: Int
    let viewModel: MainViewModel
    
    var body: some View {
        TextModalView(
            viewModel: viewModel,
            isPresented: .constant(true),
            messageHistory: viewModel.messages
        )
    }
}

// Removed OrganicRippleEffect and RippleLayer - now using Metal shader approach


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
