import SwiftUI
import UIKit
import UniformTypeIdentifiers

// MARK: - Chat screen --------------------------------------------------------

struct TextModalView: View {
    // View-models
    @ObservedObject var viewModel: MainViewModel          // your existing VM
    @StateObject private var llm = ChatViewModel()        // NEW: streams reply
    
    init(viewModel: MainViewModel, isPresented: Binding<Bool>) {
        print("🔍 TextModalView init")
        self.viewModel = viewModel
        self._isPresented = isPresented
    }

    // UI state
    @Binding var isPresented: Bool
    @State private var messageText = ""
    @State private var selectedDetent: PresentationDetent = .large
    @FocusState private var isTextFieldFocused: Bool
    @State private var showingDocumentPicker = false
    @State private var showDateHeader = false

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
            .onChange(of: viewModel.messages.count) { _, _ in
                // Update date header when messages change
                checkIfShouldShowDateHeader()
                
                if let last = viewModel.messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(last.id, anchor: .center)
                    }
                }
            }
        }
    }

    // MARK: input bar --------------------------------------------------------
    private var inputBar: some View {
        VStack {
            HStack(spacing: 12) {
                // File picker button
                Button { showingDocumentPicker = true } label: {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                        .frame(width: 44, height: 44)
                        .background(Color(hex: "#2A2A2A"))
                        .cornerRadius(4)
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showingDocumentPicker) {
                    DocumentPicker { url in handleFileUpload(url) }
                }

                // Text field
                TextField("", text: $messageText, axis: .vertical)
                    .font(.custom("IBMPlexMono", size: 16))
                    .foregroundColor(Color(hex: "#EEEEEE"))
                    .padding(.horizontal, 16)
                    .padding(.trailing, trailingPadding)
                    .padding(.vertical, 12)
                    .background(Color(hex: "#2A2A2A"))
                    .cornerRadius(4)
                    .accentColor(.white)
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        print("TextField onSubmit triggered!")
                        NSLog("TextField onSubmit triggered!")
                        sendMessage()
                    }
                    .overlay(placeholderOverlay, alignment: .leading)
                    .overlay(sendButtonOverlay, alignment: .bottomTrailing)
                    .animation(.easeInOut(duration: 0.05), value: isTextFieldFocused)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
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
                sendMessage()
            }) {
                Image(systemName: "arrow.up.square.fill")
                    .font(.title)
                    .foregroundColor(Color(hex: "#EEEEEE"))
            }
            .transition(.opacity)
            .padding(.trailing, 8)
            .padding(.bottom, 8)
        }
    }

    // MARK: - BUTTON ACTION --------------------------------------------------
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        print("sendMessage called with text: '\(text)'")
        NSLog("sendMessage called with text: '\(text)'")

        // Stop any existing polling before starting new message
        isPolling = false
        pollCount = 0

        // Check if this is the same message as last time
        isDuplicateMessage = text == lastSentMessage
        lastSentMessage = text

        // Clear any existing thinking messages (empty assistant messages)
        viewModel.messages.removeAll { message in
            !message.isUser && message.content.isEmpty
        }
        
        // Reset animation state for new message
        isPolling = false
        pollCount = 0
        isDuplicateMessage = false
        
        // Force UI refresh by updating lastRenderedTranscript
        lastRenderedTranscript = ""

        // 1) user bubble
        viewModel.sendTextMessage(text)

        // 2) placeholder assistant bubble (slight delay so it appears after user bubble)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let placeholder = ChatMessage(
                content: "",
                isUser: false,
                timestamp: Date(),
                messageType: .text
            )
            viewModel.messages.append(placeholder)
            print("Added empty placeholder message (delayed)")
        }

        // 3) clear field + ask model
        DispatchQueue.main.async {
            self.messageText = ""
        }
        print("🔍 About to call llm.send(text) with text: '\(text)'")
        llm.send(text, conversationHistory: viewModel.messages)

        // 4) start polling the stream immediately for real-time word streaming
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("Starting monitorAssistantStream")
            isPolling = true
            pollCount = 0
            monitorAssistantStream()
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
    private let maxPollCount = 300 // 30 seconds max (300 * 0.1s)

    private func monitorAssistantStream() {
        DispatchQueue.main.async {
            print("monitorAssistantStream - transcript: '\(llm.transcript)', lastRendered: '\(lastRenderedTranscript)', pollCount: \(pollCount)")
            
            // Stop polling if we've exceeded max attempts
            if pollCount >= maxPollCount {
                print("Stopping poll - exceeded max attempts")
                isPolling = false
                pollCount = 0
                return
            }
            
            // Check if transcript has changed
            let currentTranscriptLength = llm.transcript.count
            let transcriptChanged = llm.transcript != lastRenderedTranscript
            
            // Update only when transcript changed to avoid array churn
            guard transcriptChanged else {
                // If this is a duplicate message, wait a bit longer but not too long
                if isDuplicateMessage && pollCount > 30 { // 3 seconds for duplicates
                    print("Stopping poll - duplicate message with no transcript change for 3 seconds")
                    isPolling = false
                    pollCount = 0
                    isDuplicateMessage = false
                    // Trigger auto-save when response is complete
                    viewModel.autoSaveIfNeeded()
                    return
                }
                
                // If transcript hasn't changed for a while, stop polling
                if pollCount > 50 { // 5 seconds of no change
                    print("Stopping poll - no transcript change for 5 seconds")
                    isPolling = false
                    pollCount = 0
                    // Trigger auto-save when response is complete
                    viewModel.autoSaveIfNeeded()
                    return
                }
                self.scheduleNextPoll()
                return
            }
            
            lastRenderedTranscript = llm.transcript
            lastTranscriptLength = currentTranscriptLength
            pollCount = 0 // Reset counter when transcript changes

            if let idx = viewModel.messages.lastIndex(where: { !$0.isUser }),
               idx < viewModel.messages.count {
                print("Updating existing assistant message at index \(idx)")
                // Mutate the last assistant bubble in place (no array replacement)
                viewModel.messages[idx].content = llm.transcript
            } else {
                print("Creating new assistant message")
                // Create initial assistant bubble
                let bot = ChatMessage(
                    content: llm.transcript,
                    isUser: false,
                    timestamp: Date(),
                    messageType: .text
                )
                viewModel.messages.append(bot)
            }

            self.scheduleNextPoll()
        }
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
                llm.send("Please analyze this file content and provide a summary: \(formattedContent)", conversationHistory: viewModel.messages)
                
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

    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: (message.isUser && !message.content.isEmpty) ? 4 : 0) {
                if message.messageType == .file {
                    FileMessageView(message: message)
                } else {
                    if !message.isUser && message.content.isEmpty {
                        // Show thinking animation for empty assistant messages
                        ThinkingAnimationView()
                    } else {
                        if message.isUser {
                            // User messages show normally
                            Text(message.content)
                                .font(.custom("IBMPlexMono", size: 16))
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 16).padding(.vertical, 10)
                                .background(Color(hex: "#2A2A2A"))
                                .cornerRadius(4)
                                .foregroundColor(Color(hex: "#EEEEEE"))
                        } else {
                            // LLM messages without background
                            Text(message.content)
                                .font(.custom("IBMPlexMono", size: 16))
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(Color(hex: "#EEEEEE"))
                        }
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
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Rectangle()
                    .fill(Color(hex: "#EEEEEE"))
                    .frame(width: 4, height: 4) // Square and smaller
                    .offset(y: isAnimating ? -2 : 0) // Same movement
                    .animation(
                        .linear(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            // Reset animation state first
            isAnimating = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isAnimating = true
            }
        }
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
                .foregroundColor(Color(hex: "#BBBBBB"))
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
            formatter.dateFormat = "HH:mm"
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
        if cal.isDate(date, inSameDayAs: now) { return "Today" }
        if cal.isDate(date, inSameDayAs: cal.date(byAdding: .day, value: -1, to: now)!) { return "Yesterday" }

        let weekAgo = cal.date(byAdding: .day, value: -7, to: now)!
        let fmt = DateFormatter()
        if date > weekAgo { fmt.dateFormat = "EEEE, MMM d" } else { fmt.dateFormat = "MMM d, yyyy" }
        return fmt.string(from: date)
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

// MARK: - Document picker ----------------------------------------------------

struct DocumentPicker: UIViewControllerRepresentable {
    let onPick: (URL) -> Void
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes:
            [.text, .plainText, .pdf, .image, .audio, .movie], asCopy: true)
        picker.delegate = context.coordinator; picker.allowsMultipleSelection = false; return picker
    }
    func updateUIViewController(_: UIDocumentPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker; init(_ p: DocumentPicker) { parent = p }
        func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first { parent.onPick(url) }
        }
    }
}

// ------------ Preview ------------------------------------------------------

#Preview {
    // Provide default init values for preview
    TextModalView(viewModel: MainViewModel(), isPresented: .constant(true))
        .preferredColorScheme(.dark)
}


