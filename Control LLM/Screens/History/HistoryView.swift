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
                LazyVStack(spacing: 60) { // 60px between year groupings
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
                        HStack(spacing: 8) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                            
                            Text("History")
                                .font(.custom("IBMPlexMono", size: 20))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                        }
                        .padding(.leading, 20)
                        
                        Spacer()

                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 20)
                    }
                    
                    // Buffer space below header
                    Spacer()
                        .frame(height: 18)
                }
                .background(Color(hex: "#1D1D1D"))
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
        
        // 4. Trigger the activation sequence after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // This will trigger the visualizer activation and text fade-out
            // The MainViewModel.isActivated = true will be picked up by MainView
        }
    }
}

struct HistoryGroupView: View {
    let group: HistoryGroup
    let onChatSelected: (ChatHistoryEntry) -> Void
    
    var body: some View {
        // Date entries with 44px spacing between date groupings
        VStack(spacing: 44) {
            ForEach(group.entries) { entry in
                HistoryEntryView(entry: entry, onTap: onChatSelected)
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
                    .font(.custom("IBMPlexMono", size: 12))
                    .foregroundColor(ColorManager.shared.orangeColor)
                Spacer()
            }
            
            // 20px spacing from date to first chat summary
            Spacer()
                .frame(height: 20)
            
            // Chat entries
            VStack(spacing: 20) { // 20px between groups of text
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
        VStack(spacing: 0) {
                // 1px line above summary
                Rectangle()
                    .fill(Color(hex: "#333333"))
                    .frame(height: 1)
                
                // 4px spacing under the line
                Spacer()
                    .frame(height: 4)
                
                // Main summary headline (clickable) - full row is tappable
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(chat.summary)
                                .font(.custom("IBMPlexMono", size: 16))
                                .foregroundColor(Color(hex: "#EEEEEE"))
                                .lineLimit(2) // Max 2 lines
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal, 0)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8) // Add vertical padding to match Whisper spacing
                            
                            // Timestamp
                            Text(chat.timestamp)
                                .font(.custom("IBMPlexMono", size: 10))
                                .foregroundColor(ColorManager.shared.redColor)
                                .padding(.horizontal, 0)
                        }
                        
                        // Arrow indicator
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .padding(.trailing, 8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle()) // Make entire area tappable
                }
                .buttonStyle(PlainButtonStyle())
                
                // Expanded content with proper masking
                if isExpanded {
                    VStack(spacing: 10) { // 10px between expanded summaries
                        ForEach(Array(chat.expandedSummaries.prefix(1))) { expandedSummary in
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
            .clipped() // Ensure expanded content doesn't overflow
            .zIndex(isExpanded ? 1 : 0) // Ensure expanded content appears above other items
        }
    }

struct ExpandedSummaryView: View {
    let summary: ExpandedSummary
    let onContinueChat: () -> Void
    
    var body: some View {
        // Expanded summary content (no separate vertical line needed)
        VStack(spacing: 16) { // 16px between summary text and button (doubled from 8px)
                Text(summary.content)
                .font(.custom("IBMPlexMono", size: 14))
                .foregroundColor(ColorManager.shared.orangeColor)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Continue Chat button
                Button(action: onContinueChat) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                            .foregroundColor(ColorManager.shared.purpleColor)
                    
                    Text(summary.buttonText)
                        .font(.custom("IBMPlexMono", size: 16))
                            .foregroundColor(ColorManager.shared.purpleColor)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    HistoryView(
        showingTextModal: .constant(false),
        mainViewModel: MainViewModel()
    )
} 