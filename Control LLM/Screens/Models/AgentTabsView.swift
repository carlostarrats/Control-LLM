import SwiftUI

struct AgentTabsView: View {
    @ObservedObject var viewModel: ModelsViewModel
    
    var body: some View {
        VStack {
            // Tab selector
            Picker("Content Type", selection: $viewModel.selectedTab) {
                Text(NSLocalizedString("Models", comment: "")).tag(0)
                Text(NSLocalizedString("Agents", comment: "")).tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Tab content
            TabView(selection: $viewModel.selectedTab) {
                ModelsTab(viewModel: viewModel)
                    .tag(0)
                
                AgentsTab(viewModel: viewModel)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

struct ModelsTab: View {
    @ObservedObject var viewModel: ModelsViewModel
    
    var body: some View {
        ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.availableModels) { model in
                        ModelRow(
                            model: model,
                            isSelected: viewModel.selectedModel?.id == model.id
                        ) {
                            viewModel.selectModel(model)
                        }
                    }
                }
                .padding()
        }
    }
}

struct AgentsTab: View {
    @ObservedObject var viewModel: ModelsViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.customAgents) { agent in
                AgentRow(
                    agent: agent,
                    isSelected: viewModel.selectedAgent?.id == agent.id
                ) {
                    viewModel.selectAgent(agent)
                }
                .swipeActions {
                    Button(agent.isActive ? "Deactivate" : "Activate") {
                        viewModel.toggleAgent(agent)
                    }
                    .tint(agent.isActive ? ColorManager.shared.orangeColor : ColorManager.shared.greenColor)
                    
                    Button("Delete", role: .destructive) {
                        viewModel.deleteAgent(agent)
                    }
                }
            }
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add Agent") {
                    // TODO: Show add agent sheet
                }
            }
        }
    }
}

struct ModelRow: View {
    let model: LLMModelInfo
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(model.name)
                            .font(.headline)
                        Text("•")
                        Text(model.provider)
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "#BBBBBB"))
                    }
                    
                    Text(model.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(model.size)
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("•")
                        Text(NSLocalizedString("Available", comment: ""))
                            .font(.custom("IBMPlexMono", size: 10))
                            .foregroundColor(Color(hex: "#00FF00"))
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundColor(.blue)
                }
                
                if !model.isAvailable {
                    Text(NSLocalizedString("Unavailable", comment: ""))
                        .font(.custom("IBMPlexMono", size: 10))
                        .foregroundColor(Color(hex: "#FF0000"))
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}

struct AgentRow: View {
    let agent: Agent
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(agent.name)
                            .font(.headline)
                        if agent.isActive {
                            Text("• " + NSLocalizedString("Active", comment: ""))
                                .font(.custom("IBMPlexMono", size: 10))
                                .foregroundColor(Color(hex: "#00FF00"))
                        }
                    }
                    
                    Text(agent.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        if let model = agent.model {
                            Text("Model: \(model.name)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        } else {
                            Text(NSLocalizedString("No Model Assigned", comment: ""))
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
    }
}

#Preview {
    AgentTabsView(viewModel: ModelsViewModel())
} 