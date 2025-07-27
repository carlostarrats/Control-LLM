import SwiftUI

struct TextModalView: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Messages list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding()
                }
                
                // Input area
                HStack {
                    TextField("Type your message...", text: $messageText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .navigationTitle("Text Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(18)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

#Preview {
    TextModalView(viewModel: MainViewModel())
} 