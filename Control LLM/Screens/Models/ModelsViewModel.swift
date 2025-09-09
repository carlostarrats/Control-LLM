import Foundation
import SwiftUI
import Combine

@MainActor
class ModelsViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var availableModels: [LLMModelInfo] = []
    @Published var customAgents: [Agent] = []
    @Published var selectedModel: LLMModelInfo?
    @Published var selectedAgent: Agent?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        // Connect to the actual ModelManager first
        setupModelManagerConnection()
        // Load agents after connection is established and models are available
        DispatchQueue.main.async { [weak self] in
            self?.loadSampleAgents()
        }
    }
    
    private func setupModelManagerConnection() {
        // Get initial models from ModelManager
        self.availableModels = ModelManager.shared.availableModels
        self.selectedModel = ModelManager.shared.selectedModel
        
        // Listen for model changes
        NotificationCenter.default.publisher(for: .modelDidChange)
            .sink { [weak self] notification in
                if let newModel = notification.object as? LLMModelInfo {
                    self?.selectedModel = newModel
                    // Update agents when model changes
                    self?.updateAgentsWithNewModel(newModel)
                }
            }
            .store(in: &cancellables)
        
        // Listen for available models changes
        ModelManager.shared.$availableModels
            .assign(to: \.availableModels, on: self)
            .store(in: &cancellables)
        
        // Listen for selected model changes
        ModelManager.shared.$selectedModel
            .sink { [weak self] newModel in
                self?.selectedModel = newModel
                // Update agents when selected model changes (including from nil to real model)
                if let model = newModel {
                    self?.updateAgentsWithNewModel(model)
                }
            }
            .store(in: &cancellables)
        
        // If we already have a selected model, update agents immediately
        if let currentModel = self.selectedModel {
            updateAgentsWithNewModel(currentModel)
        }
    }
    
    private func loadSampleAgents() {
        // Sample custom agents - start with no model, will be updated when model is available
        customAgents = [
            Agent(
                id: UUID(),
                name: "Code Assistant",
                description: "Specialized in programming and code review",
                systemPrompt: "You are a helpful programming assistant specialized in analyzing code and providing technical guidance. When asked to analyze text (especially clipboard content), provide clear, focused analysis that extracts key information, identifies themes, and offers objective insights. Keep responses concise and directly relevant to the content provided.",
                model: nil, // Will be updated when model is available
                isActive: true
            ),
            Agent(
                id: UUID(),
                name: "Writing Coach",
                description: "Helps with writing and content creation",
                systemPrompt: "You are a writing coach who helps improve writing quality and content analysis. When asked to analyze text (especially clipboard content), provide clear, focused analysis that extracts key information, identifies themes, and offers objective insights. Keep responses concise and directly relevant to the content provided.",
                model: nil, // Will be updated when model is available
                isActive: false
            ),
            Agent(
                id: UUID(),
                name: "Data Analyst",
                description: "Specialized in data analysis and insights",
                systemPrompt: "You are a data analyst who helps extract insights from information. When asked to analyze text (especially clipboard content), provide clear, focused analysis that extracts key information, identifies themes, and offers objective insights. Keep responses concise and directly relevant to the content provided.",
                model: nil, // Will be updated when model is available
                isActive: true
            )
        ]
        
        selectedAgent = customAgents[0]
        
        // If we already have a selected model, update agents immediately
        if let currentModel = selectedModel {
            updateAgentsWithNewModel(currentModel)
        } else {
            // If no model is available yet, set up a timer to check again
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                if let currentModel = self?.selectedModel {
                    self?.updateAgentsWithNewModel(currentModel)
                }
            }
        }
    }
    
    func selectModel(_ model: LLMModelInfo) {
        
        // Use the actual ModelManager to select the model
        ModelManager.shared.selectModel(model)
        
        // Update agents to use the new model
        updateAgentsWithNewModel(model)
    }
    
    private func updateAgentsWithNewModel(_ model: LLMModelInfo) {
        for i in 0..<customAgents.count {
            customAgents[i].model = model
        }
        
        // If we have a selected agent, update it too
        if let selectedAgent = selectedAgent,
           let index = customAgents.firstIndex(where: { $0.id == selectedAgent.id }) {
            self.selectedAgent = customAgents[index]
        }
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
    
    // MARK: - Cleanup
    
    deinit {
        // Cancel all Combine subscriptions to prevent memory leaks
        cancellables.removeAll()
    }
}

struct Agent: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let systemPrompt: String
    var model: LLMModelInfo? // Now uses LLMModelInfo instead of AIModel
    var isActive: Bool
} 