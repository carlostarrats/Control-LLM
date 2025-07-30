import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @Binding var showingTextModal: Bool
    @ObservedObject var mainViewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    
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
            
            // Scrollable content
            ScrollView {
                LazyVStack(spacing: 40) { // 40px between year groupings
                    ForEach(viewModel.historyGroups) { group in
                        HistoryGroupView(group: group) { chatEntry in
                            // Handle continue chat action
                            handleContinueChat(chatEntry: chatEntry)
                        }
                    }
                }
                .padding(.top, 10) // Reduced from 30px to 10px to maintain proper visual distance
                .padding(.bottom, 20)
                .padding(.horizontal, 20) // Add horizontal padding for centering
            }
            .safeAreaInset(edge: .top) {
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
                        Text("History")
                            .font(.custom("IBMPlexMono", size: 20))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                    
                    // Buffer space below header
                    Spacer()
                        .frame(height: 20)
                }
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: "#1D1D1D"),
                            Color(hex: "#1D1D1D").opacity(0.8),
                            Color(hex: "#1D1D1D").opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
    
    private func handleContinueChat(chatEntry: ChatHistoryEntry) {
        // 1. Load the chat context into the main view model
        mainViewModel.loadChatContext(from: chatEntry)
        
        // 2. Activate voice input mode
        mainViewModel.activateVoiceInputMode()
        
        // 3. Dismiss the history sheet smoothly
        dismiss()
    }
}

struct HistoryGroupView: View {
    let group: HistoryGroup
    let onChatSelected: (ChatHistoryEntry) -> Void
    
    var body: some View {
        VStack(spacing: 0) { // No spacing - we'll control it manually
            // Year (left-aligned)
            HStack {
                Text(group.year)
                    .font(.custom("IBMPlexMono", size: 18))
                    .foregroundColor(Color(hex: "#BBBBBB"))
                Spacer()
            }
            
            // 20px spacing from year to first date
            Spacer()
                .frame(height: 20)
            
            // Date entries with 20px spacing between date groupings
            VStack(spacing: 20) {
                ForEach(group.entries) { entry in
                    HistoryEntryView(entry: entry, onTap: onChatSelected)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct HistoryEntryView: View {
    let entry: ChatHistoryEntry
    let onTap: (ChatHistoryEntry) -> Void
    
    var body: some View {
        VStack(spacing: 0) { // No spacing - controlled by parent
            // Date (left-aligned)
            HStack {
                Text(entry.date)
                    .font(.custom("IBMPlexMono", size: 16))
                    .foregroundColor(Color(hex: "#BBBBBB"))
                Spacer()
            }
            
            // Horizontal line under date (left-aligned)
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(height: 2)
            
            // 10px spacing from horizontal line to first chat summary
            Spacer()
                .frame(height: 10)
            
            // Chat entries
            VStack(spacing: 10) { // 10px between groups of text
                ForEach(entry.chats) { chat in
                    ChatSummaryView(chat: chat, entry: entry, onTap: onTap)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ChatSummaryView: View {
    let chat: ChatSummary
    let entry: ChatHistoryEntry
    let onTap: (ChatHistoryEntry) -> Void
    @State private var isExpanded = false
    
    var body: some View {
        HStack(spacing: 10) { // 10px between vertical line and content
            // Vertical line that extends to cover both main and expanded content
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(width: 1)
                .frame(maxHeight: .infinity) // Height of the entire content area
            
            // Main content area
            VStack(spacing: 0) {
                // Main summary headline (clickable)
                HStack {
                    Text(chat.summary)
                        .font(.custom("IBMPlexMono", size: 14))
                        .foregroundColor(Color(hex: "#EEEEEE"))
                        .lineLimit(2) // Max 2 lines
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 6) // Changed from 8 to 6px
                        .frame(maxWidth: .infinity, alignment: .leading) // Text is left-aligned within its own frame, and the frame expands
                        .background(
                            Rectangle()
                                .fill(Color(hex: "#333333"))
                        )
                    
                    // Arrow indicator
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                        .padding(.trailing, 8)
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }
                
                // Expanded content with proper masking
                if isExpanded {
                    VStack(spacing: 10) { // 10px between expanded summaries
                        ForEach(chat.expandedSummaries.prefix(1)) { expandedSummary in
                            ExpandedSummaryView(summary: expandedSummary) {
                                // Handle continue chat action
                                onTap(entry)
                            }
                        }
                    }
                    .padding(.top, 10) // 10px spacing from main summary to expanded content
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                        removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                    ))
                }
            }
        }
        .clipped() // Ensure expanded content doesn't overflow
        .zIndex(isExpanded ? 1 : 0) // Ensure expanded content appears above other items
    }
}

struct ExpandedSummaryView: View {
    let summary: ExpandedSummary
    let onContinueChat: () -> Void
    
    var body: some View {
        // Expanded summary content (no separate vertical line needed)
        VStack(spacing: 8) { // 8px between summary text and button
            Text(summary.content)
                .font(.custom("IBMPlexMono", size: 14))
                .foregroundColor(Color(hex: "#EEEEEE"))
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 4)
                .padding(.vertical, 6) // Changed from 16 to 6px
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Rectangle()
                        .fill(Color(hex: "#252525"))
                )
            
            // Continue Chat button
            Button(action: onContinueChat) {
                Text(summary.buttonText)
                    .font(.custom("IBMPlexMono", size: 12))
                    .foregroundColor(Color(hex: "#EEEEEE"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Rectangle()
                            .fill(Color(hex: "#222222"))
                    )
                    .overlay(
                        GeometryReader { geometry in
                            Path { path in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                
                                // Draw left and bottom as a single continuous path
                                path.move(to: CGPoint(x: 0, y: 0))
                                path.addLine(to: CGPoint(x: 0, y: height))
                                path.addLine(to: CGPoint(x: width, y: height))
                            }
                            .stroke(Color(hex: "#444444"), lineWidth: 1)
                        }
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

#Preview {
    HistoryView(
        showingTextModal: .constant(false),
        mainViewModel: MainViewModel()
    )
} 