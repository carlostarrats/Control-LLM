import Foundation
import SwiftUI

class ChatHistoryService: ObservableObject {
    static let shared = ChatHistoryService()
    
    @Published var historyGroups: [HistoryGroup] = []
    @Published var referenceChatHistory: Bool = true
    
    private let userDefaults = UserDefaults.standard
    private let historyKey = "chat_history"
    private let referenceKey = "reference_chat_history"
    private let sessionsKey = "chat_sessions"
    
    // Store full ChatSession objects separately for complete message history
    private var chatSessions: [String: ChatSession] = [:]
    
    private init() {
        loadReferenceSetting()
        loadChatSessions()
        loadHistoryData()
        
        // Clear any existing sample data on first run after update
        clearSampleDataIfNeeded()
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
        // Store the full session for message retrieval
        chatSessions[session.id] = session
        saveChatSessions()
        
        // Find or create the year group
        let year = Calendar.current.component(.year, from: session.date)
        let yearString = String(year)
        
        // Format the date for grouping conversations by day
        let today = Date()
        let formattedDate = formatDate(session.date, today: today)
        
        // Create the chat summary for this session
        let fullSummary = createFullSummary(from: session)
        let summary = ChatSummary(
            id: session.id,
            summary: session.title,
            expandedSummaries: [
                ExpandedSummary(
                    id: UUID().uuidString,
                    content: fullSummary,
                    buttonText: "Continue Chat"
                )
            ],
            timestamp: formatTime(session.date)
        )
        
        if let yearIndex = historyGroups.firstIndex(where: { $0.year == yearString }) {
            // Check if there's already an entry for this date
            if let entryIndex = historyGroups[yearIndex].entries.firstIndex(where: { $0.date == formattedDate }) {
                // Add to existing date entry - insert at beginning for newest first
                historyGroups[yearIndex].entries[entryIndex].chats.insert(summary, at: 0)
            } else {
                // Create new date entry and insert at beginning
                let newEntry = ChatHistoryEntry(date: formattedDate, chats: [summary])
                historyGroups[yearIndex].entries.insert(newEntry, at: 0)
            }
        } else {
            // Create new year group with new date entry
            let newEntry = ChatHistoryEntry(date: formattedDate, chats: [summary])
            let newGroup = HistoryGroup(year: yearString, entries: [newEntry])
            historyGroups.insert(newGroup, at: 0)
        }
        
        saveHistoryData()
    }
    
    func deleteAllHistory() {
        historyGroups.removeAll()
        chatSessions.removeAll()
        saveHistoryData()
        saveChatSessions()
    }
    
    func getChatSession(byId id: String) -> ChatSession? {
        // Return the full session with complete message history
        return chatSessions[id]
    }
    
    private func parseDate(from dateString: String, timestamp: String) -> Date? {
        // Try to parse the date and timestamp back to a Date object
        // This is a simplified implementation
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d" // e.g., "Dec 25"
        if let date = formatter.date(from: dateString) {
            // Add current year if not specified
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
            return calendar.date(byAdding: .year, value: currentYear - 1970, to: date) // Adjust for year
        }
        return nil
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
            // No saved data, start with empty history
            historyGroups = []
            return
        }
        
        historyGroups = savedGroups
    }
    
    private func saveHistoryData() {
        guard let data = try? JSONEncoder().encode(historyGroups) else { return }
        userDefaults.set(data, forKey: historyKey)
    }
    
    private func loadChatSessions() {
        guard let data = userDefaults.data(forKey: sessionsKey),
              let sessions = try? JSONDecoder().decode([String: ChatSession].self, from: data) else {
            chatSessions = [:]
            return
        }
        chatSessions = sessions
    }
    
    private func saveChatSessions() {
        guard let data = try? JSONEncoder().encode(chatSessions) else { return }
        userDefaults.set(data, forKey: sessionsKey)
    }
    
    // MARK: - Helper Methods
    
    private func createHistoryEntry(from session: ChatSession) -> ChatHistoryEntry {
        let today = Date()
        let formattedDate = formatDate(session.date, today: today)
        
        // Store a detailed summary including the full conversation context
        let fullSummary = createFullSummary(from: session)
        
        let summary = ChatSummary(
            id: session.id,
            summary: session.title,
            expandedSummaries: [
                ExpandedSummary(
                    id: UUID().uuidString,
                    content: fullSummary,
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
    
    private func createFullSummary(from session: ChatSession) -> String {
        // Create a natural conversation summary
        guard let messages = session.messages, !messages.isEmpty else {
            return session.summary
        }
        
        let userMessages = messages.filter { $0.isUser }
        let _ = messages.filter { !$0.isUser && !$0.content.isEmpty }
        
        // Get first few user messages to create a better summary
        let keyQuestions = userMessages.prefix(3).map { $0.content.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        if keyQuestions.count == 1 {
            return keyQuestions[0]
        } else if keyQuestions.count == 2 {
            return "\(keyQuestions[0]) and \(keyQuestions[1])"
        } else {
            return "\(keyQuestions[0]), \(keyQuestions[1]), and more"
        }
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
    
    // MARK: - Helper Methods for Chat Summaries
    
    func generateChatSummary(from messages: [ChatMessage]) -> String {
        // Create a summary from the first user message or use a default
        let userMessages = messages.filter { $0.isUser }
        if let firstUserMessage = userMessages.first {
            let content = firstUserMessage.content.trimmingCharacters(in: .whitespacesAndNewlines)
            // Truncate to reasonable length for summary
            if content.count > 60 {
                return String(content.prefix(57)) + "..."
            }
            return content
        }
        return "New conversation"
    }
    
    func generateChatTitle(from messages: [ChatMessage]) -> String {
        // Use first user message as title, or generate from content
        let userMessages = messages.filter { $0.isUser }
        if let firstUserMessage = userMessages.first {
            let content = firstUserMessage.content.trimmingCharacters(in: .whitespacesAndNewlines)
            // Keep title shorter
            if content.count > 40 {
                return String(content.prefix(37)) + "..."
            }
            return content
        }
        return "Chat conversation"
    }
    
    private func clearSampleDataIfNeeded() {
        let hasSeenUpdateKey = "has_cleared_sample_data_v3"
        
        if !userDefaults.bool(forKey: hasSeenUpdateKey) {
            // Clear all existing data including UI state
            historyGroups.removeAll()
            chatSessions.removeAll()
            saveHistoryData()
            saveChatSessions()
            
            // Also clear date header tracking for fresh start
            userDefaults.removeObject(forKey: "lastDateHeaderShown")
            
            // Mark that we've cleared the sample data
            userDefaults.set(true, forKey: hasSeenUpdateKey)
            
            print("🧹 Cleared sample data and UI state - starting fresh with real conversations only")
        }
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


