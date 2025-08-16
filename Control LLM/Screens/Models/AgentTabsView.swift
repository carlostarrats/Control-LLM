import SwiftUI

struct AgentTabsView: View {
    @ObservedObject var viewModel: ModelsViewModel
    
    var body: some View {
        VStack {
            // Tab selector
            Picker("Content Type", selection: $viewModel.selectedTab) {
                Text("Models").tag(0)
                Text("Agents").tag(1)
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
        List {
            ForEach(viewModel.availableModels) { model in
                ModelRow(
                    model: model,
                    isSelected: viewModel.selectedModel?.id == model.id
                ) {
                    viewModel.selectModel(model)
                }
            }
        }
        .listStyle(.plain)
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
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(model.name)
                            .font(.headline)
                        Text("•")
                        Text(model.provider)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
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
                        Text("Available")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundColor(.blue)
                }
                
                if !model.isAvailable {
                    Text("Unavailable")
                        .font(.caption)
                        .foregroundColor(.red)
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
                            Text("• Active")
                                .font(.caption)
                                .foregroundColor(ColorManager.shared.greenColor)
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
                            Text("No Model Assigned")
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