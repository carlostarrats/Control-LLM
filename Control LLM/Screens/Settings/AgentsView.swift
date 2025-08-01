import SwiftUI

struct AgentsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAgents: Set<String> = ["Assistant"] // Default selection
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 8) {
                    // Agents list
                    VStack(spacing: 0) {
                        ForEach(agents, id: \.name) { agent in
                            AgentItemView(
                                agent: agent,
                                isSelected: selectedAgents.contains(agent.name),
                                onToggle: {
                                    if selectedAgents.contains(agent.name) {
                                        selectedAgents.remove(agent.name)
                                    } else {
                                        selectedAgents.insert(agent.name)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
            .safeAreaInset(edge: .top) {
                // Header
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
                            Image(systemName: "square.3.layers.3d")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                            
                            Text("Agents")
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
                    .padding(.bottom, 20)
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
    }
    
    private var agents: [AgentItem] {
        [
            AgentItem(name: "Assistant"),
            AgentItem(name: "Coder"),
            AgentItem(name: "Writer"),
            AgentItem(name: "Analyst"),
            AgentItem(name: "Creative")
        ]
    }
}

struct AgentItem: Identifiable {
    let id = UUID()
    let name: String
}

struct AgentItemView: View {
    let agent: AgentItem
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Text(agent.name)
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(Color(hex: "#EEEEEE"))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    // Circular checkmark button
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            
            // Horizontal line under the item
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(height: 1)
        }
    }
} 