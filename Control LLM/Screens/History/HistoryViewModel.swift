import SwiftUI

class HistoryViewModel: ObservableObject {
    @Published var historyGroups: [HistoryGroup] = []
    
    init() {
        loadHistoryData()
    }
    
    private func loadHistoryData() {
        // Create sample data with proper dates
        let calendar = Calendar.current
        let today = Date()
        
        // Sample chat entries with various dates
        let sampleEntries: [(Date, String, String)] = [
            // Today
            (today, "Top 10 kinds of movieslfksf sflksk ks slss skfsfsfdfksldfklsfkl ks slkd slkd sk", "This conversation covered various movie genres including action, drama, comedy, thriller, horror, sci-fi, romance, documentary, animation, and musical. We discussed the characteristics of each genre and provided examples of notable films in each category."),
            
            // Yesterday - this will be formatted as "Yesterday"
            (calendar.date(byAdding: .day, value: -1, to: today)!, "Best programming practices for Swift development", "We discussed essential Swift programming practices including proper naming conventions, memory management, error handling, and design patterns. Key topics covered were ARC, optionals, protocols, and SwiftUI best practices."),
            
            // 3 days ago (within last 7 days)
            (calendar.date(byAdding: .day, value: -3, to: today)!, "How to implement dark mode in iOS apps", "Comprehensive guide on implementing dark mode in iOS applications. We covered color schemes, asset management, dynamic colors, and user preference handling for seamless dark mode transitions."),
            
            // 5 days ago (within last 7 days)
            (calendar.date(byAdding: .day, value: -5, to: today)!, "Machine learning algorithms comparison", "We compared various machine learning algorithms including supervised learning (linear regression, logistic regression, decision trees), unsupervised learning (clustering, dimensionality reduction), and deep learning approaches."),
            
            // 10 days ago (past last 7 days)
            (calendar.date(byAdding: .day, value: -10, to: today)!, "Advanced SwiftUI animations", "We explored advanced SwiftUI animation techniques including custom transitions, spring animations, and complex gesture-based interactions. Covered topics included matched geometry effects, timeline animations, and performance optimization."),
            
            // 15 days ago (past last 7 days)
            (calendar.date(byAdding: .day, value: -15, to: today)!, "iOS app architecture patterns", "We discussed various iOS app architecture patterns including MVC, MVVM, VIPER, and Clean Architecture. Each pattern was analyzed for its benefits, trade-offs, and implementation strategies."),
            
            // Last year
            (calendar.date(byAdding: .year, value: -1, to: today)!, "Legacy project migration strategies", "We covered strategies for migrating legacy iOS projects to modern frameworks and practices. Topics included gradual migration approaches, dependency management, and testing strategies for large codebases.")
        ]
        
        // Group entries by year and sort within each year
        var groupedByYear: [String: [(Date, String, String)]] = [:]
        
        for entry in sampleEntries {
            let year = calendar.component(.year, from: entry.0)
            let yearString = String(year)
            if groupedByYear[yearString] == nil {
                groupedByYear[yearString] = []
            }
            groupedByYear[yearString]?.append(entry)
        }
        
        // Sort entries within each year according to the specified logic
        for year in groupedByYear.keys {
            groupedByYear[year]?.sort { entry1, entry2 in
                let daysDiff1 = calendar.dateComponents([.day], from: entry1.0, to: today).day ?? 0
                let daysDiff2 = calendar.dateComponents([.day], from: entry2.0, to: today).day ?? 0
                
                // Today comes first
                if daysDiff1 == 0 && daysDiff2 != 0 { return true }
                if daysDiff2 == 0 && daysDiff1 != 0 { return false }
                
                // Yesterday comes second
                if daysDiff1 == 1 && daysDiff2 != 1 { return true }
                if daysDiff2 == 1 && daysDiff1 != 1 { return false }
                
                // Within last 7 days, sort by date (most recent first)
                if daysDiff1 <= 7 && daysDiff2 <= 7 {
                    return entry1.0 > entry2.0
                }
                
                // Past 7 days, sort by date (most recent first)
                return entry1.0 > entry2.0
            }
        }
        
        // Convert to HistoryGroup format with multiple summaries per date
        historyGroups = groupedByYear.keys.sorted(by: >).map { year in
            let entries = groupedByYear[year]!.map { entry in
                let formattedDate = formatDate(entry.0, today: today)
                print("Processing date: \(entry.0), formatted as: '\(formattedDate)'")
                
                // Create multiple summaries for yesterday to demonstrate the layout
                var summaries: [ChatSummary] = []
                
                if formattedDate == "Yesterday" {
                    // Add multiple summaries for yesterday
                    summaries = [
                        ChatSummary(
                            id: UUID().uuidString,
                            summary: "Best programming practices for Swift development",
                            expandedSummaries: [
                                ExpandedSummary(
                                    id: UUID().uuidString,
                                    content: "We discussed essential Swift programming practices including proper naming conventions, memory management, error handling, and design patterns. Key topics covered were ARC, optionals, protocols, and SwiftUI best practices.",
                                    buttonText: "Continue Chat"
                                )
                            ],
                            timestamp: formatTime(entry.0)
                        ),
                        ChatSummary(
                            id: UUID().uuidString,
                            summary: "UI/UX design principles for mobile apps",
                            expandedSummaries: [
                                ExpandedSummary(
                                    id: UUID().uuidString,
                                    content: "We explored fundamental UI/UX design principles including visual hierarchy, consistency, accessibility, and user-centered design. Covered topics included color theory, typography, spacing, and interaction patterns.",
                                    buttonText: "Continue Chat"
                                )
                            ],
                            timestamp: formatTime(entry.0)
                        ),
                        ChatSummary(
                            id: UUID().uuidString,
                            summary: "Performance optimization techniques",
                            expandedSummaries: [
                                ExpandedSummary(
                                    id: UUID().uuidString,
                                    content: "We discussed various performance optimization techniques for iOS apps including memory management, image caching, network optimization, and UI rendering improvements. Key focus areas were reducing app launch time and improving user experience.",
                                    buttonText: "Continue Chat"
                                )
                            ],
                            timestamp: formatTime(entry.0)
                        )
                    ]
                } else {
                    // Single summary for other dates
                    summaries = [
                        ChatSummary(
                            id: UUID().uuidString,
                            summary: entry.1,
                            expandedSummaries: [
                                ExpandedSummary(
                                    id: UUID().uuidString,
                                    content: entry.2,
                                    buttonText: "Continue Chat"
                                )
                            ],
                            timestamp: formatTime(entry.0)
                        )
                    ]
                }
                
                return ChatHistoryEntry(
                    date: formattedDate,
                    chats: summaries
                )
            }
            
            return HistoryGroup(year: year, entries: entries)
        }
    }
    
    private func formatDate(_ date: Date, today: Date) -> String {
        let calendar = Calendar.current
        let daysDiff = calendar.dateComponents([.day], from: date, to: today).day ?? 0
        
        let dateFormatter = DateFormatter()
        
        if daysDiff == 0 {
            return "Today"
        } else if daysDiff == 1 {
            return "Yesterday"
        } else if daysDiff <= 7 {
            // Last 7 days: "Thursday, Dec 23"
            dateFormatter.dateFormat = "EEEE, MMM d"
            return dateFormatter.string(from: date)
        } else {
            // Past 7 days: "Dec 15"
            dateFormatter.dateFormat = "MMM d"
            return dateFormatter.string(from: date)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        return dateFormatter.string(from: date)
    }
}

struct HistoryGroup: Identifiable {
    let id = UUID()
    let year: String
    var entries: [ChatHistoryEntry] // Changed to var
}

struct ChatHistoryEntry: Identifiable {
    let id = UUID()
    let date: String
    var chats: [ChatSummary] // Changed to var
}

struct ChatSummary: Identifiable {
    let id: String
    let summary: String
    let expandedSummaries: [ExpandedSummary]
    let timestamp: String
    
    // Ensure summary fits within 2 lines (approximately 60-80 characters)
    var truncatedSummary: String {
        if summary.count > 80 {
            return String(summary.prefix(77)) + "..."
        }
        return summary
    }
}

struct ExpandedSummary: Identifiable {
    let id: String
    let content: String
    let buttonText: String
} 