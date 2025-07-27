import Foundation

@MainActor
class HistoryViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var chatHistory: [ChatSession] = []
    @Published var audioHistory: [AudioNote] = []
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample chat history
        chatHistory = [
            ChatSession(
                id: UUID(),
                title: "Project Discussion",
                lastMessage: "Let's review the requirements...",
                timestamp: Date().addingTimeInterval(-3600),
                messageCount: 15
            ),
            ChatSession(
                id: UUID(),
                title: "Code Review",
                lastMessage: "The implementation looks good",
                timestamp: Date().addingTimeInterval(-7200),
                messageCount: 8
            ),
            ChatSession(
                id: UUID(),
                title: "Meeting Notes",
                lastMessage: "Action items for next week",
                timestamp: Date().addingTimeInterval(-86400),
                messageCount: 23
            )
        ]
        
        // Sample audio history
        audioHistory = [
            AudioNote(
                id: UUID(),
                title: "Voice Memo 1",
                duration: 120,
                timestamp: Date().addingTimeInterval(-1800),
                transcription: "This is a sample voice memo transcription..."
            ),
            AudioNote(
                id: UUID(),
                title: "Meeting Recording",
                duration: 1800,
                timestamp: Date().addingTimeInterval(-7200),
                transcription: "Team meeting discussion about..."
            ),
            AudioNote(
                id: UUID(),
                title: "Quick Note",
                duration: 45,
                timestamp: Date().addingTimeInterval(-3600),
                transcription: "Remember to follow up on..."
            )
        ]
    }
    
    func deleteChatSession(_ session: ChatSession) {
        chatHistory.removeAll { $0.id == session.id }
    }
    
    func deleteAudioNote(_ note: AudioNote) {
        audioHistory.removeAll { $0.id == note.id }
    }
}

struct ChatSession: Identifiable {
    let id: UUID
    let title: String
    let lastMessage: String
    let timestamp: Date
    let messageCount: Int
}

struct AudioNote: Identifiable {
    let id: UUID
    let title: String
    let duration: TimeInterval
    let timestamp: Date
    let transcription: String
} 