import SwiftUI

class HistoryViewModel: ObservableObject {
    @Published var historyGroups: [HistoryGroup] = []
    
    private let chatHistoryService = ChatHistoryService.shared
    
    init() {
        // Observe changes from ChatHistoryService
        chatHistoryService.$historyGroups
            .assign(to: &$historyGroups)
    }
}

struct HistoryGroup: Identifiable, Codable {
    var id = UUID()
    let year: String
    var entries: [ChatHistoryEntry] // Changed to var
}

struct ChatHistoryEntry: Identifiable, Codable {
    var id = UUID()
    let date: String
    var chats: [ChatSummary] // Changed to var
}

struct ChatSummary: Identifiable, Codable {
    let id: String
    let summary: String
    let expandedSummaries: [ExpandedSummary]
    let timestamp: String
    
    // Ensure summary fits within 2 lines (approximately 60-80 characters)
    var truncatedSummary: String {
        if summary.count > 80 {
            let safeLength = min(77, summary.count)
            return String(summary.prefix(safeLength)) + "..."
        }
        return summary
    }
}

struct ExpandedSummary: Identifiable, Codable {
    let id: String
    let content: String
    let buttonText: String
} 