import SwiftUI

// MARK: - Performance Optimization: View Recycling

/// High-performance view recycler for better memory management
class ViewRecycler {
    private var recycledViews: [String: AnyView] = [:]
    private let maxCacheSize = 10
    
    func getRecycledView<T: View>(for key: String, @ViewBuilder builder: () -> T) -> AnyView {
        if let cachedView = recycledViews[key] {
            return cachedView
        }
        
        let newView = AnyView(builder())
        
        // Cache the view if we have space
        if recycledViews.count < maxCacheSize {
            recycledViews[key] = newView
        }
        
        return newView
    }
    
    func clearCache() {
        recycledViews.removeAll()
    }
    
    func removeView(for key: String) {
        recycledViews.removeValue(forKey: key)
    }
}



struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @EnvironmentObject var colorManager: ColorManager
    
    // PERFORMANCE OPTIMIZATION: View recycling and reuse
    @State private var viewCache: [String: AnyView] = [:]
    @State private var viewRecycler = ViewRecycler()
    
    init() {
        NSLog("🔍 MainView init")
        // Check for first run immediately
        let hasSeenOnboarding = false // Reset for testing
        NSLog("🔍 Init check: hasSeenOnboarding = \(hasSeenOnboarding)")
        if !hasSeenOnboarding {
            NSLog("🔍 First run detected in init")
            // We can't set @State here, so we'll use a different approach
        }
    }
    @State private var showingTextModal = false
    @State private var showingSettingsView = false // Added state for Settings sheet
    @State private var showingOnboarding = false // Will be set based on whether user has seen onboarding
    @State private var showingLoadingScreen = true // Show loading screen on app startup
    @State private var loadingScreenDuration: Double = 2.0 // 2 seconds duration
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
    // Page navigation removed - settings now handled by sheet
    @State private var showingChatSheet = true
    @State private var showingSettingsSheet = true
    @State private var isSheetExpanded = false
    @State private var isSettingsSheetExpanded = false

    // MARK: - Private Functions
    private func updateWindowBackgroundColor() {
        DispatchQueue.main.async {
            // Access the window through the view's window property
            if let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
                .first(where: { $0.isKeyWindow }) {
                
                // Always use dark background - no more orange
                let backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0) // #141414
                
                // Debug logging
                NSLog("🔍 DEBUG: Setting window background to DARK")
                NSLog("🔍 DEBUG: isSettingsSheetExpanded: \(isSettingsSheetExpanded)")
                NSLog("🔍 DEBUG: isSheetExpanded: \(isSheetExpanded)")
                NSLog("🔍 DEBUG: Window found: \(window != nil)")
                NSLog("🔍 DEBUG: Window frame: \(window.frame)")
                NSLog("🔍 DEBUG: Window safe area: \(window.safeAreaInsets)")
                
                // Try multiple approaches
                window.backgroundColor = backgroundColor
                
                // Also try setting root view controller background
                if let rootVC = window.rootViewController {
                    rootVC.view.backgroundColor = backgroundColor
                    NSLog("🔍 DEBUG: Set root view controller background to DARK")
                }
                
                // Also try setting the window's root view background
                window.rootViewController?.view.backgroundColor = backgroundColor
                
                // Verify the change
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NSLog("🔍 DEBUG: Window background after change: \(window.backgroundColor?.description ?? "nil")")
                    NSLog("🔍 DEBUG: Root VC background: \(window.rootViewController?.view.backgroundColor?.description ?? "nil")")
                }
            } else {
                NSLog("🔍 DEBUG: No window found!")
            }
        }
    }
    
    // MARK: - Computed Properties
    private var chatSheetView: some View {
        viewRecycler.getRecycledView(for: "chatSheet") {
            TextModalView(
                viewModel: viewModel,
                isPresented: $showingChatSheet,
                isSheetExpanded: $isSheetExpanded,
                messageHistory: []
            )
            .background(
                LinearGradient(
                    colors: [Color(hex: "#1D1D1D"), Color(hex: "#141414")],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea(.all)
            )
        }


        .offset(y: isSettingsSheetExpanded ? UIScreen.main.bounds.height : 0)
        .zIndex(isSheetExpanded ? 2 : 0)
        .overlay(
            // Tap gesture overlay - only active when settings sheet is not expanded
            Group {
                if !isSettingsSheetExpanded {
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture { location in
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    if isSheetExpanded {
                                        // Do nothing when expanded - use X button to close
                                    } else {
                                        // Tap to expand when closed
                                        isSheetExpanded = true
                                        isSettingsSheetExpanded = false
                                    }
                                }
                            }
                    }
                    .allowsHitTesting(!isSheetExpanded) // Only allow tap when closed
                }
            }
        )


    }
    

    private var settingsSheetView: some View {
        viewRecycler.getRecycledView(for: "settingsSheet") {
            SettingsModalView(
                isPresented: $showingSettingsSheet,
                isSheetExpanded: $isSettingsSheetExpanded,
                mainViewModel: viewModel
            )
            .background(
                LinearGradient(
                    colors: [Color(hex: "#1D1D1D"), Color(hex: "#141414")],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea(.all)
            )
        }


        .offset(y: isSheetExpanded ? UIScreen.main.bounds.height : 0)
        .zIndex(isSettingsSheetExpanded ? 2 : 1)
        .overlay(
            // Tap gesture overlay - only active when chat sheet is not expanded
            Group {
                if !isSheetExpanded {
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture { location in
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    if isSettingsSheetExpanded {
                                        // Do nothing when expanded - use X button to close
                                    } else {
                                        // Tap to expand when closed
                                        isSettingsSheetExpanded = true
                                        isSheetExpanded = false
                                    }
                                }
                            }
                    }
                    .allowsHitTesting(!isSettingsSheetExpanded) // Only allow tap when closed
                }
            }
        )


    }
    
    private var mainContent: some View {
        // Home page only - settings now handled by sheet
        HomePage(
            shouldShowNavButtons: true,
            blobScale: $blobScale,
            blobColorOpacity: $blobColorOpacity,
            hueShift: hueShift,
            saturationLevel: saturationLevel,
            brightnessLevel: brightnessLevel,
            onSettings: { 
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isSettingsSheetExpanded = true
                }
            },
            isSheetPresented: $showingChatSheet,
            isSheetExpanded: $isSheetExpanded,
            isSettingsSheetExpanded: $isSettingsSheetExpanded
        )
    }
    
    var body: some View {
        ZStack {
            // Base dark background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea(.all)
            

            
            // Only show main content if onboarding is not showing
            if !showingOnboarding {
                mainContent
            }

            // Page navigation removed - settings now handled by sheet
            
        }
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#1D1D1D"),
                    Color(hex: "#141414")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all)
        )
        .onAppear {
            let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
            NSLog("🔍 Onboarding check: hasSeenOnboarding = \(hasSeenOnboarding)")
            NSLog("🔍 Loading screen showing: \(showingLoadingScreen)")
            NSLog("🔍 MainView onAppear called")
            NSLog("🔍 Initial showingOnboarding: \(showingOnboarding)")
            
            // Show onboarding after loading screen finishes (only if first run)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                if !hasSeenOnboarding {
                    NSLog("🔍 Showing onboarding - first run")
                    showingOnboarding = true
                } else {
                    NSLog("🔍 Skipping onboarding - already seen")
                    showingOnboarding = false
                }
            }
            
            // Setup clipboard processing notification observer
            viewModel.setupClipboardProcessingObserver()
            
            // Set window background color dynamically
            updateWindowBackgroundColor()
            
            // Initialize any needed setup
        }
        .onChange(of: isSettingsSheetExpanded) { oldValue, newValue in
            NSLog("🔍 DEBUG: isSettingsSheetExpanded changed from \(oldValue) to \(newValue)")
            updateWindowBackgroundColor()
        }
        .onChange(of: isSheetExpanded) { oldValue, newValue in
            NSLog("🔍 DEBUG: isSheetExpanded changed from \(oldValue) to \(newValue)")
            updateWindowBackgroundColor()
        }
        .onDisappear {
            // Clean up notification observer
            viewModel.cleanupClipboardObserver()
            
            // PERFORMANCE OPTIMIZATION: Clear view cache to free memory
            viewRecycler.clearCache()
        }
        .overlay(
            // Chat sheet (behind settings sheet, 100pt height)
            Group {
                if showingChatSheet {
                    VStack {
                        Spacer()
                        chatSheetView
                            .frame(height: isSheetExpanded ? UIScreen.main.bounds.height * 0.9 : 120)
                            // .cornerRadius(16, corners: [.topLeft, .topRight]) // TEST: Remove corner radius to see if it fixes safe area

                    }
                }
            }
        )
        .overlay(
            // Settings sheet (in front, 50pt height)
            Group {
                if showingSettingsSheet {
                    VStack {
                        Spacer()
                        settingsSheetView
                            .frame(height: isSettingsSheetExpanded ? UIScreen.main.bounds.height * 0.9 : 50)
                            // .cornerRadius(16, corners: [.topLeft, .topRight]) // TEST: Remove corner radius to see if it fixes safe area

                    }
                }
            }
        )
        .overlay(
            // Dynamic safe area overlay that matches sheet colors
            VStack {
                Spacer()
                Rectangle()
                    .fill(
                        // Smooth transition between red and dark based on sheet states
                        !isSheetExpanded && !isSettingsSheetExpanded ? 
                        ColorManager.shared.redColor : 
                        Color(hex: "#141414")
                    )
                    .frame(height: 50) // Cover the 34pt safe area plus some buffer
                    .allowsHitTesting(false)
                    .animation(.easeInOut(duration: 0.3), value: isSheetExpanded)
                    .animation(.easeInOut(duration: 0.3), value: isSettingsSheetExpanded)
            }
            .ignoresSafeArea(.all)
            .zIndex(999) // Ensure it's on top of everything
        )
        .overlay(
            // Loading Screen (app startup) - Full screen modal above everything
            Group {
                if showingLoadingScreen {
                    LoadingScreenView()
                        .zIndex(1001) // Ensure it's on top of everything including onboarding
                        .transition(.identity) // No animation
                        .animation(.none, value: showingLoadingScreen) // Disable implicit animations
                        .onAppear {
                            NSLog("🔍 Loading screen appeared!")
                            // Hide loading screen after logo expansion has time to be visible (after 1.7 seconds)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                                NSLog("🔍 Hiding loading screen - after expansion")
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showingLoadingScreen = false
                                }
                            }
                        }
                }
            }
        )
        .overlay(
            // Onboarding Modal (first run only) - Full screen modal above everything
            Group {
                if showingOnboarding {
                    OnboardingView(isPresented: $showingOnboarding)
                        .zIndex(1000) // Ensure it's on top of everything
                        .transition(.identity) // No animation
                        .animation(.none, value: showingOnboarding) // Disable implicit animations
                }
            }
        )





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

// SettingsPage removed - functionality moved to SettingsModalView

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
    @Binding var isSettingsSheetExpanded: Bool
    
    var body: some View {
        // Main content
        ZStack {
            // Top navigation buttons - NOW EMPTY
            VStack {
                Spacer()
            }

            // Central visual design element with tabs - RESTORED ORIGINAL
            // Only show animations when neither sheet is expanded (per requirements)
            if !isSheetExpanded && !isSettingsSheetExpanded {
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
                .offset(y: -60) // Move up by 60 points to center in available space
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
