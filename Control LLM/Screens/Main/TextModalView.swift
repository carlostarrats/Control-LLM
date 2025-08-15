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
    @State private var selectedDetent: PresentationDetent = .large
    @FocusState private var isTextFieldFocused: Bool
    @State private var showingDocumentPicker = false
    @State private var showDateHeader = false
    var messageHistory: [ChatMessage]?
    @EnvironmentObject var colorManager: ColorManager

    // MARK: body -------------------------------------------------------------
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#1D1D1D"), Color(hex: "#141414")],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                messageList
                inputBar
            }
        }
        .presentationDetents([.height(100), .medium, .large], selection: $selectedDetent)
        .presentationDragIndicator(.hidden)
        .onAppear {
            checkIfShouldShowDateHeader()
            if let history = messageHistory {
                viewModel.llm.messageHistory = history
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("modelDidChange"))) { _ in
            print("🔍 TextModalView: Model change notification received, resetting state...")
            // Reset only internal polling state when model changes
            isPolling = false
            pollCount = 0
            lastTranscriptLength = 0
            lastSentMessage = ""
            isDuplicateMessage = false
            
            // IMPORTANT: Don't clear lastRenderedTranscript here - this preserves the displayed content
            // The transcript will be updated when the new model responds
            
            // Clear any empty thinking messages (placeholder messages)
            viewModel.messages.removeAll { message in
                !message.isUser && message.content.isEmpty
            }
            
            print("🔍 TextModalView: State reset completed - displayed messages preserved")
        }
    }
    
    // MARK: - Date header logic ----------------------------------------------
    private func checkIfShouldShowDateHeader() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: Date())
        
        // Get the last date when header was shown
        let lastShownDate = UserDefaults.standard.string(forKey: "lastDateHeaderShown")
        
        print("🗓️ Date header check:")
        print("  Today: \(todayString)")
        print("  Last shown: \(lastShownDate ?? "nil")")
        print("  Messages count: \(viewModel.messages.count)")
        
        // Show header if there are messages AND we haven't shown it today
        if !viewModel.messages.isEmpty {
            if lastShownDate != todayString {
                UserDefaults.standard.set(todayString, forKey: "lastDateHeaderShown")
                showDateHeader = true
            } else {
                // Still show if we have messages, even if we've shown it today
                showDateHeader = true
            }
        } else {
            showDateHeader = false
        }
        
        print("  Will show header: \(showDateHeader)")
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
                        .foregroundColor(Color(hex: "#BBBBBB"))
                    Text("Control")
                        .font(.custom("IBMPlexMono", size: 20))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                }
                .padding(.leading, 20)

                Spacer()

                Button { isPresented = false } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 20)
            }

            Spacer().frame(height: 18)
        }
        .background(Color(hex: "#1D1D1D"))
    }

    // MARK: message list -----------------------------------------------------
    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                 LazyVStack(spacing: 24) {
                    if !viewModel.messages.isEmpty && showDateHeader { 
                        DateHeaderView(firstMessageTime: viewModel.messages.first?.timestamp) 
                    }
                     ForEach(viewModel.messages) { MessageBubble(message: $0).id($0.id) }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .safeAreaPadding(.bottom, 70)
            .onChange(of: viewModel.messages) { _, _ in
                // Update date header when messages change
                checkIfShouldShowDateHeader()
                
                if let last = viewModel.messages.last {
                    withAnimation(.spring()) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: input bar --------------------------------------------------------
    private var inputBar: some View {
        VStack {
            HStack(alignment: .bottom, spacing: 12) {
                // Plus button
                Button(action: {
                    showingDocumentPicker = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(colorManager.greenColor)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
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

                // Text field
                TextField("Type your message...", text: $messageText, axis: .vertical)
                    .font(.custom("IBMPlexMono", size: 16))
                    .foregroundColor(colorManager.purpleColor)
                    .padding(.leading, 16)
                    .padding(.trailing, trailingPadding)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#2A2A2A"))
                    .cornerRadius(4)
                    .tint(Color(hex: "#EEEEEE"))
                    .onChange(of: messageText) { _, _ in
                        FeedbackService.shared.playSound(.keyPress)
                    }
                    .onTapGesture {
                        isTextFieldFocused = true
                    }
                    .overlay(placeholderOverlay.allowsHitTesting(false), alignment: .leading) // Fix placeholder tap issue
                    .overlay(sendButtonOverlay, alignment: .bottomTrailing) // Anchor to bottom-right
                    .animation(.easeInOut(duration: 0.05), value: isTextFieldFocused)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(hex: "#222222"))
    }

    // trailing padding changes when send-button visible
    private var trailingPadding: CGFloat {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedText.isEmpty ? 16 : 50
    }

    // placeholder
    @ViewBuilder private var placeholderOverlay: some View {
        if messageText.isEmpty {
            HStack {
                Text("Ask Anything…")
                    .font(.custom("IBMPlexMono", size: 16))
                    .foregroundColor(Color(hex: "#666666"))
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }

    // send button overlay
    @ViewBuilder private var sendButtonOverlay: some View {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            Button(action: {
                print("Send button pressed!")
                NSLog("Send button pressed!")
                Task {
                    await sendMessage()
                }
            }) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#1D1D1D"))
                    .frame(width: 32, height: 32)
                    .background(colorManager.purpleColor)
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
            .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            .padding(.trailing, 8)
            .padding(.bottom, 6) // keep anchored but visually centered for single-line height
        }
    }

    // MARK: - BUTTON ACTION --------------------------------------------------
    private func sendMessage() async {
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
        isDuplicateMessage = text == lastSentMessage
        lastSentMessage = text
        
        print("🔍 TextModalView: isDuplicateMessage: \(isDuplicateMessage)")
        
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

        print("🔍 TextModalView: About to call viewModel.sendTextMessage")
        // 1) user bubble
        viewModel.sendTextMessage(text)

        print("🔍 TextModalView: About to create placeholder message")
        // 2) placeholder assistant bubble (slight delay so it appears after user bubble)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let placeholder = ChatMessage(
                content: "",
                isUser: false,
                timestamp: Date(),
                messageType: .text
            )
            viewModel.messages.append(placeholder)
            print("🔍 TextModalView: Added empty placeholder message (delayed)")
        }

        print("🔍 TextModalView: About to clear messageText")
        // 3) clear field + ask model
        DispatchQueue.main.async {
            self.messageText = ""
        }
        print("🔍 TextModalView: About to call viewModel.llm.send with history count: \(viewModel.llm.messageHistory?.count ?? 0)")
        try? await viewModel.llm.send(text)
        
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

    // MARK: - STREAM POLLER --------------------------------------------------
    // MARK: - STREAM POLLER --------------------------------------------------
    @State private var lastRenderedTranscript = ""
    @State private var isPolling = false
    @State private var pollCount = 0
    @State private var lastTranscriptLength = 0
    @State private var lastSentMessage = ""
    @State private var isDuplicateMessage = false
    @State private var lastLoadedModelForDuplicateCheck: String? = nil

    private let maxPollCount = 300 // 30 seconds max (300 * 0.1s)

    private func monitorAssistantStream() {
        guard isPolling else { return }
        
        let currentTranscriptLength = viewModel.llm.transcript.count
        let currentTranscript = viewModel.llm.transcript
        
        print("🔍 TextModalView: Polling transcript - length: \(currentTranscriptLength), content: '\(currentTranscript)'")
        
        // Check if we should stop polling
        if pollCount > 50 { // Increased patience for first response
            print("🔍 TextModalView: Max polls reached, stopping")
            isPolling = false
            FeedbackService.shared.playHaptic(.light)
            return
        }
        
        // Check if transcript has changed
        if currentTranscriptLength == lastTranscriptLength && currentTranscript == lastRenderedTranscript {
            // No change - continue polling
            self.scheduleNextPoll()
            return
        }
        
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
                // Auto-save after first full exchange
                viewModel.autoSaveIfNeeded()
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
                // Auto-save after first full exchange
                viewModel.autoSaveIfNeeded()
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


    // MARK: - File upload helper --------------------------------------------
    private func handleFileUpload(_ url: URL) {
        let fileName = url.lastPathComponent.isEmpty ? "Unknown File" : url.lastPathComponent
        
        // Add file message to chat
        let fileMessage = ChatMessage(
            content: "📎 \(fileName)",
            isUser: true,
            timestamp: Date(),
            messageType: .file,
            fileName: fileName,
            fileURL: url
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
    @State private var isVisible = false
    @EnvironmentObject var colorManager: ColorManager

    var body: some View {
        HStack(spacing: 0) {
            if message.isUser { Spacer() }
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: (message.isUser && !message.content.isEmpty) ? 4 : 0) {
                if message.messageType == .file {
                    FileMessageView(message: message)
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
                            // Animation is always in the layout to reserve space, but hidden when there's text
                            ThinkingAnimationView()
                                .offset(x: -31, y: -35)
                                .opacity(message.content.isEmpty ? 1 : 0)

                            // Actual text content
                            Text(message.content)
                                .font(.custom("IBMPlexMono", size: 16))
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(Color(hex: "#EEEEEE"))
                                .padding(.leading, 2)
                        }
                        .animation(.spring(duration: 0.4), value: message.content.isEmpty)
                    }
                }
                // Timestamps removed - now shown in date header instead
            }
            .opacity(isVisible ? 1 : 0)
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
        LottieView(name: "thinking_animation", loopMode: .loop)
            .frame(width: 89, height: 89) // 15% smaller
    }
}

// MARK: - Date header --------------------------------------------------------

struct DateHeaderView: View {
    let firstMessageTime: Date?
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
        let dateText = Self.smart(Date())
        
        if let time = firstMessageTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            let timeText = formatter.string(from: time)
            return "\(dateText) \(timeText)"
        } else {
            return dateText
        }
    }

    // smart-date formatter
    private static func smart(_ date: Date) -> String {
        let cal = Calendar.current
        let now = Date()
        if cal.isDate(date, inSameDayAs: now) { return "TODAY" }
        if cal.isDate(date, inSameDayAs: cal.date(byAdding: .day, value: -1, to: now)!) { return "YESTERDAY" }

        let weekAgo = cal.date(byAdding: .day, value: -7, to: now)!
        let fmt = DateFormatter()
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
                .foregroundColor(message.isUser ? .black : Color(hex: "#BBBBBB"))
            VStack(alignment: .leading, spacing: 2) {
                Text(message.fileName ?? "Unknown File")
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(message.isUser ? .black : Color(hex: "#EEEEEE"))
                    .lineLimit(1)
                if let url = message.fileURL {
                    Text(url.pathExtension.uppercased())
                        .font(.custom("IBMPlexMono", size: 10))
                        .foregroundColor(message.isUser ? .black.opacity(0.6) : Color(hex: "#BBBBBB"))
                }
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(message.isUser ? Color(hex: "#EEEEEE") : Color(hex: "#2A2A2A"))
        .cornerRadius(4)
    }
}

// ------------ Preview ------------------------------------------------------

#Preview {
    TextModalView(viewModel: MainViewModel(), isPresented: .constant(true), messageHistory: [])
        .preferredColorScheme(.dark)
}


