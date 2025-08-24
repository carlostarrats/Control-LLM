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
        .sheet(isPresented: $showingModelsSheet) {
            SettingsModelsView()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { 
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
        let calendar = Calendar.current
        let now = Date()
        let daysDifference = calendar.dateComponents([.day], from: message.timestamp, to: now).day ?? 0
        
        // Apply opacity fade based on message age
        switch daysDifference {
        case 0: return 1.0      // Today: 100% opacity
        case 1: return 0.9      // Yesterday: 90% opacity
        case 2: return 0.8      // Day 2: 80% opacity
        case 3: return 0.7      // Day 3: 70% opacity
        case 4: return 0.6      // Day 4: 60% opacity
        case 5: return 0.5      // Day 5: 50% opacity
        case 6: return 0.4      // Day 6: 40% opacity
        default: return 0.0     // Day 7+: 0% opacity (will be deleted)
        }
    }
    
    private func getMessagesGroupedByDate() -> [(Date, [ChatMessage])] {
        let messages = viewModel.messages
        guard !messages.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let now = Date()
        let cutoffDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        // Filter out messages older than 7 days
        let recentMessages = messages.filter { message in
            message.timestamp > cutoffDate
        }
        
        let grouped = Dictionary(grouping: recentMessages) { message in
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
                    Text("Control")
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
                if oldTranscript.isEmpty && !newTranscript.isEmpty {
                    if let lastAssistantIndex = viewModel.messages.lastIndex(where: { !$0.isUser }) {
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
            
            Text("Nothing to see here (yet) 🤖")
                .font(.custom("IBMPlexMono", size: 16))
                .foregroundColor(Color(hex: "#666666"))
                .multilineTextAlignment(.center)
            
                                        Button(action: {
                                showingModelsSheet = true
                            }) {
                                Text("Download Model")
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
        ForEach(getMessagesGroupedByDate(), id: \.0) { date, messages in
            VStack(spacing: 24) {
                DateHeaderView(firstMessageTime: date)
                
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
                    Color(hex: "#141414")
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
                if !hasModelsInstalled {
                    Text("Download model to chat...")
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(Color(hex: "#666666"))
                } else if viewModel.llm.isProcessing {
                    Text("Generating response...")
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(Color(hex: "#666666"))
                } else {
                    Text("Ask Anything…")
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(Color(hex: "#666666"))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }

    // send button overlay
    @ViewBuilder private var sendButtonOverlay: some View {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        if (!trimmedText.isEmpty || viewModel.llm.isProcessing) && hasModelsInstalled {
            Button(action: {
                if viewModel.llm.isProcessing {
                    // Stop button pressed - cancel ongoing generation
                    print("Stop button pressed!")
                    NSLog("Stop button pressed!")
                    viewModel.llm.stopGeneration()
                } else {
                    // Send button pressed - send new message
                    print("Send button pressed!")
                    NSLog("Send button pressed!")
                    Task {
                        await sendMessage()
                    }
                }
            }) {
                if viewModel.llm.isProcessing {
                    // Stop button (square icon)
                    Text("■")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#1D1D1D"))
                        .frame(width: 32, height: 32)
                        .background(colorManager.redColor)
                        .cornerRadius(4)
                } else {
                    // Send button (arrow icon)
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#1D1D1D"))
                        .frame(width: 32, height: 32)
                        .background(colorManager.purpleColor)
                        .cornerRadius(4)
                }
            }
            .buttonStyle(.plain)
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
        let isClipboardMessageFormat = text.hasPrefix("Analyze this text (keep under 8000 tokens):")
        
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
        // 3) clear field + ask model
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
                return "Your message is too long. Please shorten it and try again."
            case 11: // Another model operation in progress
                return "Another model operation is in progress. Please wait and try again."
            case 12: // Model name not available
                return "Model not available. Please check your model settings."
            case 17: // Invalid context pointer
                return "Model error. Please try restarting the app."
            case 18: // Empty prompt
                return "Empty message. Please type something and try again."
            case 19: // Invalid strings
                return "Message format error. Please try again."
            case 20: // Streaming timeout
                return "Response took too long. Please try a shorter message."
            case 27: // Token limit reached
                return "Response was cut off due to length. Try asking a more specific question."
            default:
                return "LLM Error: \(nsError.localizedDescription)"
            }
        case "ChatViewModel":
            switch nsError.code {
            case 1: // No model selected
                return "No model selected. Please choose a model in Settings."
            case 2: // Model loading failed
                return "Failed to load model. Please try again or select a different model."
            default:
                return "Chat Error: \(nsError.localizedDescription)"
            }
        default:
            return "Error: \(error.localizedDescription)"
        }
    }
    

    
    // MARK: - STREAM POLLER --------------------------------------------------
    // MARK: - STREAM POLLER --------------------------------------------------
    @State private var lastRenderedTranscript = ""
    @State private var isPolling = false
    @State private var pollCount = 0
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
            errorMessage = "Response took too long. Please try a shorter message or check your model settings."
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
            if stableTranscriptCount >= 5 && !currentTranscript.isEmpty {
                print("🔍 TextModalView: WARNING - Possible streaming loop detected after \(stableTranscriptCount) stable polls")
                print("🔍 TextModalView: Stopping polling to prevent infinite loop")
                isPolling = false
                FeedbackService.shared.playHaptic(.light)
                
                // Add follow-up questions for clipboard messages if not already added
                addFollowUpQuestionsIfNeeded()
                return
            }
            
            // Check if transcript has been stable for 3 consecutive polls (600ms)
            // This indicates the response is likely complete
            if stableTranscriptCount >= 3 && !hasProvidedCompletionHaptic && !currentTranscript.isEmpty {
                print("🔍 TextModalView: Response appears complete, providing haptic feedback")
                FeedbackService.shared.playHaptic(.light)
                hasProvidedCompletionHaptic = true
                
                // Add follow-up questions for clipboard messages if not already added
                addFollowUpQuestionsIfNeeded()
                
                // Stop polling when response is complete
                isPolling = false
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
        let fileName = url.lastPathComponent.isEmpty ? "Unknown File" : url.lastPathComponent
        
        // Add file message to chat
        let fileMessage = ChatMessage(
            content: "📎 \(fileName)",
            isUser: true,
            timestamp: Date(),
            messageType: .file
        )
        viewModel.messages.append(fileMessage)
        
        // Process file and send to LLM
        Task {
            do {
                let fileContent = try await FileProcessingService.shared.processFile(url)
                let formattedContent = FileProcessingService.shared.formatForLLM(fileContent)
                
                // Add assistant message with file analysis
                let assistantMessage = ChatMessage(
                    content: "I've processed your file. Here's what I found:\n\n\(formattedContent)\n\nWhat would you like me to do with this content?",
                    isUser: false,
                    timestamp: Date(),
                    messageType: .text
                )
                
                await MainActor.run {
                    viewModel.messages.append(assistantMessage)
                }
                
                // Send the file content to LLM for processing
                // Use the proper streaming path through ChatViewModel
                try? await viewModel.llm.send("Please analyze this file content and provide a summary: \(formattedContent)")
                
                // Start monitoring the stream
                await MainActor.run {
                    monitorAssistantStream()
                }
                
            } catch {
                let errorMessage = ChatMessage(
                    content: "❌ Error processing file: \(error.localizedDescription)",
                    isUser: false,
                    timestamp: Date(),
                    messageType: .text
                )
                
                await MainActor.run {
                    viewModel.messages.append(errorMessage)
                }
            }
        }
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
        let dateText = Self.smart(firstMessageTime)
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "hh:mm a"
        let timeText = formatter.string(from: firstMessageTime)
        return "\(dateText) \(timeText)"
    }
    
    // smart-date formatter
    private static func smart(_ date: Date) -> String {
        let cal = Calendar.current
        let now = Date()
        if cal.isDate(date, inSameDayAs: now) { return "TODAY" }
        if cal.isDate(date, inSameDayAs: cal.date(byAdding: .day, value: -1, to: now)!) { return "YESTERDAY" }

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
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "doc.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(message.isUser ? .black : ColorManager.shared.whiteTextColor)
            VStack(alignment: .leading, spacing: 2) {
                Text("File Message")
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(message.isUser ? .black : ColorManager.shared.whiteTextColor)
                    .lineLimit(1)
                // File extension display removed
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(message.isUser ? ColorManager.shared.whiteTextColor : Color(hex: "#2A2A2A"))
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


