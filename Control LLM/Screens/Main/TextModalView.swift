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
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 100)
                    .padding(.bottom, 20)
                }
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(0.0), location: 0.0),
                            .init(color: Color.black.opacity(0.0), location: 0.01),
                            .init(color: Color.black.opacity(0.1), location: 0.04),
                            .init(color: Color.black.opacity(0.3), location: 0.08),
                            .init(color: Color.black.opacity(0.7), location: 0.12),
                            .init(color: Color.black.opacity(1.0), location: 0.16),
                            .init(color: Color.black.opacity(1.0), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input area - fixed at bottom
            VStack(spacing: 0) {
                Divider()
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
                                    .foregroundColor(Color(hex: "#E90068"))
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
                    .background(message.isUser ? Color(hex: "#E90068") : Color.gray.opacity(0.2))
                    .cornerRadius(18)
                    .foregroundColor(message.isUser ? .white : .primary)
                
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