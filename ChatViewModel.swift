import Foundation
import SwiftUI

@Observable
class ChatViewModel {
    var transcript: String = ""
    var isProcessing: Bool = false
    var modelLoaded: Bool = false
    var lastLoadedModel: String? = nil
    var lastSentMessage: String? = nil
    var messageHistory: [ChatMessage]? = []
    
    // Add cancellation support
    private var currentGenerationTask: Task<Void, Never>?
    
    private var modelChangeObserver: NSObjectProtocol?
    private var updateTimer: Timer?
    private var cleanupTimer: Timer?
    
    init() {
        print("🔍 ChatViewModel: init")
        setupModelChangeObserver()
        setupCleanupTimer()
    }
    
    deinit {
        // Clean up notification observer
        if let observer = modelChangeObserver {
            NotificationCenter.default.removeObserver(observer)
            modelChangeObserver = nil
        }
        // Clean up timers
        updateTimer?.invalidate()
        cleanupTimer?.invalidate()
    }
    
    private func setupModelChangeObserver() {
        // FIXED: Listen for the correct notification name that ModelManager posts
        modelChangeObserver = NotificationCenter.default.addObserver(
            forName: .modelDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleModelChange()
        }
    }
    
    private func handleModelChange() {
        print("🔍 ChatViewModel: handleModelChange called")
        
        // OPTIMIZATION: Use async/await for better performance
        Task { [weak self] in
            guard let self = self else { return }
            
            // OPTIMIZATION: Clear UI state immediately for better responsiveness
            await MainActor.run {
                self.transcript = ""
                self.modelLoaded = false
                self.lastLoadedModel = nil
            }
            
            // Clear duplicate message state to allow re-sending
            self.clearDuplicateMessageState()
            
            // OPTIMIZATION: Parallel unload and model preparation for faster switching
            do {
                print("🔍 ChatViewModel: Starting parallel model switch...")
                try await withThrowingTaskGroup(of: Void.self) { group in
                    group.addTask { try await HybridLLMService.shared.forceUnloadModel() }
                    group.addTask { try await self.ensureModel() }
                    try await group.waitForAll()
                }
                print("🔍 ChatViewModel: Model switch completed successfully")
            } catch {
                print("❌ ChatViewModel: Error during model switch: \(error)")
                await MainActor.run {
                    self.modelLoaded = false
                }
            }
        }
    }
    
    func send(_ userText: String) async throws {
        print("🔍 ChatViewModel: send started — \(userText)")

        // Prevent duplicate submissions
        let isDuplicate = userText == lastSentMessage && lastLoadedModel != nil
        if isDuplicate {
            print("🔍 ChatViewModel: Duplicate message detected, ignoring")
            return
        }
        lastSentMessage = userText

        // Cancel any existing generation task
        currentGenerationTask?.cancel()
        
        // Create new cancellable task for generation
        currentGenerationTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                await MainActor.run {
                    self.isProcessing = true
                    self.transcript = ""
                }
                
                // Load model and prepare history
                let historyToSend = buildSafeHistory(from: messageHistory ?? [])
                try await HybridLLMService.shared.loadSelectedModel()

                // Use the HybridLLMService to generate the response
                try await HybridLLMService.shared.generateResponse(
                    userText: userText,
                    history: historyToSend,
                    onToken: { [weak self] partialResponse in
                        Task { @MainActor in
                            // Check if task was cancelled
                            if Task.isCancelled { return }
                            self?.transcript += partialResponse
                        }
                    }
                )
                
                // Only update state if not cancelled
                if !Task.isCancelled {
                    await MainActor.run {
                        self.isProcessing = false
                    }
                }
                
            } catch {
                // Only update state if not cancelled
                if !Task.isCancelled {
                    await MainActor.run {
                        print("❌ ChatViewModel: Error in send: \(error)")
                        self.isProcessing = false
                        
                        // Provide more user-friendly error messages for common cases
                        let errorMessage: String
                        if let nsError = error as NSError? {
                            switch nsError.code {
                            case 26: // Input too long
                                errorMessage = "Your message was shortened to fit within limits. If the shortened version doesn't accurately represent what you wanted to say, please try a shorter message."
                            case 27: // Token limit reached
                                errorMessage = "The response was cut off because it reached the maximum length limit. Try asking a more specific question or breaking your request into smaller parts."
                            case 6: // Prompt too long
                                errorMessage = "Your message is too long. Please shorten it and try again."
                            default:
                                errorMessage = "Error: \(error.localizedDescription)"
                            }
                        } else {
                            errorMessage = "Error: \(error.localizedDescription)"
                        }
                        
                        self.transcript = errorMessage
                    }
                }
            }
        }
        
        // Wait for the task to complete or be cancelled
        await currentGenerationTask?.value
    }
    
    // MARK: - History Safeguard
    private func buildSafeHistory(from fullHistory: [ChatMessage]) -> [ChatMessage] {
        // Limits to prevent overwhelming the prompt
        let maxMessages = 20
        let maxCharacters = 4000

        // Take the most recent messages up to maxMessages
        var trimmed = Array(fullHistory.suffix(maxMessages))

        // If still too long, trim from the oldest in this window until below character cap
        func totalChars(_ msgs: [ChatMessage]) -> Int {
            msgs.reduce(0) { $0 + $1.content.count }
        }

        while totalChars(trimmed) > maxCharacters && !trimmed.isEmpty {
            trimmed.removeFirst()
        }

        return trimmed
    }
    
    func clearConversation() {
        DispatchQueue.main.async {
            self.transcript = ""
            self.messageHistory = []
            self.lastSentMessage = nil
            print("🔍 ChatViewModel: Conversation cleared")
        }
    }
    
    func clearDuplicateMessageState() {
        DispatchQueue.main.async {
            self.lastSentMessage = nil
            print("🔍 ChatViewModel: Duplicate message state cleared")
        }
    }
    
    func ensureModel() async throws {
        print("🔍 ChatViewModel: ensureModel called")

        // Use the HybridLLMService to manage model state
        if !(await HybridLLMService.shared.isModelLoaded) {
            print("🔍 ChatViewModel: Model not loaded, loading selected model via Hybrid Service")
            try await HybridLLMService.shared.loadSelectedModel()
        } else {
            let engineInfo = await HybridLLMService.shared.getCurrentEngineInfo()
            print("🔍 ChatViewModel: Model already loaded: \(engineInfo)")
        }
        
        // Sync local state for UI purposes by fetching async properties first
        let isLoaded = await HybridLLMService.shared.isModelLoaded
        let filename = await HybridLLMService.shared.currentModelFilename
        
        await MainActor.run {
            self.modelLoaded = isLoaded
            self.lastLoadedModel = filename
        }
    }
    
    // MARK: - Memory Fade Management
    
    private func setupCleanupTimer() {
        // Run cleanup every hour to remove old messages
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.cleanupOldMessages()
        }
    }
    
    private func cleanupOldMessages() {
        let calendar = Calendar.current
        let now = Date()
        let cutoffDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        
        // Remove messages older than 7 days
        messageHistory = messageHistory?.filter { message in
            message.timestamp > cutoffDate
        }
        
        print("🔍 ChatViewModel: Cleaned up messages older than 7 days")
    }
    
    func calculateMessageOpacity(for message: ChatMessage) -> Double {
        let calendar = Calendar.current
        let now = Date()
        let daysDifference = calendar.dateComponents([.day], from: message.timestamp, to: now).day ?? 0
        
        // Apply opacity fade based on message age
        switch daysDifference {
        case 0: return 1.0      // Today: 100% opacity
        case 1: return 0.9      // Yesterday: 90% opacity
        case 2: return 0.8      // Day 2: 80% opacity
        case 3: return 0.7      // Day 3: 70% opacity
        case 4: return 0.6      // Day 4: 60% opacity
        case 5: return 0.5      // Day 5: 50% opacity
        case 6: return 0.4      // Day 6: 40% opacity
        default: return 0.0     // Day 7+: 0% opacity (will be deleted)
        }
    }
    
    func getMessagesGroupedByDate() -> [(Date, [ChatMessage])] {
        guard let messages = messageHistory, !messages.isEmpty else { return [] }
        
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: messages) { message in
            calendar.startOfDay(for: message.timestamp)
        }
        
        // Sort by date (oldest first) and filter out empty groups
        var result: [(Date, [ChatMessage])] = []
        for (date, messages) in grouped {
            if !messages.isEmpty {
                let sortedMessages = messages.sorted { $0.timestamp < $1.timestamp }
                result.append((date, sortedMessages))
            }
        }
        return result.sorted { $0.0 < $1.0 }
    }
    
    // MARK: - Cancellation Support
    
    @MainActor
    func stopGeneration() {
        print("🔍 ChatViewModel: Stopping generation")
        currentGenerationTask?.cancel()
        currentGenerationTask = nil
        
        // Also stop the HybridLLMService generation
        HybridLLMService.shared.stopGeneration()
        
        self.isProcessing = false
    }
}