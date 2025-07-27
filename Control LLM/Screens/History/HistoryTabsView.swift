import SwiftUI

struct HistoryTabsView: View {
    @ObservedObject var viewModel: HistoryViewModel
    
    var body: some View {
        VStack {
            // Tab selector
            Picker("History Type", selection: $viewModel.selectedTab) {
                Text("Chat").tag(0)
                Text("Audio").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Tab content
            TabView(selection: $viewModel.selectedTab) {
                ChatHistoryTab(viewModel: viewModel)
                    .tag(0)
                
                AudioHistoryTab(viewModel: viewModel)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

struct ChatHistoryTab: View {
    @ObservedObject var viewModel: HistoryViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.chatHistory) { session in
                ChatHistoryRow(session: session)
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            viewModel.deleteChatSession(session)
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
}

struct AudioHistoryTab: View {
    @ObservedObject var viewModel: HistoryViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.audioHistory) { note in
                AudioHistoryRow(note: note)
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            viewModel.deleteAudioNote(note)
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
}

struct ChatHistoryRow: View {
    let session: ChatSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.title)
                    .font(.headline)
                Spacer()
                Text(session.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(session.lastMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text("\(session.messageCount) messages")
                    .font(.caption)
                    .foregroundColor(.blue)
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

struct AudioHistoryRow: View {
    let note: AudioNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.title)
                    .font(.headline)
                Spacer()
                Text(note.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(note.transcription)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(.blue)
                Text(formatDuration(note.duration))
                    .font(.caption)
                    .foregroundColor(.blue)
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    HistoryTabsView(viewModel: HistoryViewModel())
} 