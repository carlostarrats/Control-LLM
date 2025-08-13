import Foundation

@MainActor
class ModelsViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var availableModels: [AIModel] = []
    @Published var customAgents: [Agent] = []
    @Published var selectedModel: AIModel?
    @Published var selectedAgent: Agent?
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        // Sample AI models - REMOVED hardcoded models
        availableModels = []
        
        // Sample custom agents
        customAgents = [
            Agent(
                id: UUID(),
                name: "Code Assistant",
                description: "Specialized in programming and code review",
                systemPrompt: "You are a helpful programming assistant...",
                model: nil, // No model since we removed hardcoded ones
                isActive: true
            ),
            Agent(
                id: UUID(),
                name: "Writing Coach",
                description: "Helps with writing and content creation",
                systemPrompt: "You are a writing coach who helps...",
                model: nil, // No model since we removed hardcoded ones
                isActive: false
            ),
            Agent(
                id: UUID(),
                name: "Data Analyst",
                description: "Specialized in data analysis and insights",
                systemPrompt: "You are a data analyst who helps...",
                model: nil, // No model since we removed hardcoded ones
                isActive: true
            )
        ]
        
        selectedModel = nil // No model selected since we removed hardcoded ones
        selectedAgent = customAgents[0]
    }
    
    func selectModel(_ model: AIModel) {
        selectedModel = model
    }
    
    func selectAgent(_ agent: Agent) {
        selectedAgent = agent
    }
    
    func toggleAgent(_ agent: Agent) {
        if let index = customAgents.firstIndex(where: { $0.id == agent.id }) {
            customAgents[index].isActive.toggle()
        }
    }
    
    func addAgent(_ agent: Agent) {
        customAgents.append(agent)
    }
    
    func deleteAgent(_ agent: Agent) {
        customAgents.removeAll { $0.id == agent.id }
    }
}

struct AIModel: Identifiable {
    let id: UUID
    let name: String
    let provider: String
    let description: String
    let isAvailable: Bool
    let maxTokens: Int
    let costPerToken: Double
}

struct Agent: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let systemPrompt: String
    let model: AIModel? // Made optional as models are removed
    var isActive: Bool
} 