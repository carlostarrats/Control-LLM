import SwiftUI
import UIKit
import UniformTypeIdentifiers
import Lottie

// MARK: - Lottie View Wrapper -------------------------------------------------

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    
    init(name: String, loopMode: LottieLoopMode = .loop) {
        self.name = name
        self.loopMode = loopMode
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
            print("✅ Lottie: Loaded animation '\(name)' using .named()")
        }
        // Method 2: Try to load from the animations subdirectory
        else if let url = Bundle.main.url(forResource: "16cfa363-2720-425f-bcde-0cf315dd706a", withExtension: "json", subdirectory: "Animations.dataset/animations") {
            print("📁 Lottie: Found JSON file at URL: \(url)")
            // Note: loadedFrom is async, so we can't use it here
            // We'll need to handle this differently
        }
        // Method 3: Try from bundle URL
        else if let url = Bundle.main.url(forResource: name, withExtension: "lottie") {
            print("📁 Lottie: Found .lottie file at URL: \(url)")
        }
        // Method 4: Try from main bundle path
        else if let path = Bundle.main.path(forResource: name, ofType: "lottie") {
            print("📁 Lottie: Found .lottie file at path: \(path)")
        }
        
        if let animation = animation {
            animationView.animation = animation
            animationView.loopMode = loopMode
            animationView.contentMode = .scaleAspectFit
            animationView.play()
            print("✅ Lottie: Animation '\(name)' started playing")
        } else {
            print("❌ Lottie: Could not load animation '\(name)' - falling back to dots")
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
        // No updates needed
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
    
    init(viewModel: MainViewModel, isPresented: Binding<Bool>, messageHistory: [ChatMessage]? = nil) {
        print("🔍 TextModalView init")
        self.viewModel = viewModel
        self._isPresented = isPresented
        self.messageHistory = messageHistory ?? []
    }

    // UI state
    @Binding var isPresented: Bool
    @State private var messageText = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var showingDocumentPicker = false
    @State private var showingModelsSheet = false
    @State private var isSendButtonPressed = false

    @State private var inputBarHeight: CGFloat = 0
    @State private var opacityUpdateTimer: Timer?
    var messageHistory: [ChatMessage]?
    @EnvironmentObject var colorManager: ColorManager
    
    // MARK: - Computed Properties
    private var hasModelsInstalled: Bool {
        !ModelManager.shared.availableModels.isEmpty
    }


    // MARK: body -------------------------------------------------------------
    var body: some View {
        ZStack(alignment: .bottom) {
            // Full background gradient
            LinearGradient(
                colors: [Color(hex: "#1D1D1D"), Color(hex: "#141414")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                messageList
            }

            inputBar
            
        }
        .onAppear {
            setupOpacityUpdateTimer()
            
            // Reset clipboard message state when view appears
            isClipboardMessage = false
            hasAddedFollowUpQuestions = false
            
            // Also reset the ChatViewModel's duplicate detection to ensure clean state
            viewModel.llm.lastSentMessage = nil
            
            print("🔍 TextModalView: onAppear - Reset clipboard state and duplicate detection")
            
            // CRITICAL FIX: Removed clipboard message observer setup - consolidated into single message flow
        }
        .onDisappear {
            opacityUpdateTimer?.invalidate()
            opacityUpdateTimer = nil
            
            // Dismiss keyboard when view disappears
            isTextFieldFocused = false
            hideKeyboard()
            
            // CRITICAL FIX: Removed clipboard message observer cleanup - consolidated into single message flow
        }
                        .onReceive(NotificationCenter.default.publisher(for: .modelDidChange)) { _ in
            print("🔍 TextModalView: Model changed notification received")
            
            // IMPORTANT: Preserve the user's follow-up question if it exists
            let lastUserMessage = viewModel.messages.last { $0.isUser }
            let hasFollowUpQuestion = lastUserMessage != nil && !lastUserMessage!.content.hasPrefix("Analyze this text")
            
            // CRITICAL FIX: Don't sync UI messages to ChatViewModel - this causes context loss
            print("🔍 TextModalView: Model change - preserving ChatViewModel history")
            
            // Reset all streaming state for new model
            isPolling = false
            pollCount = 0
            lastRenderedTranscript = ""
            lastTranscriptLength = 0
            lastSentMessage = ""
            isDuplicateMessage = false
            stableTranscriptCount = 0
            hasProvidedCompletionHaptic = false
            
            // CRITICAL FIX: Also reset local UI state to match ChatViewModel
            // This ensures the UI is properly synchronized after model changes
            if !viewModel.llm.isProcessing {
                // If ChatViewModel is not processing, ensure our local state matches
                // This prevents the UI from thinking it's in a processing state when it's not
                print("🔍 TextModalView: ChatViewModel isProcessing is false, ensuring UI state matches")
            }
            
            // Reset clipboard message state
            isClipboardMessage = false
            hasAddedFollowUpQuestions = false
            
            // CRITICAL FIX: Don't clear empty thinking messages during model change
            // This can interfere with UI state and cause the thinking animation to not show
            // viewModel.messages.removeAll { message in
            //     !message.isUser && message.content.isEmpty
            // }
            
            // IMPORTANT: Also reset the ChatViewModel's duplicate detection
            viewModel.llm.lastSentMessage = nil
            
            // CRITICAL FIX: Don't sync UI messages - preserve ChatViewModel history
            print("🔍 TextModalView: Model change complete - preserving context")
            
            // If there was a follow-up question, we need to re-send it to the new model
            if hasFollowUpQuestion {
                print("🔍 TextModalView: Preserving follow-up question for new model: '\(lastUserMessage!.content.prefix(100))...'")
                // The question will be automatically re-sent by the ChatViewModel
            }
            
            print("🔍 TextModalView: ALL streaming state reset completed for new model")
        }
        .onReceive(NotificationCenter.default.publisher(for: .dismissKeyboard)) { _ in
            // Dismiss keyboard and reset focus when navigating away from chat
            isTextFieldFocused = false
            hideKeyboard()
        }
        .sheet(isPresented: $showingModelsSheet) {
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
                print("🔍 TextModalView: Processing pending clipboard prompt: \(prompt.prefix(50))...")
                
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


    }
    


    // MARK: - Opacity Update Timer -------------------------------------------
    
    private func setupOpacityUpdateTimer() {
        // Update opacity every minute to create smooth fade effect
        opacityUpdateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            // Trigger a UI update to recalculate opacity values
            // This will cause the view to refresh with new opacity values
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
    
    // MARK: header -----------------------------------------------------------
    private var header: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(hex: "#666666"))
                .frame(width: 36, height: 5)
                .padding(.top, 8).padding(.bottom, 20)

            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(colorManager.whiteTextColor)
                    Text(NSLocalizedString("Control", comment: ""))
                        .font(.custom("IBMPlexMono", size: 20))
                        .foregroundColor(colorManager.whiteTextColor)
                }
                .padding(.leading, 20)

                Spacer()

                Button { isPresented = false } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(colorManager.whiteTextColor)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 20)
            }

            Spacer().frame(height: 18)
        }
    }

    // MARK: message list -----------------------------------------------------
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 24) {
                    if !hasModelsInstalled {
                        noModelMessage
                    } else {
                        normalMessageList
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 120)
            }
            .onChange(of: viewModel.messages) { _, newMessages in
                if let last = newMessages.last, !last.content.isEmpty {
                    withAnimation(.spring()) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: viewModel.llm.transcript) { oldTranscript, newTranscript in
                // CRITICAL FIX: Actually update the message content when transcript changes
                if !newTranscript.isEmpty && newTranscript != oldTranscript {
                    if let lastAssistantIndex = viewModel.messages.lastIndex(where: { !$0.isUser }) {
                        // Update the message content with the new transcript
                        viewModel.messages[lastAssistantIndex].content = newTranscript
                        
                        // Scroll to the updated message
                        let lastAssistant = viewModel.messages[lastAssistantIndex]
                        withAnimation(.spring()) {
                            proxy.scrollTo(lastAssistant.id, anchor: .bottom)
                        }
                    }
                }
            }
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
        }
    }
    
    // MARK: - Normal Message List
    private var normalMessageList: some View {
        ForEach(Array(getMessagesGroupedByDate().enumerated()), id: \.element.0) { index, dateAndMessages in
            let (date, messages) = dateAndMessages
            VStack(spacing: 24) {
                DateHeaderView(
                    firstMessageTime: messages.first?.timestamp ?? date,
                    isFirstMessageInConversation: index == 0
                )
                
                ForEach(messages) { message in
                    MessageBubble(
                        message: message,
                        opacity: calculateMessageOpacity(for: message)
                    )
                    .id(message.id)
                }
            }
        }
    }

    // MARK: input bar --------------------------------------------------------
    private var inputBar: some View {
        VStack {
            HStack(alignment: .bottom, spacing: 12) {
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
                            print("File import failed: \(error.localizedDescription)")
                        }
                    }
                }
                .frame(width: 44, height: 44)

                // Text field
                TextField("", text: $messageText, axis: .vertical)
                    .font(.custom("IBMPlexMono", size: 16))
                    .foregroundColor(colorManager.purpleColor)
                    .padding(.leading, 16)
                    .padding(.trailing, trailingPadding)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#2A2A2A"))
                    .cornerRadius(4)
                    .tint(colorManager.whiteTextColor)
                    .focused($isTextFieldFocused) // Explicitly bind focus state
                    .disabled(viewModel.llm.isProcessing || !hasModelsInstalled) // Disable during LLM response or when no models
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
                    .overlay(sendButtonOverlay, alignment: .bottomTrailing) // Anchor to bottom-right
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
        if messageText.isEmpty {
            HStack {
                Group { // Group to apply a single transition
                    if !hasModelsInstalled {
                        Text(NSLocalizedString("Download model to chat...", comment: ""))
                    } else if viewModel.llm.isProcessing || isLocalProcessing { // Also check local state
                        Text(NSLocalizedString("Generating response...", comment: ""))
                    } else {
                        Text(NSLocalizedString("Ask Anything…", comment: ""))
                    }
                }
                .font(.custom("IBMPlexMono", size: 16))
                .foregroundColor(Color(hex: "#666666"))
                .transition(.identity) // Use .identity for instant change to sync with button

                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }

    // send button overlay
    @ViewBuilder private var sendButtonOverlay: some View {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        if (!trimmedText.isEmpty || viewModel.llm.isProcessing || isLocalProcessing) && hasModelsInstalled {
            Group {
                if viewModel.llm.isProcessing || isLocalProcessing {
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
                isSendButtonPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isSendButtonPressed = false
                }

                if viewModel.llm.isProcessing {
                    // Stop button pressed - cancel ongoing generation
                    print("Stop button pressed!")
                    NSLog("Stop button pressed!")
                    viewModel.llm.stopGeneration()
                } else {
                    // Send button pressed - send new message
                    print("Send button pressed!")
                    NSLog("Send button pressed!")
                    
                    // Immediately change button state and dismiss keyboard for instant UI response
                    print("🔍 Setting isLocalProcessing = true for immediate button change")
                    isLocalProcessing = true
                    isTextFieldFocused = false
                    
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
                    }
                }
            }
            .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            .padding(.trailing, 8)
            .padding(.bottom, 6) // keep anchored but visually centered for single-line height
        }
    }

    // MARK: - BUTTON ACTION --------------------------------------------------
    private func sendMessage() async {
        // Prevent sending if already processing or no models available
        guard !viewModel.llm.isProcessing else {
            print("🔍 TextModalView: sendMessage called but LLM is already processing")
            return
        }
        
        guard hasModelsInstalled else {
            print("🔍 TextModalView: sendMessage called but no models are installed")
            return
        }
        
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { 
            print("🔍 TextModalView: sendMessage called but text is empty")
            return 
        }

        // Play sound for sending a message
        FeedbackService.shared.playSound(.messageSent)

        // Donate user's action to Shortcuts
        ShortcutsIntegrationHelper.shared.donateMessageSent(message: text)

        print("🔍 TextModalView: sendMessage called with text: '\(text)'")
        NSLog("🔍 TextModalView: sendMessage called with text: '\(text)'")

        // Stop any existing polling before starting new message
        isPolling = false
        pollCount = 0
        
        // Check if this is the same message as last time
        // Special handling for clipboard messages - they should never be considered duplicates
        let isClipboardMessageFormat = text.hasPrefix(NSLocalizedString("Analyze this text (keep under 8000 tokens):", comment: ""))
        
        if isClipboardMessageFormat {
            // Clipboard messages are never duplicates - they always have different content
            isDuplicateMessage = false
            print("🔍 TextModalView: Clipboard message detected, bypassing duplicate check")
        } else {
            // Normal duplicate detection for regular messages
            isDuplicateMessage = text == lastSentMessage
            print("🔍 TextModalView: isDuplicateMessage: \(isDuplicateMessage)")
        }
        
        lastSentMessage = text
        
        // Allow re-sending if this is a duplicate but we're in a new context (e.g., after model switch)
        // Check if the transcript has changed or if we're in a new model context
        let isNewContext = viewModel.llm.transcript.isEmpty || 
                          viewModel.llm.lastLoadedModel != lastLoadedModelForDuplicateCheck
        lastLoadedModelForDuplicateCheck = viewModel.llm.lastLoadedModel
        
        if isDuplicateMessage && isNewContext {
            print("🔍 TextModalView: Duplicate message detected, but allowing re-send in new context")
            isDuplicateMessage = false
        } else if isDuplicateMessage {
            print("🔍 TextModalView: Duplicate message detected, ignoring")
            return
        }
        
        // Clear any existing thinking messages (empty assistant messages)
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

        print("🔍 TextModalView: Sending message through MainViewModel")
        
        // CRITICAL FIX: Send through MainViewModel which handles user message creation and LLM sending
        await MainActor.run {
            viewModel.sendTextMessage(text)
        }

        // Reset clipboard message state for normal chat messages
        isClipboardMessage = false
        hasAddedFollowUpQuestions = false

        print("🔍 TextModalView: About to create placeholder message")
        // 2) placeholder assistant bubble (0.3s delay to prevent motion and allow thinking animation)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let placeholder = ChatMessage(
                content: "",
                isUser: false,
                timestamp: Date(),
                messageType: .text
            )
            viewModel.messages.append(placeholder)
            print("🔍 TextModalView: Added empty placeholder message (0.3s delay)")
            
            // CRITICAL FIX: Don't sync UI messages - let ChatViewModel handle its own context
            print("🔍 TextModalView: Placeholder added, starting polling")
        }
        
        print("🔍 TextModalView: About to clear messageText")
        // 3) clear field + ask model (keyboard already dismissed)
        DispatchQueue.main.async {
            self.messageText = ""
        }
        print("🔍 TextModalView: LLM call already made through ChatViewModel, no duplicate call needed")
        // Note: viewModel.llm.send(text) is already called by ChatViewModel.sendTextMessage
        // No need to duplicate the LLM call here
        
        print("🔍 TextModalView: About to start polling")
        // 4) start polling the stream immediately for real-time word streaming
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("🔍 TextModalView: Starting monitorAssistantStream")
            isPolling = true
            pollCount = 0
            monitorAssistantStream()
        }
        
        print("🔍 TextModalView: sendMessage completed successfully")
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
    // MARK: - STREAM POLLER --------------------------------------------------
    @State private var lastRenderedTranscript = ""
    @State private var isPolling = false
    @State private var pollCount = 0
    @State private var isLocalProcessing = false // Local state for immediate button changes
    @State private var lastTranscriptLength = 0
    @State private var lastSentMessage = ""
    @State private var isDuplicateMessage = false
    @State private var lastLoadedModelForDuplicateCheck: String? = nil
    
    // Clipboard message tracking for follow-up questions
    @State private var isClipboardMessage = false
    @State private var hasAddedFollowUpQuestions = false
    
    // Response completion tracking for haptic feedback
    @State private var stableTranscriptCount = 0
    @State private var hasProvidedCompletionHaptic = false
    
    // MARK: - Error Handling State
    @State private var errorMessage: String?
    @State private var showingError = false
    
    // Voice integration state
    // Voice functionality removed

    private let maxPollCount = 300 // 30 seconds max (300 * 0.1s)

    private func monitorAssistantStream() {
        guard isPolling else { return }
        
        // Check if file processing failed - stop polling immediately
        if let fileError = viewModel.fileProcessingError {
            print("🔍 TextModalView: File processing failed with error: \(fileError), stopping polling")
            isPolling = false
            isLocalProcessing = false
            
            // Find and update the placeholder message to show the error
            if let placeholderIndex = viewModel.messages.firstIndex(where: { !$0.isUser && $0.content.isEmpty }) {
                viewModel.messages[placeholderIndex].content = "❌ \(fileError)"
            }
            
            return
        }
        
        // Check if file processing is still in progress - if not, stop polling
        if viewModel.isFileProcessing == false && viewModel.selectedFileUrl != nil {
            print("🔍 TextModalView: File processing completed, stopping polling")
            isPolling = false
            isLocalProcessing = false
            return
        }
        
        let currentTranscriptLength = viewModel.llm.transcript.count
        let currentTranscript = viewModel.llm.transcript
        
        print("🔍 TextModalView: Polling transcript - length: \(currentTranscriptLength), content: '\(currentTranscript)'")
        
        // Check if we should stop polling - give clipboard messages more time for analysis
        let maxPolls = isClipboardMessage ? 300 : 150  // 30 seconds for clipboard, 15 seconds for regular messages
        if pollCount > maxPolls {
            print("🔍 TextModalView: Max polls (\(maxPolls)) reached, stopping")
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
                print("🔍 TextModalView: WARNING - Possible streaming loop detected after \(stableTranscriptCount) stable polls")
                print("🔍 TextModalView: Stopping polling to prevent infinite loop")
                isPolling = false
                isLocalProcessing = false // Reset local processing state
                
                // Add follow-up questions for clipboard messages if not already added
                addFollowUpQuestionsIfNeeded()
                return
            }
            
            // Check if transcript has been stable for 3 consecutive polls (600ms)
            // This indicates the response is likely complete
            if stableTranscriptCount >= 3 && !hasProvidedCompletionHaptic && !currentTranscript.isEmpty {
                print("🔍 TextModalView: Response appears complete, providing haptic feedback")
                hasProvidedCompletionHaptic = true
                
                // Add follow-up questions for clipboard messages if not already added
                addFollowUpQuestionsIfNeeded()
                
                // Stop polling when response is complete
                isPolling = false
                isLocalProcessing = false // Reset local processing state
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
            print("🔍 TextModalView: Transcript is empty but we have previous content, continuing to poll")
            self.scheduleNextPoll()
            return
        }
        
        print("🔍 TextModalView: Transcript changed! Updating UI...")
        print("🔍 TextModalView: Previous transcript: '\(lastRenderedTranscript)'")
        print("🔍 TextModalView: New transcript: '\(viewModel.llm.transcript)'")
        
        // Only update if we have actual content
        if !currentTranscript.isEmpty {
            lastRenderedTranscript = currentTranscript
            lastTranscriptLength = currentTranscriptLength
            pollCount = 0 // Reset counter when transcript changes

            if let idx = viewModel.messages.lastIndex(where: { !$0.isUser }),
               idx < viewModel.messages.count {
                print("🔍 TextModalView: Updating existing assistant message at index \(idx)")
                print("🔍 TextModalView: Setting message content to: '\(viewModel.llm.transcript)'")
                // Mutate the last assistant bubble in place (no array replacement)
                viewModel.messages[idx].content = viewModel.llm.transcript
                print("🔍 TextModalView: Message updated successfully")
            } else {
                print("🔍 TextModalView: Creating new assistant message")
                print("🔍 TextModalView: New message content: '\(viewModel.llm.transcript)'")
                // Create initial assistant bubble
                let bot = ChatMessage(
                    content: viewModel.llm.transcript,
                    isUser: false,
                    timestamp: Date(),
                    messageType: .text
                )
                viewModel.messages.append(bot)
                print("🔍 TextModalView: New message created and added")
            }
        } else {
            print("🔍 TextModalView: Transcript is empty, continuing to poll for content")
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
            
            print("🔍 TextModalView: Added follow-up questions to clipboard message")
        }
    }


    // MARK: - File upload helper --------------------------------------------
    private func handleFileUpload(_ url: URL) {
        let fileName = url.lastPathComponent.isEmpty ? NSLocalizedString("Unknown File", comment: "") : url.lastPathComponent
        
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
                        // User messages: dark bubble, purple text
                        Text(message.content)
                            .font(.custom("IBMPlexMono", size: 14))
                            .foregroundColor(colorManager.purpleColor)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#2A2A2A"))
                            .cornerRadius(4)
                    } else {
                        // Assistant messages: ZStack for stable transition
                        ZStack(alignment: .topLeading) {
                            // Animation is only rendered when content is empty to prevent layout issues
                            if message.content.isEmpty {
                                ThinkingAnimationView()
                                    .offset(x: -31, y: -35) // Restore original positioning
                            }

                            // Actual text content
                            Text(message.content)
                                .font(.custom("IBMPlexMono", size: 16))
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(colorManager.whiteTextColor)
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
    var body: some View {
        LottieView(name: "thinkingAnimation", loopMode: .loop)
            .frame(width: 89, height: 89) // 15% smaller
            .allowsHitTesting(false) // Prevent interaction with the animation
    }
}

// MARK: - Date header --------------------------------------------------------

struct DateHeaderView: View {
    let firstMessageTime: Date
    let isFirstMessageInConversation: Bool
    @State private var isVisible = false
    
    var body: some View {
        HStack {
            Spacer()
            Text(formattedDateAndTime())
                .font(.custom("IBMPlexMono", size: 12))
                .foregroundColor(ColorManager.shared.orangeColor)
            Spacer()
        }
        .padding(.top, 20).padding(.bottom, 10)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 4)
        .animation(.easeOut(duration: 0.3), value: isVisible)
        .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { isVisible = true } }
    }
    
    private func formattedDateAndTime() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        let timeText = formatter.string(from: firstMessageTime)
        
        if isFirstMessageInConversation {
            // For first message, show only time
            return timeText
        } else {
            // For subsequent messages, show date and time
            let dateText = Self.smart(firstMessageTime)
            return "\(dateText) \(timeText)"
        }
    }
    
    // smart-date formatter
    private static func smart(_ date: Date) -> String {
        let cal = Calendar.current
        let now = Date()
        if cal.isDate(date, inSameDayAs: now) { return NSLocalizedString("TODAY", comment: "") }
        if cal.isDate(date, inSameDayAs: cal.date(byAdding: .day, value: -1, to: now)!) { return NSLocalizedString("YESTERDAY", comment: "") }

        let weekAgo = cal.date(byAdding: .day, value: -7, to: now)!
        let fmt = DateFormatter()
        fmt.locale = Locale.current
        fmt.timeZone = TimeZone.current
        if date > weekAgo { fmt.dateFormat = "EEEE, MMM d" } else { fmt.dateFormat = "MMM d, yyyy" }
        return fmt.string(from: date).uppercased()
    }
}

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


