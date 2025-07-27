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
        // Sample AI models
        availableModels = [
            AIModel(
                id: UUID(),
                name: "GPT-4",
                provider: "OpenAI",
                description: "Most capable GPT model for complex reasoning",
                isAvailable: true,
                maxTokens: 8192,
                costPerToken: 0.00003
            ),
            AIModel(
                id: UUID(),
                name: "GPT-3.5 Turbo",
                provider: "OpenAI",
                description: "Fast and efficient for most tasks",
                isAvailable: true,
                maxTokens: 4096,
                costPerToken: 0.000002
            ),
            AIModel(
                id: UUID(),
                name: "Claude-3 Opus",
                provider: "Anthropic",
                description: "Advanced reasoning and analysis",
                isAvailable: true,
                maxTokens: 200000,
                costPerToken: 0.000015
            ),
            AIModel(
                id: UUID(),
                name: "Claude-3 Sonnet",
                provider: "Anthropic",
                description: "Balanced performance and cost",
                isAvailable: true,
                maxTokens: 200000,
                costPerToken: 0.000003
            )
        ]
        
        // Sample custom agents
        customAgents = [
            Agent(
                id: UUID(),
                name: "Code Assistant",
                description: "Specialized in programming and code review",
                systemPrompt: "You are a helpful programming assistant...",
                model: availableModels[0],
                isActive: true
            ),
            Agent(
                id: UUID(),
                name: "Writing Coach",
                description: "Helps with writing and content creation",
                systemPrompt: "You are a writing coach who helps...",
                model: availableModels[1],
                isActive: false
            ),
            Agent(
                id: UUID(),
                name: "Data Analyst",
                description: "Specialized in data analysis and insights",
                systemPrompt: "You are a data analyst who helps...",
                model: availableModels[2],
                isActive: true
            )
        ]
        
        selectedModel = availableModels[0]
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
    let model: AIModel
    var isActive: Bool
} 