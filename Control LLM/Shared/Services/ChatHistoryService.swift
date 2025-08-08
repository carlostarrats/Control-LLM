import Foundation
import SwiftUI

class ChatHistoryService: ObservableObject {
    static let shared = ChatHistoryService()
    
    @Published var historyGroups: [HistoryGroup] = []
    @Published var referenceChatHistory: Bool = true
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "chat_history"
    private let referenceKey = "reference_chat_history"
    
    private init() {
        loadReferenceSetting()
        loadHistoryData()
    }
    
    // MARK: - Reference Chat History Setting
    
    func toggleReferenceChatHistory() {
        referenceChatHistory.toggle()
        saveReferenceSetting()
    }
    
    private func loadReferenceSetting() {
        referenceChatHistory = userDefaults.object(forKey: referenceKey) as? Bool ?? true
    }
    
    private func saveReferenceSetting() {
        userDefaults.set(referenceChatHistory, forKey: referenceKey)
    }
    
    // MARK: - Chat History Management
    
    func addChatSession(_ session: ChatSession) {
        // Add new chat session to history
        let entry = createHistoryEntry(from: session)
        
        // Find or create the year group
        let year = Calendar.current.component(.year, from: session.date)
        let yearString = String(year)
        
        if let index = historyGroups.firstIndex(where: { $0.year == yearString }) {
            // Add to existing year group
            historyGroups[index].entries.insert(entry, at: 0) // Add at beginning
        } else {
            // Create new year group
            let newGroup = HistoryGroup(year: yearString, entries: [entry])
            historyGroups.insert(newGroup, at: 0) // Add at beginning
        }
        
        saveHistoryData()
    }
    
    func deleteAllHistory() {
        historyGroups.removeAll()
        saveHistoryData()
    }
    
    func deleteHistoryEntry(_ entry: ChatHistoryEntry) {
        for (groupIndex, group) in historyGroups.enumerated() {
            if let entryIndex = group.entries.firstIndex(where: { $0.id == entry.id }) {
                historyGroups[groupIndex].entries.remove(at: entryIndex)
                
                // Remove empty year groups
                if historyGroups[groupIndex].entries.isEmpty {
                    historyGroups.remove(at: groupIndex)
                }
                break
            }
        }
        saveHistoryData()
    }
    
    // MARK: - Data Loading and Saving
    
    private func loadHistoryData() {
        guard let data = userDefaults.data(forKey: historyKey),
              let savedGroups = try? JSONDecoder().decode([HistoryGroup].self, from: data) else {
            // No saved data, create sample data for demonstration
            createSampleData()
            return
        }
        
        historyGroups = savedGroups
    }
    
    private func saveHistoryData() {
        guard let data = try? JSONEncoder().encode(historyGroups) else { return }
        userDefaults.set(data, forKey: historyKey)
    }
    
    // MARK: - Helper Methods
    
    private func createHistoryEntry(from session: ChatSession) -> ChatHistoryEntry {
        let today = Date()
        let formattedDate = formatDate(session.date, today: today)
        
        let summary = ChatSummary(
            id: session.id,
            summary: session.title,
            expandedSummaries: [
                ExpandedSummary(
                    id: UUID().uuidString,
                    content: session.summary,
                    buttonText: "Continue Chat"
                )
            ],
            timestamp: formatTime(session.date)
        )
        
        return ChatHistoryEntry(
            date: formattedDate,
            chats: [summary]
        )
    }
    
    private func formatDate(_ date: Date, today: Date) -> String {
        let calendar = Calendar.current
        let daysDiff = calendar.dateComponents([.day], from: date, to: today).day ?? 0
        
        let dateFormatter = DateFormatter()
        
        if daysDiff == 0 {
            return "TODAY"
        } else if daysDiff == 1 {
            return "YESTERDAY"
        } else if daysDiff <= 7 {
            dateFormatter.dateFormat = "EEEE, MMM d"
            return dateFormatter.string(from: date).uppercased()
        } else {
            dateFormatter.dateFormat = "MMM d"
            return dateFormatter.string(from: date).uppercased()
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Sample Data Creation
    
    private func createSampleData() {
        let calendar = Calendar.current
        let today = Date()
        
        let sampleSessions: [ChatSession] = [
            ChatSession(
                id: UUID().uuidString,
                title: "Top 10 kinds of movies",
                summary: "This conversation covered various movie genres including action, drama, comedy, thriller, horror, sci-fi, romance, documentary, animation, and musical. We discussed the characteristics of each genre and provided examples of notable films in each category.",
                date: today
            ),
            ChatSession(
                id: UUID().uuidString,
                title: "Best programming practices for Swift development",
                summary: "We discussed essential Swift programming practices including proper naming conventions, memory management, error handling, and design patterns. Key topics covered were ARC, optionals, protocols, and SwiftUI best practices.",
                date: calendar.date(byAdding: .day, value: -1, to: today)!
            ),
            ChatSession(
                id: UUID().uuidString,
                title: "How to implement dark mode in iOS apps",
                summary: "Comprehensive guide on implementing dark mode in iOS applications. We covered color schemes, asset management, dynamic colors, and user preference handling for seamless dark mode transitions.",
                date: calendar.date(byAdding: .day, value: -3, to: today)!
            ),
            ChatSession(
                id: UUID().uuidString,
                title: "Machine learning algorithms comparison",
                summary: "We compared various machine learning algorithms including supervised learning (linear regression, logistic regression, decision trees), unsupervised learning (clustering, dimensionality reduction), and deep learning approaches.",
                date: calendar.date(byAdding: .day, value: -5, to: today)!
            ),
            ChatSession(
                id: UUID().uuidString,
                title: "Advanced SwiftUI animations",
                summary: "We explored advanced SwiftUI animation techniques including custom transitions, spring animations, and complex gesture-based interactions. Covered topics included matched geometry effects, timeline animations, and performance optimization.",
                date: calendar.date(byAdding: .day, value: -10, to: today)!
            ),
            ChatSession(
                id: UUID().uuidString,
                title: "iOS app architecture patterns",
                summary: "We discussed various iOS app architecture patterns including MVC, MVVM, VIPER, and Clean Architecture. Each pattern was analyzed for its benefits, trade-offs, and implementation strategies.",
                date: calendar.date(byAdding: .day, value: -15, to: today)!
            ),
            ChatSession(
                id: UUID().uuidString,
                title: "Legacy project migration strategies",
                summary: "We covered strategies for migrating legacy iOS projects to modern frameworks and practices. Topics included gradual migration approaches, dependency management, and testing strategies for large codebases.",
                date: calendar.date(byAdding: .year, value: -1, to: today)!
            )
        ]
        
        // Group sessions by year
        var groupedByYear: [String: [ChatSession]] = [:]
        
        for session in sampleSessions {
            let year = calendar.component(.year, from: session.date)
            let yearString = String(year)
            if groupedByYear[yearString] == nil {
                groupedByYear[yearString] = []
            }
            groupedByYear[yearString]?.append(session)
        }
        
        // Convert to HistoryGroup format
        historyGroups = groupedByYear.keys.sorted(by: >).map { year in
            let sessions = groupedByYear[year]!.sorted { $0.date > $1.date }
            let entries = sessions.map { createHistoryEntry(from: $0) }
            return HistoryGroup(year: year, entries: entries)
        }
        
        saveHistoryData()
    }
}

// MARK: - Data Models

struct ChatSession: Codable {
    let id: String
    let title: String
    let summary: String
    let date: Date
    let messages: [ChatMessage]?
    
    init(id: String, title: String, summary: String, date: Date, messages: [ChatMessage]? = nil) {
        self.id = id
        self.title = title
        self.summary = summary
        self.date = date
        self.messages = messages
    }
}


