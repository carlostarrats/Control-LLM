import SwiftUI
import UIKit
import UniformTypeIdentifiers
import Lottie


// MARK: - Lottie View Wrapper -------------------------------------------------

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let isVisible: Bool
    
    init(name: String, loopMode: LottieLoopMode = .loop, isVisible: Bool = true) {
        self.name = name
        self.loopMode = loopMode
        self.isVisible = isVisible
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Try to load the animation
        var animation: LottieAnimation?
        
        // Method 1: Try named animation (this should work for assets)
        if let namedAnimation = LottieAnimation.named(name) {
            animation = namedAnimation
        }
        // Method 2: Try to load from the animations subdirectory
        else if let url = Bundle.main.url(forResource: "16cfa363-2720-425f-bcde-0cf315dd706a", withExtension: "json", subdirectory: "Animations.dataset/animations") {
            // Note: loadedFrom is async, so we can't use it here
            // We'll need to handle this differently
        }
        // Method 3: Try from bundle URL
        else if let url = Bundle.main.url(forResource: name, withExtension: "lottie") {
            // Found .lottie file
        }
        // Method 4: Try from main bundle path
        else if let path = Bundle.main.path(forResource: name, ofType: "lottie") {
            // Found .lottie file at path
        }
        
        if let animation = animation {
            animationView.animation = animation
            animationView.loopMode = loopMode
            animationView.contentMode = .scaleAspectFit
            animationView.play()
        } else {
            // Fallback: Create a simple loading indicator
            let fallbackView = createFallbackView()
            view.addSubview(fallbackView)
            fallbackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                fallbackView.topAnchor.constraint(equalTo: view.topAnchor),
                fallbackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                fallbackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                fallbackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        return view
    }
    
    private func createFallbackView() -> UIView {
        let fallbackView = UIView()
        fallbackView.backgroundColor = .clear
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for i in 0..<3 {
            let dot = UIView()
            dot.backgroundColor = UIColor.white
            dot.layer.cornerRadius = 2
            dot.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(dot)
            
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 4),
                dot.heightAnchor.constraint(equalToConstant: 4)
            ])
            
            // Animate the dot
            UIView.animate(withDuration: 0.6, delay: Double(i) * 0.2, options: [.repeat, .autoreverse], animations: {
                dot.transform = CGAffineTransform(translationX: 0, y: -2)
            })
        }
        
        fallbackView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: fallbackView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: fallbackView.centerYAnchor)
        ])
        
        return fallbackView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // CRITICAL FIX: Handle visibility state changes
        guard let animationView = uiView.subviews.first as? LottieAnimationView else { return }
        
        if isVisible {
            // Start animation when visible
            if !animationView.isAnimationPlaying {
                animationView.play()
            }
        } else {
            // Stop animation when not visible
            if animationView.isAnimationPlaying {
                animationView.stop()
            }
        }
    }
}

// MARK: - Custom Button Style (No Haptic)
private struct NoHapticButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - No Haptic Button Wrapper
private struct NoHapticButton: UIViewRepresentable {
    let isStopButton: Bool
    let colorManager: ColorManager
    let action: () -> Void
    
    func makeUIView(context: Context) -> NoHapticUIButton {
        let button = NoHapticUIButton(type: .system)
        
        // Configure button appearance
        if isStopButton {
            button.setTitle("■", for: .normal)
        } else {
            button.setImage(UIImage(systemName: "arrow.up")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
            ), for: .normal)
        }
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(UIColor(Color(hex: "#1D1D1D")), for: .normal)
        button.tintColor = UIColor(Color(hex: "#1D1D1D"))
        button.backgroundColor = isStopButton ? UIColor(Color.red.opacity(0.8)) : UIColor(Color.blue.opacity(0.8))
        button.layer.cornerRadius = 4
        button.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        
        // Disable all haptic feedback
        button.showsTouchWhenHighlighted = false
        
        // Remove all existing gesture recognizers and add custom one
        if let existingGestures = button.gestureRecognizers {
            for gesture in existingGestures {
                button.removeGestureRecognizer(gesture)
            }
        }
        
        // Add custom tap gesture recognizer
        let tapGesture = NoHapticTapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.buttonTapped))
        button.addGestureRecognizer(tapGesture)
        
        return button
    }
    
    func updateUIView(_ uiView: NoHapticUIButton, context: Context) {
        if isStopButton {
            uiView.setTitle("■", for: .normal)
        } else {
            uiView.setImage(UIImage(systemName: "arrow.up")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
            ), for: .normal)
        }
        uiView.backgroundColor = isStopButton ? UIColor(Color.red.opacity(0.8)) : UIColor(Color.blue.opacity(0.8))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    class Coordinator: NSObject {
        let action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func buttonTapped() {
            action()
        }
    }
}

// MARK: - Custom UIButton that disables haptic feedback
private class NoHapticUIButton: UIButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Disable haptic feedback by overriding the touch method
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Disable haptic feedback by overriding the touch method
        super.touchesEnded(touches, with: event)
    }
    
    // Override to disable haptic feedback completely
    override var isHighlighted: Bool {
        get { return super.isHighlighted }
        set { 
            // Don't call super.setter to prevent haptic feedback
            // super.isHighlighted = newValue
        }
    }
}

// MARK: - Custom Tap Gesture Recognizer that disables haptic feedback
private class NoHapticTapGestureRecognizer: UITapGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Disable haptic feedback
        super.touchesBegan(touches, with: event!)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Disable haptic feedback
        super.touchesEnded(touches, with: event!)
    }
}

// MARK: - Chat screen --------------------------------------------------------

struct TextModalView: View {
    // View-models
    @ObservedObject var viewModel: MainViewModel          // your existing VM
    // REMOVED: @StateObject private var llm = ChatViewModel()        // NEW: streams reply
    
    // CRITICAL FIX: Unique view identifier that changes on app restart to force SwiftUI view recreation
    private let viewIdentifier: String = "TextModalView_\(Date().timeIntervalSince1970)"
    
    
    init(viewModel: MainViewModel, isPresented: Binding<Bool>, isSheetExpanded: Binding<Bool>? = nil, messageHistory: [ChatMessage]? = nil) {
        self.viewModel = viewModel
        self._isPresented = isPresented
        self._isSheetExpanded = isSheetExpanded ?? .constant(false)
        self.messageHistory = messageHistory ?? []
        
        NSLog("TextModalView: Created with unique identifier: \(self.viewIdentifier)")
    }

    // UI state
    @Binding var isPresented: Bool
    @Binding var isSheetExpanded: Bool
    @State private var messageText = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var showingDocumentPicker = false
    @State private var showingModelsSheet = false
    @State private var isSendButtonPressed = false

    @State private var inputBarHeight: CGFloat = 0
    @State private var opacityUpdateTimer: Timer?
    @State private var keyboardHeight: CGFloat = 0
    @State private var scrollToBottomCounter = 0
    @State private var showGeneratingText = false {
        didSet {
            NSLog("TextModalView: showGeneratingText changed from \(oldValue) to \(showGeneratingText)")
        }
    }
    @State private var isButtonProcessing = false {
        didSet {
            NSLog("TextModalView: isButtonProcessing changed from \(oldValue) to \(isButtonProcessing)")
        }
    }
    @State private var timeUpdateTimer: Timer?
    @State private var currentTime = Date()

    @State private var isClipboardMessage = false
    @State private var hasAddedFollowUpQuestions = false
    var messageHistory: [ChatMessage]?
    @EnvironmentObject var colorManager: ColorManager
    
    // MARK: - Computed Properties
    private var hasModelsInstalled: Bool {
        !ModelManager.shared.availableModels.isEmpty
    }
    
    // MARK: - Force Reset Function
    private func forceResetProcessingState() {
        // CRITICAL FIX: Stop all polling and reset all processing states
        NSLog("TextModalView: forceResetProcessingState() called - resetting showGeneratingText to false")
        isPolling = false
        pollCount = 0
        isLocalProcessing = false
        effectiveIsProcessing = false
        showGeneratingText = false
        
        // CRITICAL FIX: Reset ChatViewModel state
        viewModel.llm.isProcessing = false
        // viewModel.llm.transcript = "" // REMOVED: Don't clear transcript
        
        // CRITICAL FIX: Clear any empty assistant messages to prevent multiple empty messages
        viewModel.messages.removeAll { message in
            !message.isUser && message.content.isEmpty
        }
    }
    
    // MARK: - Helper Functions
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            keyboardHeight = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }


    // MARK: body -------------------------------------------------------------
    var body: some View {
        let _ = NSLog("TextModalView: BODY RE-RENDERING - effectiveIsProcessing: \(effectiveIsProcessing), isProcessing: \(viewModel.llm.isProcessing), transcript length: \(viewModel.llm.transcript.count)")
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background gradient when expanded, transparent when collapsed
                if isSheetExpanded {
                    LinearGradient(
                        colors: [Color(hex: "#1D1D1D"), Color(hex: "#141414")],
                        startPoint: .top, endPoint: .bottom
                    )
                    .ignoresSafeArea(.all)
                } else {
                    Color.clear
                    .ignoresSafeArea(.all)
                }
                
                // Purple gradient overlay - extends from top to bottom of screen
                VStack(spacing: 0) {
                    // Gradient that extends from the top of the screen down to the bottom
                    LinearGradient(
                        colors: [
                            colorManager.purpleColor.opacity(isSheetExpanded ? 0.0 : 1.0), 
                            colorManager.purpleColor.opacity(isSheetExpanded ? 0.0 : 1.0)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(maxHeight: .infinity) // Extend to full height
                    .allowsHitTesting(false)
                }
                .allowsHitTesting(false)
                
                // Content layer
                VStack(spacing: 0) {
                    // Header with close button - transparent background to allow gradient through
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Image(systemName: "bubble.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(isSheetExpanded ? colorManager.purpleColor : Color(hex: "#141414"))
                                .padding(.trailing, 6)
                            
                            Text(headerText)
                                .font(.custom("IBMPlexMono", size: 12))
                                .foregroundColor(headerTextColor)
                                .padding(.leading, 0)
                            
                            Spacer()
                            
                            // Cursor rays when collapsed, X when expanded
                            if isSheetExpanded {
                                Button(action: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        isSheetExpanded = false
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(colorManager.orangeColor)
                                        .frame(width: 20, height: 20)
                                        .contentShape(Rectangle())
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.trailing, 0)
                            } else {
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(hex: "#141414"))
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 0)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, isSheetExpanded ? 0 : 14)
                    .padding(.bottom, 10)
                    .background(Color.clear) // Make header background transparent
                    
                    // Message list - expand to fill available space
                    messageList
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Input bar - positioned at bottom when sheet is expanded
                if isSheetExpanded {
                    VStack {
                        Spacer()
                        inputBar
                            .padding(.bottom, keyboardHeight > 0 ? 0 : max(geometry.safeAreaInsets.bottom, 20))
                    }
                    .offset(y: keyboardHeight > 0 ? -keyboardHeight + max(geometry.safeAreaInsets.bottom, 20) : 0)
                }
                
                
            }
        }
        .onChange(of: viewModel.llm.latestToken) { _, newToken in
            // SIMPLIFIED: Only handle non-empty tokens and ensure we have an assistant message
            guard !newToken.isEmpty else { return }
            
            // Find the last assistant message
            if let lastAssistantIndex = viewModel.messages.lastIndex(where: { !$0.isUser }) {
                viewModel.messages[lastAssistantIndex].content += newToken
                NSLog("TextModalView: Appended token to message at index \(lastAssistantIndex)")
                
                // CRITICAL: Scroll to keep content above input bar when streaming
                DispatchQueue.main.async {
                    scrollToBottomCounter += 1
                }
            } else {
                // Create new assistant message if none exists
                let assistantMessage = ChatMessage(
                    content: newToken,
                    isUser: false,
                    timestamp: Date()
                )
                viewModel.messages.append(assistantMessage)
                NSLog("TextModalView: Created new assistant message with token")
            }
        }
        .onAppear {
            setupOpacityUpdateTimer()
            setupTimeUpdateTimer()
            
            // Reset clipboard message state when view appears
            isClipboardMessage = false
            hasAddedFollowUpQuestions = false
            
            // Also reset the ChatViewModel's duplicate detection to ensure clean state
            viewModel.llm.lastSentMessage = nil
            
            // CRITICAL FIX: Force reset processing state to ensure clean start
            forceResetProcessingState()
            
            // CRITICAL FIX: Reset showGeneratingText FIRST to ensure clean state
            NSLog("TextModalView: onAppear - resetting showGeneratingText to false")
            showGeneratingText = false
            
            // CRITICAL FIX: Synchronize processing state when view appears
            syncProcessingState()
            
            // CRITICAL FIX: Update effective processing state on view creation
            updateEffectiveProcessingState()
            
            // CRITICAL FIX: Clear any empty assistant messages on app start to prevent multiple empty messages
            viewModel.messages.removeAll { message in
                !message.isUser && message.content.isEmpty
            }
            
            // Setup keyboard observers
            setupKeyboardObservers()
            
            // CRITICAL FIX: Ensure polling is stopped on view appear
            isPolling = false
            pollCount = 0
            
            // CRITICAL FIX: Removed clipboard message observer setup - consolidated into single message flow
        }
        .onChange(of: viewModel.llm.isProcessing) { oldValue, isProcessing in
            NSLog("TextModalView: onChange(viewModel.llm.isProcessing) triggered - old: \(oldValue), new: \(isProcessing)")
            // CRITICAL FIX: Update effective processing state when llm.isProcessing changes
            updateEffectiveProcessingState()
            
            // CRITICAL FIX: Reset button processing flag when LLM generation completes
            if oldValue == true && isProcessing == false {
                NSLog("TextModalView: LLM generation completed - resetting button lock")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NSLog("TextModalView: RESETTING isButtonProcessing = false (generation completed)")
                    isButtonProcessing = false
                }
                
                // DEBUGGING: Clean up empty assistant messages when processing stops
                let emptyCount = viewModel.messages.filter { !$0.isUser && $0.content.isEmpty }.count
                NSLog("TextModalView: Found \(emptyCount) empty assistant messages when processing stopped")
                viewModel.messages.removeAll { message in
                    !message.isUser && message.content.isEmpty
                }
                NSLog("TextModalView: Cleaned up empty assistant messages")
            }
            
            // REMOVED: Redundant sync mechanism - real-time transcript updates should handle content updates
            
            // CRITICAL FIX: Cancel any pending timer
            showGeneratingTextTimer?.invalidate()
            showGeneratingTextTimer = nil
            
            // Add delay for generating text and stop button
            if isProcessing {
                showGeneratingText = false
                showGeneratingTextTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
                    showGeneratingText = true
                }
            } else {
                showGeneratingText = false
            }
        }
        .onChange(of: isLocalProcessing) { _, newValue in
            NSLog("TextModalView: onChange(isLocalProcessing) triggered - new value: \(newValue)")
            // CRITICAL FIX: Update effective processing state when isLocalProcessing changes
            updateEffectiveProcessingState()
        }
        .onChange(of: viewModel.isFileProcessing) { _, isFileProcessing in
            // CRITICAL FIX: Reset showGeneratingText when file processing completes
            if !isFileProcessing {
                showGeneratingText = false
            }
        }
        .onDisappear {
            opacityUpdateTimer?.invalidate()
            opacityUpdateTimer = nil
            timeUpdateTimer?.invalidate()
            timeUpdateTimer = nil
            showGeneratingTextTimer?.invalidate()
            showGeneratingTextTimer = nil
            
            // CRITICAL FIX: Stop all polling and reset processing state on disappear
            isPolling = false
            pollCount = 0
            isLocalProcessing = false
            showGeneratingText = false
            
            // Dismiss keyboard when view disappears
            isTextFieldFocused = false
            hideKeyboard()
            
            // Cleanup keyboard observers
            removeKeyboardObservers()
            
            // CRITICAL FIX: Removed clipboard message observer cleanup - consolidated into single message flow
        }
                        .onReceive(NotificationCenter.default.publisher(for: .modelDidChange)) { _ in
            
            // IMPORTANT: Preserve the user's follow-up question if it exists
            let lastUserMessage = viewModel.messages.last { $0.isUser }
            let hasFollowUpQuestion = lastUserMessage != nil && !lastUserMessage!.content.hasPrefix("Analyze this text")
            
            // CRITICAL FIX: Don't sync UI messages to ChatViewModel - this causes context loss
            
            // Reset all streaming state for new model
            isPolling = false
            pollCount = 0
            lastRenderedTranscript = ""
            lastTranscriptLength = 0
            lastSentMessage = ""
            isDuplicateMessage = false
            stableTranscriptCount = 0
            hasProvidedCompletionHaptic = false
            
            // CRITICAL FIX: Force reset all processing states on model change
            isLocalProcessing = false
            showGeneratingText = false
            effectiveIsProcessing = false
            
            // CRITICAL FIX: Also reset local UI state to match ChatViewModel
            // This ensures the UI is properly synchronized after model changes
            if !viewModel.llm.isProcessing {
                // If ChatViewModel is not processing, ensure our local state matches
                // This prevents the UI from thinking it's in a processing state when it's not
            }
            
            // Reset clipboard message state
            isClipboardMessage = false
            hasAddedFollowUpQuestions = false
            
            // CRITICAL FIX: Clear empty assistant messages during model change to prevent multiple empty messages
            viewModel.messages.removeAll { message in
                !message.isUser && message.content.isEmpty
            }
            
            // IMPORTANT: Also reset the ChatViewModel's duplicate detection
            viewModel.llm.lastSentMessage = nil
            
            // CRITICAL FIX: Don't sync UI messages - preserve ChatViewModel history
            
            // If there was a follow-up question, we need to re-send it to the new model
            if hasFollowUpQuestion {
                SecureLogger.log("TextModalView: Preserving follow-up question for new model", sensitiveData: lastUserMessage!.content)
                // The question will be automatically re-sent by the ChatViewModel
            }
            
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissKeyboard)) { _ in
            // Dismiss keyboard and reset focus when navigating away from chat
            isTextFieldFocused = false
            hideKeyboard()
        }
        .fullScreenCover(isPresented: $showingModelsSheet) {
            SettingsModelsView()
        }
        .alert(NSLocalizedString("Error", comment: ""), isPresented: $showingError) {
            Button(NSLocalizedString("OK", comment: "")) { 
                errorMessage = nil
                showingError = false
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
        .onChange(of: viewModel.pendingClipboardPrompt) { _, newPrompt in
            if let prompt = newPrompt {
                SecureLogger.log("TextModalView: Processing pending clipboard prompt", sensitiveData: prompt)
                
                // Clear the pending prompt immediately to prevent re-processing
                viewModel.pendingClipboardPrompt = nil
                
                // Process as clipboard message
                isClipboardMessage = true
                hasAddedFollowUpQuestions = false
                
                // Set the message text and send it
                messageText = prompt
                Task {
                    await sendMessage()
                }
            }
        }
        .onAppear {
            NSLog("TextModalView: VIEW LIFECYCLE - onAppear called")
            NSLog("TextModalView: VIEW LIFECYCLE - effectiveIsProcessing on appear: \(effectiveIsProcessing)")
        }
        .onDisappear {
            NSLog("TextModalView: VIEW LIFECYCLE - onDisappear called")
        }
        .id(viewIdentifier) // CRITICAL FIX: Force SwiftUI to recreate entire view hierarchy on app restart
        .onChange(of: viewModel.messages) { oldMessages, newMessages in
            NSLog("TextModalView: ANIMATION STATE TRACKING - messages array changed")
            NSLog("TextModalView: ANIMATION STATE TRACKING - old count: \(oldMessages.count), new count: \(newMessages.count)")
            if let lastMessage = newMessages.last {
                NSLog("TextModalView: ANIMATION STATE TRACKING - last message isUser: \(lastMessage.isUser), content length: \(lastMessage.content.count)")
                NSLog("TextModalView: ANIMATION STATE TRACKING - last message content: '\(lastMessage.content)'")
            }
            NSLog("TextModalView: ANIMATION STATE TRACKING - effectiveIsProcessing: \(effectiveIsProcessing)")
            NSLog("TextModalView: ANIMATION STATE TRACKING - showGeneratingText: \(showGeneratingText)")
            NSLog("TextModalView: ANIMATION STATE TRACKING - isLocalProcessing: \(isLocalProcessing)")
        }


    }
    


    // MARK: - Opacity Update Timer -------------------------------------------
    
    private func setupOpacityUpdateTimer() {
        // Update opacity every minute to create smooth fade effect
        opacityUpdateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            // Trigger a UI update to recalculate opacity values
            // This will cause the view to refresh with new opacity values
        }
    }
    
    private func setupTimeUpdateTimer() {
        // Update time every minute to keep the display current
        timeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    // MARK: - Message Synchronization -----------------------------------------
    
    // REMOVED: syncUIMessagesToLLM function - was causing context loss by overwriting ChatViewModel history
    
    // MARK: - Clipboard Message Observer (REMOVED - consolidated into single message flow)
    
    // CRITICAL FIX: Removed separate clipboard message handling to prevent duplicate message processing
    // All messages now go through the unified sendMessage() function
    
    // MARK: - Response Completion Observer
    
    // MARK: - Message Management -------------------------------------------
    
    private func calculateMessageOpacity(for message: ChatMessage) -> Double {
        // All messages in current session have full opacity
        return 1.0
    }
    
    private func getMessagesGroupedByDate() -> [(Date, [ChatMessage])] {
        let messages = viewModel.messages
        guard !messages.isEmpty else { return [] }
        
        let calendar = Calendar.current
        
        // Group messages by day within the current session
        let grouped = Dictionary(grouping: messages) { message in
            calendar.startOfDay(for: message.timestamp)
        }
        
        // Sort by date (oldest first) and filter out empty groups
        var result: [(Date, [ChatMessage])] = []
        for (date, messages) in grouped {
            if !messages.isEmpty {
                let sortedMessages = messages.sorted { $0.timestamp < $1.timestamp }
                result.append((date, sortedMessages))
            }
        }
        return result.sorted { $0.0 < $1.0 }
    }
    
    // MARK: header removed - now part of scrollable content
    
    // Helper function to determine if we should show "SWIPE TO CHAT"
    private func shouldShowSwipeToChat() -> Bool {
        // If no messages, always show "SWIPE TO CHAT"
        if viewModel.messages.isEmpty {
            return true
        }
        
        // Check if messages are older than 24 hours
        if let firstMessage = viewModel.messages.first {
            let now = Date()
            let timeDifference = now.timeIntervalSince(firstMessage.timestamp)
            let twentyFourHours: TimeInterval = 24 * 60 * 60
            
            // If first message is older than 24 hours, show "SWIPE TO CHAT"
            if timeDifference > twentyFourHours {
                return true
            }
        }
        
        // Otherwise show time
        return false
    }
    
    // Helper function to get current time
    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: currentTime)
    }
    
    // Helper function to determine if we should show time in header
    private func shouldShowTimeInHeader() -> Bool {
        // If no messages, show "CONTROL LLM"
        if viewModel.messages.isEmpty {
            return false
        }
        
        // Check if messages are older than 24 hours
        if let firstMessage = viewModel.messages.first {
            let now = Date()
            let timeDifference = now.timeIntervalSince(firstMessage.timestamp)
            let twentyFourHours: TimeInterval = 24 * 60 * 60
            
            // If first message is older than 24 hours, show "CONTROL LLM"
            if timeDifference > twentyFourHours {
                return false
            }
        }
        
        // Otherwise show time
        return true
    }
    
    // Computed properties to break up complex expressions
    private var headerText: String {
        shouldShowTimeInHeader() ? getCurrentTime() : NSLocalizedString("INTERFACE", comment: "")
    }
    
    private var headerTextColor: Color {
        isSheetExpanded ? colorManager.purpleColor : Color(hex: "#141414")
    }
    
    // MARK: - Localized Font Sizing
    private var localizedPlaceholderFont: Font {
        let currentLanguage = Locale.current.languageCode ?? "en"
        switch currentLanguage {
        case "fr", "es":
            return .custom("IBMPlexMono", size: 12) // Smaller for French/Spanish
        default:
            return .custom("IBMPlexMono", size: 16) // Original size for English
        }
    }
    
    private var localizedGeneratingFont: Font {
        let currentLanguage = Locale.current.languageCode ?? "en"
        switch currentLanguage {
        case "fr", "es":
            return .custom("IBMPlexMono", size: 12) // Smaller for French/Spanish
        default:
            return .custom("IBMPlexMono", size: 16) // Original size for English
        }
    }

    // MARK: message list -----------------------------------------------------
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 24) {
                    // No grabber or time display - clean interface
                    
                    if !hasModelsInstalled {
                        noModelMessage
                    } else {
                        normalMessageList
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, isSheetExpanded ? 0 : 14)
                .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 24 : 24)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 200)
            }
                // Removed final scroll - only use streaming scroll mechanism
            .onChange(of: viewModel.messages) { _, newMessages in
                if let last = newMessages.last, !last.content.isEmpty {
                    withAnimation(.spring()) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            // REMOVED: Conflicting transcript onChange handler - now using latestToken only
        }
    }
    
    // MARK: - No Model Message
    private var noModelMessage: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 200)
            
            Text(NSLocalizedString("Nothing to see here (yet) 🤖", comment: ""))
                .font(.custom("IBMPlexMono", size: 16))
                .foregroundColor(Color(hex: "#666666"))
                .multilineTextAlignment(.center)
            
            Button(action: {
                showingModelsSheet = true
            }) {
                Text(NSLocalizedString("Download Model", comment: ""))
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#141414"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(colorManager.purpleColor)
                    .cornerRadius(4)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
                .frame(height: 200)
        }
    }
    
    // MARK: - Normal Message List
    private var normalMessageList: some View {
        ForEach(Array(getMessagesGroupedByDate().enumerated()), id: \.element.0) { index, dateAndMessages in
            let (date, messages) = dateAndMessages
            VStack(spacing: 24) {
                ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                    MessageBubble(
                        message: message,
                        opacity: calculateMessageOpacity(for: message),
                        messageHistory: messages,
                        currentIndex: index,
                        isProcessing: viewModel.llm.isProcessing,
                        isLocalProcessing: isLocalProcessing
                    )
                    .id(message.id)
                }
            }
        }
    }

    // MARK: input bar --------------------------------------------------------
    private var inputBar: some View {
        VStack {
            HStack(alignment: .center, spacing: 12) {
                // Plus button with full-height background matching input bar
                ZStack {
                    Color(hex: "#0f0f0f")
                    Button(action: {
                        showingDocumentPicker = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(hasModelsInstalled ? colorManager.greenColor : Color(hex: "#666666"))
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(!hasModelsInstalled)
                    .fileImporter(
                        isPresented: $showingDocumentPicker,
                        allowedContentTypes: [.text, .plainText, .data],
                        allowsMultipleSelection: false
                    ) { result in
                        switch result {
                        case .success(let urls):
                            if let url = urls.first {
                                handleFileUpload(url)
                            }
                        case .failure(let error):
                            break
                        }
                    }
                }
                .frame(width: 44, height: 44)
                .cornerRadius(4)

                // Text field
                TextField("Ask anything...", text: $messageText, axis: .vertical)
                    .font(.custom("IBMPlexMono", size: 16))
                    .foregroundColor(colorManager.purpleColor)
                    .focused($isTextFieldFocused)
                    .padding(.leading, 16)
                    .padding(.trailing, trailingPadding)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#0f0f0f"))
                    .cornerRadius(4)
                    .disabled(viewModel.llm.isProcessing || !hasModelsInstalled) // Disable during LLM response or when no models
                    .onChange(of: viewModel.llm.isProcessing) { _, isProcessing in
                        // CRITICAL FIX: Clear messageText when processing state changes to prevent corruption
                        if !isProcessing && !messageText.isEmpty {
                            messageText = ""
                        }
                        
                        // CRITICAL FIX: Reset isLocalProcessing when llm.isProcessing changes to false
                        if !isProcessing {
                            isLocalProcessing = false
                        }
                        
                        // CRITICAL FIX: Update effective processing state when llm.isProcessing changes
                        updateEffectiveProcessingState()
                    }
                    .onChange(of: messageText) { _, _ in
                        if !viewModel.llm.isProcessing && hasModelsInstalled { // Only play sound if not processing and models available
                            FeedbackService.shared.playSound(.keyPress)
                        }
                    }
                    .onTapGesture {
                        if !viewModel.llm.isProcessing && hasModelsInstalled { // Only allow focus if not processing and models available
                            isTextFieldFocused = true
                        }
                    }
                    .overlay(placeholderOverlay.allowsHitTesting(false), alignment: .leading) // Fix placeholder tap issue
                    .overlay(
                        Group {
                            if viewModel.llm.isProcessing && showGeneratingText {
                                generatingOverlay.allowsHitTesting(false)
                            }
                        }, alignment: .leading
                    ) // Generating response overlay - with delay
                    .overlay(sendButtonOverlay, alignment: .trailing) // Send button - always visible
                    .animation(.easeInOut(duration: 0.05), value: isTextFieldFocused)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
        // Remove full-width bar; keep only plus button and TextField.
        .background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: InputBarHeightKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(InputBarHeightKey.self) { height in
            inputBarHeight = height
        }
    }

    // trailing padding changes when send-button visible
    private var trailingPadding: CGFloat {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        // Show button if there's text OR if LLM is processing (for stop button), but only if models are available
        return (!hasModelsInstalled || (trimmedText.isEmpty && !viewModel.llm.isProcessing)) ? 16 : 50
    }

    private struct InputBarHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }

    // placeholder
    @ViewBuilder private var placeholderOverlay: some View {
        if messageText.isEmpty && !(viewModel.llm.isProcessing || isLocalProcessing) {
            HStack {
                Group { // Group to apply a single transition
                    if !hasModelsInstalled {
                        Text(NSLocalizedString("Download model to chat...", comment: ""))
                    } else {
                        Text(NSLocalizedString("Ask Anything…", comment: ""))
                    }
                }
                .font(localizedPlaceholderFont)
                .foregroundColor(Color(hex: "#666666"))
                .transition(.identity) // Use .identity for instant change to sync with button

                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
    
    // generating response overlay - always visible when processing
    @ViewBuilder private var generatingOverlay: some View {
        let _ = NSLog("TextModalView: GENERATING OVERLAY - effectiveIsProcessing: \(effectiveIsProcessing), showing: \(effectiveIsProcessing)")
        let _ = NSLog("TextModalView: GENERATING OVERLAY - isLocalProcessing: \(isLocalProcessing), showGeneratingText: \(showGeneratingText)")
        if effectiveIsProcessing {
            HStack {
                Text(NSLocalizedString("Generating response...", comment: ""))
                    .font(localizedGeneratingFont)
                    .foregroundColor(Color(hex: "#666666"))
                    .transition(.identity)
                    .onAppear {
                    }
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }

    // send button overlay
    @ViewBuilder private var sendButtonOverlay: some View {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        if (!trimmedText.isEmpty || effectiveIsProcessing) && hasModelsInstalled {
            HStack {
                Spacer()
                Group {
                    if showGeneratingText {
                        // Stop button (square icon)
                        Text(NSLocalizedString("■", comment: ""))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "#1D1D1D"))
                            .frame(width: 32, height: 32)
                            .background(colorManager.redColor)
                            .cornerRadius(4)
                            .transition(.identity) // Instant in, instant out
                    } else {
                        // Send button (arrow icon)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "#1D1D1D"))
                            .frame(width: 32, height: 32)
                            .background(colorManager.purpleColor)
                            .cornerRadius(4)
                            .transition(.identity) // Reverted: Instant in, instant out
                    }
                }
                .scaleEffect(isSendButtonPressed ? 0.95 : 1.0)
                .opacity(isSendButtonPressed ? 0.8 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isSendButtonPressed)
                .onTapGesture {
                    // CRITICAL DEBUG: Track automatic button clicks
                    NSLog("TextModalView: onTapGesture TRIGGERED - investigating automatic double-tap")
                    NSLog("TextModalView: Call stack trace:")
                    Thread.callStackSymbols.enumerated().forEach { index, symbol in
                        NSLog("TextModalView: [\(index)] \(symbol)")
                    }
                    NSLog("TextModalView: End of call stack trace")
                    
                    // CRITICAL FIX: Button should act based on current state, not display state
                    // Use viewModel.llm.isProcessing for action logic, showGeneratingText for display
                    let isCurrentlyGenerating = viewModel.llm.isProcessing
                    NSLog("TextModalView: BUTTON CLICK - isProcessing: \(isCurrentlyGenerating), showGeneratingText: \(showGeneratingText)")
                    
                    if isCurrentlyGenerating {
                        // Stop button pressed - cancel ongoing generation (always allow this)
                        NSLog("TextModalView: STOP BUTTON PRESSED - Cancelling generation")
                        
                        // CRITICAL FIX: Reset button processing flag when generation is cancelled
                        NSLog("TextModalView: RESETTING isButtonProcessing = false (generation cancelled)")
                        isButtonProcessing = false
                        
                        // Cancel both LLM generation and PDF processing
                        viewModel.llm.stopGeneration()
                        viewModel.cancelFileProcessing()
                        
                        // No button lock needed for stop button - user intentionally clicked it
                    } else {
                        // Send button pressed - prevent double-clicks only for send button
                        NSLog("TextModalView: BUTTON TAP RECEIVED - isButtonProcessing: \(isButtonProcessing)")
                        guard !isButtonProcessing else {
                            NSLog("TextModalView: Send button click ignored - already processing")
                            return
                        }
                        
                        NSLog("TextModalView: SETTING isButtonProcessing = true")
                        isButtonProcessing = true
                        isSendButtonPressed = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isSendButtonPressed = false
                        }
                        
                        // Send button pressed - send new message
                        NSLog("TextModalView: SEND BUTTON PRESSED - Sending message")
                        
                        // Set focus state
                        isTextFieldFocused = false
                        NSLog("TextModalView: IMMEDIATE FEEDBACK - Button pressed, sending message")
                        
                        // Force keyboard dismissal using multiple methods for reliability
                        hideKeyboard()
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        
                        // Force TextField to lose focus completely
                        DispatchQueue.main.async {
                            self.isTextFieldFocused = false
                            self.hideKeyboard()
                            // Additional force dismissal
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        
                        Task {
                            await sendMessage()
                            
                            // CRITICAL FIX: Don't reset button processing flag here - it will be reset when generation completes
                            NSLog("TextModalView: Message sent, waiting for generation to complete before unlocking button")
                        }
                    }
                }
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                .padding(.trailing, 8)
            }
        }
    }

    // MARK: - BUTTON ACTION --------------------------------------------------
    private func sendMessage() async {
        NSLog("TextModalView: sendMessage() called")
        // Prevent sending if already processing or no models available
        guard !viewModel.llm.isProcessing else {
            NSLog("TextModalView: sendMessage() blocked - already processing")
            return
        }
        
        guard hasModelsInstalled else {
            return
        }
        
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { 
            return 
        }

        // Play sound for sending a message
        FeedbackService.shared.playSound(.messageSent)

        // Donate user's action to Shortcuts
        ShortcutsIntegrationHelper.shared.donateMessageSent(message: text)


        // Stop any existing polling before starting new message
        isPolling = false
        pollCount = 0
        
        // Check if this is the same message as last time
        // Special handling for clipboard messages - they should never be considered duplicates
        let isClipboardMessageFormat = text.hasPrefix(NSLocalizedString("Analyze this text (keep under 2000 tokens):", comment: ""))
        
        if isClipboardMessageFormat {
            // Clipboard messages are never duplicates - they always have different content
            isDuplicateMessage = false
        } else {
            // Normal duplicate detection for regular messages
            isDuplicateMessage = text == lastSentMessage
        }
        
        lastSentMessage = text
        
        // Allow re-sending if this is a duplicate but we're in a new context (e.g., after model switch)
        // Check if the transcript has changed or if we're in a new model context
        let isNewContext = viewModel.llm.transcript.isEmpty || 
                          viewModel.llm.lastLoadedModel != lastLoadedModelForDuplicateCheck
        lastLoadedModelForDuplicateCheck = viewModel.llm.lastLoadedModel
        
        if isDuplicateMessage && isNewContext {
            isDuplicateMessage = false
        } else if isDuplicateMessage {
            return
        }
        
        // Set local processing state after duplicate check passes
        isLocalProcessing = true
        
        // CRITICAL FIX: Only remove empty assistant messages to prevent multiple empty messages
        // This preserves completed responses while preventing empty message accumulation
        viewModel.messages.removeAll { message in
            !message.isUser && message.content.isEmpty
        }
        
        // Force UI refresh by updating lastRenderedTranscript
        lastRenderedTranscript = ""
        
        // Reset animation state for new message
        isPolling = false
        pollCount = 0
        isDuplicateMessage = false
        
        // Reset haptic feedback tracking for new response
        stableTranscriptCount = 0
        hasProvidedCompletionHaptic = false

        
        // CRITICAL FIX: Set LLM processing state BEFORE sending message to prevent UI state loss during view recreation
        viewModel.llm.isProcessing = true
        
        // CRITICAL FIX: Send through MainViewModel which handles user message creation and LLM sending
        await viewModel.sendTextMessage(text)

        // Reset clipboard message state for normal chat messages
        isClipboardMessage = false
        hasAddedFollowUpQuestions = false

        // CRITICAL FIX: Check if file processing occurred - if so, skip placeholder and polling
        let hasProcessedData = await LargeFileProcessingService.shared.hasProcessedData()
        if viewModel.selectedFileUrl != nil || hasProcessedData {
            // Clear message text synchronously to prevent corruption
            messageText = ""
            return
        }

        // 2) placeholder assistant bubble (create immediately, not with delay)
        // BUT: Don't create placeholder if file processing is happening
        NSLog("TextModalView: isFileProcessing = \(viewModel.isFileProcessing)")
        if !viewModel.isFileProcessing {
            let placeholder = ChatMessage(
                content: "",
                isUser: false,
                timestamp: Date(),
                messageType: .text
            )
            viewModel.messages.append(placeholder)
            NSLog("TextModalView: Created empty placeholder message immediately")
            NSLog("TextModalView: viewModel.messages count after creation: \(viewModel.messages.count)")
            NSLog("TextModalView: Last message isUser: \(viewModel.messages.last?.isUser ?? false), content: '\(viewModel.messages.last?.content ?? "nil")'")
        } else {
            NSLog("TextModalView: Skipped empty message creation - file processing is active")
        }
        
        // 3) clear field + ask model (keyboard already dismissed)
        messageText = ""
        // Note: viewModel.llm.send(text) is already called by ChatViewModel.sendTextMessage
        // No need to duplicate the LLM call here
        
        // 4) start polling the stream immediately for real-time word streaming
        // BUT: Don't poll if file processing is happening (file processing handles its own results)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NSLog("TextModalView: POLLING SETUP - Starting polling mechanism")
            NSLog("TextModalView: POLLING SETUP - viewModel.isFileProcessing: \(viewModel.isFileProcessing)")
            if viewModel.isFileProcessing {
                NSLog("TextModalView: POLLING SETUP - File processing active, skipping polling")
                isPolling = false
                isLocalProcessing = false
            } else {
                NSLog("TextModalView: POLLING SETUP - Starting polling for real-time updates")
                isPolling = true
                pollCount = 0
                monitorAssistantStream()
            }
        }
        
    }
    
    // MARK: - Error Handling --------------------------------------------------
    private func getErrorMessage(for error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.domain {
        case "LLMService":
            switch nsError.code {
            case 6: // Prompt too long
                return NSLocalizedString("Your message is too long. Please shorten it and try again.", comment: "")
            case 11: // Another model operation in progress
                return NSLocalizedString("Another model operation is in progress. Please wait and try again.", comment: "")
            case 12: // Model name not available
                return NSLocalizedString("Model not available. Please check your model settings.", comment: "")
            case 17: // Invalid context pointer
                return NSLocalizedString("Model error. Please try restarting the app.", comment: "")
            case 18: // Empty prompt
                return NSLocalizedString("Empty message. Please type something and try again.", comment: "")
            case 19: // Invalid strings
                return NSLocalizedString("Message format error. Please try again.", comment: "")
            case 20: // Streaming timeout
                return NSLocalizedString("Response took too long. Please try a shorter message.", comment: "")
            case 27: // Token limit reached
                return NSLocalizedString("Response was cut off due to length. Try asking a more specific question.", comment: "")
            default:
                return String(format: NSLocalizedString("LLM Error: %@", comment: ""), nsError.localizedDescription)
            }
        case "ChatViewModel":
            switch nsError.code {
            case 1: // No model selected
                return NSLocalizedString("No model selected. Please choose a model in Settings.", comment: "")
            case 2: // Model loading failed
                return NSLocalizedString("Failed to load model. Please try again or select a different model.", comment: "")
            default:
                return String(format: NSLocalizedString("Chat Error: %@", comment: ""), nsError.localizedDescription)
            }
        default:
            return String(format: NSLocalizedString("Error: %@", comment: ""), error.localizedDescription)
        }
    }
    

    
    // MARK: - STREAM POLLER --------------------------------------------------
    
    // CRITICAL FIX: Ensure isLocalProcessing is synchronized with llm.isProcessing on view creation
    private func syncProcessingState() {
        NSLog("TextModalView: syncProcessingState called")
        NSLog("TextModalView: viewModel.llm.isProcessing = \(viewModel.llm.isProcessing)")
        NSLog("TextModalView: isLocalProcessing = \(isLocalProcessing)")
        NSLog("TextModalView: showGeneratingText = \(showGeneratingText)")
        if viewModel.llm.isProcessing {
            isLocalProcessing = true
        } else {
            isLocalProcessing = false
            // CRITICAL FIX: Also reset showGeneratingText when not processing
            showGeneratingText = false
        }
        NSLog("TextModalView: After sync - isLocalProcessing = \(isLocalProcessing)")
        NSLog("TextModalView: After sync - showGeneratingText = \(showGeneratingText)")
    }
    
    // CRITICAL FIX: State variable to track effective processing state (already declared above)
    
    // CRITICAL FIX: Timer to cancel delayed showGeneratingText updates
    @State private var showGeneratingTextTimer: Timer?
    
    // CRITICAL FIX: Function to update effective processing state
    private func updateEffectiveProcessingState() {
        NSLog("TextModalView: updateEffectiveProcessingState called")
        NSLog("TextModalView: viewModel.llm.isProcessing = \(viewModel.llm.isProcessing)")
        NSLog("TextModalView: isLocalProcessing = \(isLocalProcessing)")
        NSLog("TextModalView: current effectiveIsProcessing = \(effectiveIsProcessing)")
        
        let newValue = viewModel.llm.isProcessing || isLocalProcessing
        NSLog("TextModalView: calculated newValue = \(newValue)")
        
        if newValue != effectiveIsProcessing {
            NSLog("TextModalView: effectiveIsProcessing changing from \(effectiveIsProcessing) to \(newValue)")
            effectiveIsProcessing = newValue
        } else {
            NSLog("TextModalView: effectiveIsProcessing unchanged (\(effectiveIsProcessing))")
        }
        
        // CRITICAL FIX: Reset showGeneratingText when not processing
        if !effectiveIsProcessing {
            NSLog("TextModalView: Resetting showGeneratingText to false")
            showGeneratingText = false
        }
    }
    // All state variables already declared above
    
    // MARK: - Error Handling State
    @State private var errorMessage: String?
    @State private var showingError = false
    
    // MARK: - Additional State Variables
    @State private var lastRenderedTranscript = ""
    @State private var isPolling = false
    @State private var pollCount = 0
    @State private var isLocalProcessing = false
    @State private var lastTranscriptLength = 0
    @State private var lastSentMessage = ""
    @State private var isDuplicateMessage = false
    @State private var lastLoadedModelForDuplicateCheck: String? = nil
    @State private var stableTranscriptCount = 0
    @State private var hasProvidedCompletionHaptic = false
    @State private var effectiveIsProcessing = false
    
    // Voice integration state
    // Voice functionality removed

    private let maxPollCount = 300 // 30 seconds max (300 * 0.1s)

    private func monitorAssistantStream() {
        guard isPolling else { 
            NSLog("TextModalView: monitorAssistantStream - not polling, returning")
            return 
        }
        
        NSLog("TextModalView: monitorAssistantStream - poll count: \(pollCount)")
        NSLog("TextModalView: monitorAssistantStream - viewModel.llm.isProcessing: \(viewModel.llm.isProcessing)")
        NSLog("TextModalView: monitorAssistantStream - transcript length: \(viewModel.llm.transcript.count)")
        NSLog("TextModalView: monitorAssistantStream - transcript content: '\(viewModel.llm.transcript)'")
        
        // CRITICAL FIX: Check the actual message content instead of transcript
        let lastAssistantMessage = viewModel.messages.last { !$0.isUser }
        let actualContent = lastAssistantMessage?.content ?? ""
        NSLog("TextModalView: monitorAssistantStream - actual message content: '\(actualContent)'")
        
        // CRITICAL FIX: Check if LLM is actually processing - if not, stop polling immediately
        if !viewModel.llm.isProcessing {
            NSLog("TextModalView: monitorAssistantStream - LLM not processing, stopping polling")
            isPolling = false
            isLocalProcessing = false
            showGeneratingText = false
            return
        }
        
        // Check if file processing failed - stop polling immediately
        if let fileError = viewModel.fileProcessingError {
            isPolling = false
            isLocalProcessing = false
            
            // Find and update the placeholder message to show the error
            if let placeholderIndex = viewModel.messages.firstIndex(where: { !$0.isUser && $0.content.isEmpty }) {
                viewModel.messages[placeholderIndex].content = "❌ \(fileError)"
            }
            
            return
        }
        
        // Check if file processing is still in progress - if not, stop polling
        if viewModel.isFileProcessing == false {
            isPolling = false
            isLocalProcessing = false
            // CRITICAL FIX: Reset showGeneratingText when file processing completes
            showGeneratingText = false
            return
        }
        
        // CRITICAL FIX: Use actual message content instead of transcript
        let currentTranscriptLength = actualContent.count
        let currentTranscript = actualContent
        
        SecureLogger.log("TextModalView: Polling transcript", sensitiveData: "length: \(currentTranscriptLength), content: \(currentTranscript)")
        
        // Check if we should stop polling - give clipboard messages more time for analysis
        let maxPolls = isClipboardMessage ? 300 : 150  // 30 seconds for clipboard, 15 seconds for regular messages
        if pollCount > maxPolls {
            isPolling = false
            FeedbackService.shared.playHaptic(.light)
            
            // Show timeout error
            errorMessage = NSLocalizedString("Response took too long. Please try a shorter message or check your model settings.", comment: "")
            showingError = true
            
            // Add follow-up questions for clipboard messages if not already added
            addFollowUpQuestionsIfNeeded()
            return
        }
        
        // FIXED: Better detection for streaming loops and stuck responses
        if currentTranscriptLength == lastTranscriptLength && currentTranscript == lastRenderedTranscript {
            // No change - increment stable count
            stableTranscriptCount += 1
            
            // FIXED: Detect streaming loops where LLM keeps generating same content
            if stableTranscriptCount >= 3 && !currentTranscript.isEmpty {
                isPolling = false
                isLocalProcessing = false // Reset local processing state
                
                // Add follow-up questions for clipboard messages if not already added
                addFollowUpQuestionsIfNeeded()
                return
            }
            
            // Check if transcript has been stable for 3 consecutive polls (600ms)
            // This indicates the response is likely complete
            if stableTranscriptCount >= 3 && !hasProvidedCompletionHaptic && !currentTranscript.isEmpty {
                hasProvidedCompletionHaptic = true
                
                // Add follow-up questions for clipboard messages if not already added
                addFollowUpQuestionsIfNeeded()
                
                // Stop polling when response is complete
                isPolling = false
                isLocalProcessing = false // Reset local processing state
                
                // CRITICAL FIX: Reset showGeneratingText when response is complete
                showGeneratingText = false
                
                // CRITICAL FIX: DO NOT clear transcript - keep the generated content visible
                // The transcript should retain the generated response for the user to see
                return
            }
            
            // CRITICAL FIX: Check for new content before continuing polling
            NSLog("TextModalView: monitorAssistantStream - Checking content change")
            NSLog("TextModalView: monitorAssistantStream - actualContent: '\(actualContent)'")
            NSLog("TextModalView: monitorAssistantStream - lastRenderedTranscript: '\(lastRenderedTranscript)'")
            NSLog("TextModalView: monitorAssistantStream - actualContent.isEmpty: \(actualContent.isEmpty)")
            NSLog("TextModalView: monitorAssistantStream - actualContent != lastRenderedTranscript: \(actualContent != lastRenderedTranscript)")
            
            if !actualContent.isEmpty && actualContent != lastRenderedTranscript {
                NSLog("TextModalView: monitorAssistantStream - New content detected, stopping polling")
                NSLog("TextModalView: monitorAssistantStream - Content: '\(actualContent)'")
                lastRenderedTranscript = actualContent
                lastTranscriptLength = actualContent.count
                pollCount = 0 // Reset counter when transcript changes
                isPolling = false
                isLocalProcessing = false
                showGeneratingText = false
                return
            }
            
            // Continue polling
            self.scheduleNextPoll()
            return
        }
        
        // Transcript changed - reset stable count
        stableTranscriptCount = 0
        
        // Check if transcript is empty but we have a previous response
        if currentTranscript.isEmpty && !lastRenderedTranscript.isEmpty {
            NSLog("TextModalView: monitorAssistantStream - Early return: currentTranscript empty but lastRenderedTranscript not empty")
            self.scheduleNextPoll()
            return
        }
        
        // Legacy logic - should not be needed anymore
        if !currentTranscript.isEmpty {
            lastRenderedTranscript = currentTranscript
            lastTranscriptLength = currentTranscriptLength
            pollCount = 0 // Reset counter when transcript changes

            if let idx = viewModel.messages.lastIndex(where: { !$0.isUser }),
               idx < viewModel.messages.count {
                SecureLogger.log("TextModalView: Setting message content", sensitiveData: viewModel.llm.transcript)
                // Mutate the last assistant bubble in place (no array replacement)
                viewModel.messages[idx].content = viewModel.llm.transcript
            } else {
                SecureLogger.log("TextModalView: New message content", sensitiveData: viewModel.llm.transcript)
                // Create initial assistant bubble
                let bot = ChatMessage(
                    content: viewModel.llm.transcript,
                    isUser: false,
                    timestamp: Date(),
                    messageType: .text
                )
                viewModel.messages.append(bot)
            }
        } else {
        }

        self.scheduleNextPoll()
    }

    private func scheduleNextPoll() {
        guard isPolling else { return }
        pollCount += 1
        // Poll at a comfortable reading pace (200ms for natural streaming)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            monitorAssistantStream()
        }
    }

    // Voice integration functionality removed

    private func addFollowUpQuestionsIfNeeded() {
        guard isClipboardMessage && !hasAddedFollowUpQuestions else { return }
        
        // Find the last assistant message
        if let lastAssistantIndex = viewModel.messages.lastIndex(where: { !$0.isUser }) {
            let followUpQuestions = [
                "• Rewrite this differently?",
                "• Expand on any points?",
                "• Make this into bullet points?",
                "• Find key themes?"
            ]
            
            let followUpText = "\n\n**Follow-up Questions:**\n\n\(followUpQuestions.joined(separator: "\n"))"
            
            // Append follow-up questions to the existing response
            viewModel.messages[lastAssistantIndex].content += followUpText
            hasAddedFollowUpQuestions = true
            
        }
    }




    // MARK: - File upload helper --------------------------------------------
    private func handleFileUpload(_ url: URL) {
        let fileName = url.lastPathComponent.isEmpty ? NSLocalizedString("Unknown File", comment: "") : url.lastPathComponent
        let fileExtension = url.pathExtension.lowercased()
        
        // Check if file type is supported
        let supportedTypes = ["txt", "md", "rtf", "pdf", "jpg", "jpeg", "png", "heic", "doc", "docx"]
        
        if !supportedTypes.contains(fileExtension) {
            // Add file message to chat
            let fileMessage = ChatMessage(
                content: "📎 \(fileName)",
                isUser: true,
                timestamp: Date(),
                messageType: .file
            )
            viewModel.messages.append(fileMessage)
            
            // Show unsupported file type error message as LLM response
            let errorMessage = ChatMessage(
                content: "❌ I can't process .\(fileExtension) files yet!\n\n📋 Here are the file types I can help you with:\n\n📄 **Documents:**\n• PDF files (.pdf) - up to 25MB\n• Word documents (.doc, .docx) - up to 15MB\n• Text files (.txt, .md, .rtf) - up to 5MB\n\n🖼️ **Images:**\n• Photos (.jpg, .jpeg, .png, .heic) - up to 10MB\n\nPlease try uploading one of these supported file types, and I'll be happy to help analyze it! 😊",
                isUser: false,
                timestamp: Date(),
                messageType: .text
            )
            viewModel.messages.append(errorMessage)
            return
        }
        
        // Add file message to chat
        let fileMessage = ChatMessage(
            content: "📎 \(fileName)",
            isUser: true,
            timestamp: Date(),
            messageType: .file
        )
        viewModel.messages.append(fileMessage)
        
        // Show "File received, what's next?" message
        let assistantMessage = ChatMessage(
            content: "File received, what's next?",
            isUser: false,
            timestamp: Date(),
            messageType: .text
        )
        
        viewModel.messages.append(assistantMessage)
        
        // Store the file URL for later processing when user asks questions
        viewModel.selectedFileUrl = url
        
        // The file content will be processed through the proper LargeFileProcessingService path
        // when the user asks follow-up questions about the file
    }
    
}

// MARK: - Bubble view --------------------------------------------------------

struct MessageBubble: View {
    let message: ChatMessage
    let opacity: Double
    let messageHistory: [ChatMessage]
    let currentIndex: Int
    let isProcessing: Bool
    let isLocalProcessing: Bool
    @State private var isVisible = false
    @EnvironmentObject var colorManager: ColorManager

    var body: some View {
        HStack(spacing: 0) {
            if message.isUser { Spacer() }
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: (message.isUser && !message.content.isEmpty) ? 4 : 0) {
                if message.messageType == .file {
                    FileMessageView(message: message)
                } else if message.messageType == .file {
                    // Voice messages: show with microphone icon and voice indicator
                    HStack(spacing: 8) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(message.isUser ? colorManager.purpleColor : Color(hex: "#00D4FF"))
                        
                        Text(message.content)
                            .font(.custom("IBMPlexMono", size: 14))
                            .foregroundColor(message.isUser ? colorManager.purpleColor : colorManager.whiteTextColor)
                            .multilineTextAlignment(.leading)
                            .textSelection(.enabled)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(message.isUser ? Color(hex: "#2A2A2A") : Color(hex: "#1A1A1A"))
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(message.isUser ? Color.clear : Color(hex: "#00D4FF").opacity(0.3), lineWidth: 1)
                            )
                    }
                } else {
                    if message.isUser {
                        // User messages: dark bubble, purple text with formatting
                        Text(TextFormatter.formatText(message.content))
                            .font(.custom("IBMPlexMono", size: 14))
                            .foregroundColor(colorManager.purpleColor)
                            .multilineTextAlignment(.leading)
                            .textSelection(.enabled)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#2A2A2A"))
                            .cornerRadius(4)
                    } else {
                        // Assistant messages: ZStack for stable transition
                        ZStack(alignment: .topLeading) {
                            // Animation is only rendered when content is empty to prevent layout issues
                            let _ = NSLog("TextModalView: MESSAGE BUBBLE - message.content.isEmpty: \(message.content.isEmpty), content: '\(message.content)'")
                            // MINIMAL FIX: Only show thinking animation when actually needed
                            if message.content.isEmpty && (isProcessing || isLocalProcessing) {
                                ThinkingAnimationView(isVisible: true)
                                    .offset(x: -31, y: -35)
                            }

                            // Actual text content with formatting
                            Text(TextFormatter.formatText(message.content))
                                .font(.custom("IBMPlexMono", size: 16))
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(colorManager.whiteTextColor)
                                .textSelection(.enabled)
                                .padding(.leading, 2)
                        }
                        .animation(.spring(duration: 0.4), value: message.content.isEmpty)
                    }
                }
                // Timestamps removed - now shown in date header instead
            }
            .opacity(isVisible ? opacity : 0)
            .offset(y: isVisible ? 0 : 8)
            .animation(.easeOut(duration: 0.4), value: isVisible)

            if !message.isUser { Spacer() }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isVisible = true }
        }
    }
    
}



// MARK: - Thinking animation -------------------------------------------------

struct ThinkingAnimationView: View {
    let isVisible: Bool
    
    init(isVisible: Bool = true) {
        self.isVisible = isVisible
    }
    
    var body: some View {
        LottieView(name: "thinkingAnimation", loopMode: .loop, isVisible: isVisible)
            .frame(width: 89, height: 89) // 15% smaller
            .allowsHitTesting(false) // Prevent interaction with the animation
    }
}

// MARK: - Blinking Cursor Test -------------------------------------------------

struct BlinkingCursorView: View {
    @State private var isVisible = true
    
    var body: some View {
        Text("...")
            .font(.custom("IBMPlexMono", size: 16))
            .foregroundColor(.white)
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isVisible)
            .onAppear {
                isVisible = true
            }
            .onDisappear {
                isVisible = false
            }
    }
}

// MARK: - Date header --------------------------------------------------------

// MARK: - DateHeaderView removed - duplicate time display eliminated

// MARK: - File bubble --------------------------------------------------------

struct FileMessageView: View {
    let message: ChatMessage
    
    private var fileName: String {
        // Extract filename from message content (removes the 📎 emoji and trims whitespace)
        let content = message.content
        if content.hasPrefix("📎 ") {
            return String(content.dropFirst(2)).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var truncatedFileName: String {
        let name = fileName
        if name.count > 12 {
            return String(name.prefix(12)) + "..."
        }
        return name
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.fill")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color(hex: "#141414"))
                .frame(width: 24, height: 32) // Match height of two lines
            VStack(alignment: .leading, spacing: 2) {
                Text("\(NSLocalizedString("File Upload", comment: "")):")
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#141414"))
                    .lineLimit(1)
                Text(truncatedFileName)
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#141414"))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(ColorManager.shared.greenColor)
        .cornerRadius(4)
    }
}

// MARK: - ARRAY SAFETY --------------------------------------------------

private extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


// ------------ Preview ------------------------------------------------------

#Preview {
    TextModalView(viewModel: MainViewModel(), isPresented: .constant(true), messageHistory: [])
        .preferredColorScheme(.dark)
}


