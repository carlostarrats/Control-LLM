import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct TextModalView: View {
    @ObservedObject var viewModel: MainViewModel
    @Binding var isPresented: Bool
    @State private var messageText = ""
    @State private var selectedDetent: PresentationDetent = .large
    @State private var glowAnimation: Double = 0
    @FocusState private var isTextFieldFocused: Bool
    @State private var showingDocumentPicker = false
    
    init(viewModel: MainViewModel, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self._isPresented = isPresented
    }
    
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
            
            VStack(spacing: 0) {
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

                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 20)
                    }
                    
                    // Buffer space below header
                    Spacer()
                        .frame(height: 18)
                }
                .background(Color(hex: "#1D1D1D"))
                
                // Messages list - takes remaining space
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Date header - iOS style
                            if !viewModel.messages.isEmpty {
                                HStack {
                                    Spacer()
                                    Text(formatSmartDate(Date()))
                                        .font(.custom("IBMPlexMono", size: 12))
                                        .foregroundColor(Color(hex: "#BBBBBB"))
                                    Spacer()
                                }
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                            }
                            
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 24)
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .center)
                            }
                        }
                    }
                }
                
                // Input area with clean background
                VStack(spacing: 0) {
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            // File upload button
                            Button(action: {
                                showingDocumentPicker = true
                            }) {
                                Image(systemName: "doc.badge.plus")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(Color(hex: "#BBBBBB"))
                                    .frame(width: 44, height: 44)
                                    .background(Color(hex: "#2A2A2A"))
                                    .cornerRadius(4)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .sheet(isPresented: $showingDocumentPicker) {
                                DocumentPicker { url in
                                    handleFileUpload(url)
                                }
                            }
                            
                            // Text input field
                            TextField("", text: $messageText, axis: .vertical)
                                .font(.custom("IBMPlexMono", size: 16))
                                .foregroundColor(Color(hex: "#EEEEEE"))
                                .padding(.horizontal, 16)
                                .padding(.trailing, !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 50 : 16)
                                .padding(.vertical, 12)
                                .background(Color(hex: "#2A2A2A"))
                                .cornerRadius(4)
                                .accentColor(.white)
                                .focused($isTextFieldFocused)
                                .onTapGesture {
                                    isTextFieldFocused = true
                                }
                                .overlay(
                                    Group {
                                        if messageText.isEmpty {
                                            HStack {
                                                                                            Text("Ask Anything...")
                                                .font(.custom("IBMPlexMono", size: 16))
                                                .foregroundColor(Color(hex: "#666666"))
                                                .allowsHitTesting(false)
                                                Spacer()
                                            }
                                            .padding(.horizontal, 16)
                                        }
                                    },
                                    alignment: .leading
                                )
                                .overlay(
                                    Group {
                                        if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            Button(action: sendMessage) {
                                                Image(systemName: "arrow.up.square.fill")
                                                    .font(.title)
                                                    .foregroundColor(Color(hex: "#EEEEEE"))
                                            }
                                            .transition(.opacity)
                                            .padding(.trailing, 8)
                                            .padding(.bottom, 8)
                                        }
                                    },
                                    alignment: .bottomTrailing
                                )
                                .animation(.easeInOut(duration: 0.05), value: messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
        }
        .presentationDetents([.height(100), .medium, .large], selection: $selectedDetent)
        .presentationDragIndicator(.hidden) // Hide the system drag indicator
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        viewModel.sendTextMessage(trimmedText)
        messageText = ""
    }
    
    private func handleFileUpload(_ url: URL) {
        let fileName = url.lastPathComponent
        
        // Create a file message
        let fileMessage = ChatMessage(
            content: "📎 \(fileName)",
            isUser: true,
            timestamp: Date(),
            messageType: .file,
            fileName: fileName,
            fileURL: url
        )
        
        viewModel.messages.append(fileMessage)
        
        // TODO: Process the file with the LLM
        // This would involve reading the file content and sending it to the LLM
    }
    
    private func formatSmartDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        // Check if it's today
        if calendar.isDate(date, inSameDayAs: now) {
            return "Today"
        }
        
        // Check if it's yesterday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        if calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        }
        
        // Check if it's within the last 7 days (this week)
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        if date > weekAgo {
            // Format as "Wednesday, Jan 29"
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        } else {
            // Format as "Jan 20, 2025"
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                if message.messageType == .file {
                    FileMessageView(message: message)
                } else {
                                    Text(message.content)
                    .font(.custom("IBMPlexMono", size: 16))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isUser ? Color(hex: "#EEEEEE") : Color(hex: "#2A2A2A"))
                    .cornerRadius(4)
                    .foregroundColor(message.isUser ? .black : Color(hex: "#EEEEEE"))
                }
                
                Text(message.timestamp, style: .time)
                    .font(.custom("IBMPlexMono", size: 12))
                    .foregroundColor(Color(hex: "#BBBBBB"))
            }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

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
                
                if let fileURL = message.fileURL {
                    Text(fileURL.pathExtension.uppercased())
                        .font(.custom("IBMPlexMono", size: 10))
                        .foregroundColor(message.isUser ? .black.opacity(0.6) : Color(hex: "#BBBBBB"))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(message.isUser ? Color(hex: "#EEEEEE") : Color(hex: "#2A2A2A"))
        .cornerRadius(4)
    }
}

#Preview {
    TextModalView(viewModel: MainViewModel(), isPresented: .constant(true))
        .preferredColorScheme(.dark)
}

// MARK: - Document Picker
struct DocumentPicker: UIViewControllerRepresentable {
    let onPick: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .plainText, .pdf, .image, .audio, .movie], asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onPick(url)
        }
    }
}

 