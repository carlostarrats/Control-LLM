import SwiftUI

struct TextModalView: View {
    @ObservedObject var viewModel: MainViewModel
    @Binding var isPresented: Bool
    @State private var messageText = ""
    @State private var selectedDetent: PresentationDetent = .large
    @State private var glowAnimation: Double = 0
    
    init(viewModel: MainViewModel, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self._isPresented = isPresented
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
                                    .foregroundColor(Color(hex: "#B3B3B3"))
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
                    .padding(.top, 80)
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
            
            // Input area - fixed at bottom
            VStack(spacing: 0) {
                Divider()
                    .background(Color(hex: "#E6E6E6").opacity(0.6))
                    .padding(.horizontal, 20)
                
                HStack {
                    TextField("Ask Anything...", text: $messageText, axis: .vertical)
                        .font(.custom("IBMPlexMono", size: 16))
                        .padding(.horizontal, 16)
                        .padding(.trailing, 50)
                        .padding(.vertical, 12)
                        .cornerRadius(12)
                        .accentColor(.white)
                        .overlay(
                            Button(action: sendMessage) {
                                Image(systemName: "arrow.up.circle")
                                    .font(.title)
                                    .foregroundColor(Color(hex: "#E6E6E6"))
                            }
                            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .padding(.trailing, 8)
                            .padding(.bottom, 8),
                            alignment: .bottomTrailing
                        )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .background(Color(hex: "#141414"))
        .presentationDetents([.height(100), .medium, .large], selection: $selectedDetent)
        .presentationDragIndicator(.visible)
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        viewModel.sendTextMessage(trimmedText)
        messageText = ""
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
                Text(message.content)
                    .font(.custom("IBMPlexMono", size: 16))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isUser ? Color(hex: "#E6E6E6") : Color.gray.opacity(0.2))
                    .cornerRadius(18)
                    .foregroundColor(message.isUser ? .black : .primary)
                
                Text(message.timestamp, style: .time)
                    .font(.custom("IBMPlexMono", size: 12))
                    .foregroundColor(.secondary)
            }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

#Preview {
    TextModalView(viewModel: MainViewModel(), isPresented: .constant(true))
        .preferredColorScheme(.dark)
} 