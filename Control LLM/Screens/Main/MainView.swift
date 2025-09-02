import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @EnvironmentObject var colorManager: ColorManager
    
    init() {
        NSLog("🔍 MainView init")
        // Check for first run immediately
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        NSLog("🔍 Init check: hasSeenOnboarding = \(hasSeenOnboarding)")
        if !hasSeenOnboarding {
            NSLog("🔍 First run detected in init")
            // We can't set @State here, so we'll use a different approach
        }
    }
    @State private var showingTextModal = false
    @State private var showingSettingsView = false // Added state for Settings sheet
    @State private var showingOnboarding = false // Will be set to true in onAppear if first run
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
    @State private var showingChatSheet = true
    @State private var isSheetExpanded = false
    @State private var chatSheetView: TextModalView?
    
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
                    isSheetPresented: $showingChatSheet,
                    isSheetExpanded: $isSheetExpanded
                )
                .tag(1)
            }

            .onChange(of: currentPage) { _, newPage in
                // Dismiss keyboard when navigating away from home page
                if newPage != 1 {
                    // Post notification to dismiss keyboard
                    NotificationCenter.default.post(name: .dismissKeyboard, object: nil)
                } else if newPage == 1 {
                    // When returning to main page, ensure chat sheet is shown
                    showingChatSheet = true
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Onboarding Modal (first run only)
            if showingOnboarding {
                OnboardingModal(isPresented: $showingOnboarding)
            }
        }
        .onAppear {
            let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
            NSLog("🔍 Onboarding check: hasSeenOnboarding = \(hasSeenOnboarding)")
            
            if hasSeenOnboarding {
                NSLog("🔍 User has already seen onboarding, keeping modal hidden")
                showingOnboarding = false
            } else {
                NSLog("🔍 First run, showing modal")
                showingOnboarding = true
            }
            
            // Setup clipboard processing notification observer
            viewModel.setupClipboardProcessingObserver()
            
            // Initialize stable chat sheet view
            if chatSheetView == nil {
                chatSheetView = TextModalView(
                    viewModel: viewModel,
                    isPresented: $showingChatSheet,
                    isSheetExpanded: $isSheetExpanded
                )
            }
        }
        .onDisappear {
            // Clean up notification observer
            viewModel.cleanupClipboardObserver()
        }
        .sheet(isPresented: Binding(
            get: { showingChatSheet && currentPage == 1 },
            set: { newValue in
                if newValue {
                    showingChatSheet = true
                } else {
                    showingChatSheet = false
                }
            }
        )) {
            if let chatView = chatSheetView {
                chatView
                .presentationDetents([.height(100), .large], selection: Binding(
                    get: { isSheetExpanded ? .large : .height(100) },
                    set: { newDetent in
                        isSheetExpanded = (newDetent == .large)
                        print("🔍 Sheet detent changed to: \(newDetent), isSheetExpanded: \(isSheetExpanded)")
                    }
                ))
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled)
                .interactiveDismissDisabled()
                .onChange(of: isSheetExpanded) { _, newValue in
                    print("🔍 Sheet expansion state changed to: \(newValue)")
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
    @Binding var isSheetPresented: Bool
    @Binding var isSheetExpanded: Bool
    
    var body: some View {
        // Main content
        ZStack {
            // Top navigation buttons - NOW EMPTY
            VStack {
                Spacer()
            }

            // Central visual design element with tabs - RESTORED ORIGINAL
            // Only show animations when sheet is not expanded (per requirements)
            if !isSheetExpanded {
                VisualizerTabView(
                    hueShift: hueShift,
                    saturationLevel: saturationLevel,
                    brightnessLevel: brightnessLevel
                )
                .scaleEffect(blobScale)
                .accessibilityLabel(NSLocalizedString("Voice recording button", comment: ""))
                .accessibilityHint(NSLocalizedString("Double tap to start or stop voice recording", comment: ""))
                .opacity(blobColorOpacity)
                .animation(.easeInOut(duration: 0.8), value: blobColorOpacity)
            }

            // Bottom navigation buttons removed - main screen now has no buttons
            VStack {
                Spacer()
                
                // Empty space where buttons used to be
                Spacer()
                    .frame(height: 50)
            }
        }
    }
}



// Removed OrganicRippleEffect and RippleLayer - now using Metal shader approach


struct NavigationButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("IBMPlexMono", size: 14))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(hex: "#2A2A2A"))
                .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
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
