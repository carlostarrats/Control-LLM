import Foundation
import SwiftUI

// MARK: - Error Types

enum ChatViewModelError: Error, LocalizedError {
    case modelSwitchInProgress
    
    var errorDescription: String? {
        switch self {
        case .modelSwitchInProgress:
            return "Model switch in progress. Please wait a moment before sending your message."
        }
    }
}

@Observable
class ChatViewModel {
    // MARK: - Model Management
    
    var modelLoaded = false
    var lastLoadedModel: String?
    var isProcessing = false
    var transcript = ""
    
    // FIXED: Add flag to prevent messages during model switch
    var isModelSwitching = false
    
    // MARK: - Message Management
    
    var lastSentMessage: String?
    var messageHistory: [ChatMessage]?
    
    // MARK: - Notification Management
    
    private var modelChangeObserver: NSObjectProtocol?
    private var updateTimer: Timer?
    
    private var currentGenerationTask: Task<Void, Never>?
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
        print("🔍 ChatViewModel: Current messageHistory count: \(messageHistory?.count ?? 0)")
        
        // FIXED: Set model switching flag to prevent new messages
        isModelSwitching = true
        
        // OPTIMIZATION: Use async/await for better performance
        Task { [weak self] in
            guard let self = self else { return }
            
            // OPTIMIZATION: Clear UI state immediately for better responsiveness
            await MainActor.run {
                self.transcript = ""
                self.modelLoaded = false
                self.lastLoadedModel = nil
                self.isProcessing = false  // CRITICAL FIX: Reset processing state
            }
            
            // Clear duplicate message state to allow re-sending
            self.clearDuplicateMessageState()
            
            // CRITICAL FIX: DO NOT clear messageHistory during model switch
            // This preserves conversation context across model changes
            print("🔍 ChatViewModel: Preserving messageHistory during model switch: \(self.messageHistory?.count ?? 0) messages")
            
            // FIXED: Ensure proper sequencing - unload first, then load new model
            do {
                print("🔍 ChatViewModel: Starting sequential model switch...")
                
                // Step 1: Unload current model
                print("🔍 ChatViewModel: Step 1 - Unloading current model")
                try await HybridLLMService.shared.forceUnloadModel()
                
                // Step 2: Load new model
                print("🔍 ChatViewModel: Step 2 - Loading new model")
                try await self.ensureModel()
                
                // Step 3: Verify model is ready
                print("🔍 ChatViewModel: Step 3 - Verifying model readiness")
                let isReady = await HybridLLMService.shared.isModelLoaded
                let modelName = await HybridLLMService.shared.currentModelFilename
                
                await MainActor.run {
                    self.modelLoaded = isReady
                    self.lastLoadedModel = modelName
                }
                
                // FIXED: Add delay to ensure model is fully ready
                print("🔍 ChatViewModel: Step 4 - Waiting for model to stabilize")
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                print("🔍 ChatViewModel: Model switch completed successfully")
                print("🔍 ChatViewModel: New model: \(modelName ?? "unknown")")
                print("🔍 ChatViewModel: Model loaded: \(isReady)")
                print("🔍 ChatViewModel: After model switch, messageHistory count: \(self.messageHistory?.count ?? 0)")
                
                // Step 5: Verify history is intact
                if let history = self.messageHistory {
                    print("🔍 ChatViewModel: Final history verification:")
                    for (index, message) in history.enumerated() {
                        print("   [\(index)] \(message.isUser ? "User" : "Assistant"): \(message.content.prefix(100))...")
                    }
                }
                
                // FIXED: Clear model switching flag to allow new messages
                await MainActor.run {
                    self.isModelSwitching = false
                }
                print("🔍 ChatViewModel: Model switch complete - ready for new messages")
                
            } catch {
                print("❌ ChatViewModel: Error during model switch: \(error)")
                await MainActor.run {
                    self.modelLoaded = false
                    self.isModelSwitching = false
                }
            }
        }
    }
    
    func send(_ userText: String) async throws {
        print("🔍🔍🔍 ChatViewModel: send started — \(userText.prefix(100))...")
        print("🔍 ChatViewModel: Current isProcessing: \(isProcessing)")
        print("🔍 ChatViewModel: Current transcript: '\(transcript)'")
        print("🔍 ChatViewModel: Current lastSentMessage: '\(lastSentMessage ?? "nil")'")
        print("🔍 ChatViewModel: Current lastLoadedModel: '\(lastLoadedModel ?? "nil")'")
        print("🔍 ChatViewModel: Current isModelSwitching: \(isModelSwitching)")

        // FIXED: Prevent messages during model switch
        if isModelSwitching {
            print("🔍 ChatViewModel: ❌ Model switch in progress, rejecting message")
            throw ChatViewModelError.modelSwitchInProgress
        }

        // Special handling for clipboard messages - they should never be considered duplicates
        let isClipboardMessageFormat = userText.hasPrefix("Analyze this text (keep under 8000 tokens):")
        
        if isClipboardMessageFormat {
            // Clipboard messages are never duplicates - they always have different content
            print("🔍 ChatViewModel: ✅ CLIPBOARD MESSAGE DETECTED - bypassing duplicate check")
        } else {
            // Normal duplicate detection for regular messages
            let isDuplicate = userText == lastSentMessage && lastLoadedModel != nil
            print("🔍 ChatViewModel: Regular message - isDuplicate: \(isDuplicate)")
            if isDuplicate {
                print("🔍 ChatViewModel: ❌ Duplicate message detected, ignoring and returning")
                return
            }
        }
        
        print("🔍 ChatViewModel: ✅ Message passed duplicate check, proceeding...")
        lastSentMessage = userText

        // CRITICAL FIX: Add user message to history BEFORE sending to LLM
        let userMessage = ChatMessage(content: userText, isUser: true, timestamp: Date())
        if messageHistory == nil {
            messageHistory = []
        }
        messageHistory?.append(userMessage)
        print("🔍 ChatViewModel: Added user message to history. Total messages: \(messageHistory?.count ?? 0)")

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
                print("🔍 ChatViewModel: About to build history from messageHistory: \(messageHistory?.count ?? 0) messages")
                
                // CRITICAL FIX: Build history from ALL messages (excluding current user message to avoid duplication)
                // The current user message will be passed separately as userText
                let currentHistory = messageHistory ?? []
                
                // Only remove the last message if we have more than 1 message (to avoid removing everything)
                let historyWithoutCurrentMessage: [ChatMessage]
                if currentHistory.count > 1 {
                    historyWithoutCurrentMessage = Array(currentHistory.dropLast()) // Remove the just-added user message
                } else {
                    historyWithoutCurrentMessage = [] // No previous history, just current message
                }
                
                let historyToSend = buildSafeHistory(from: historyWithoutCurrentMessage)
                
                print("🔍 ChatViewModel: History prepared, sending \(historyToSend.count) messages to LLM")
                print("🔍 ChatViewModel: Current user message: '\(userText.prefix(100))...'")
                print("🔍 ChatViewModel: Full history being sent:")
                for (index, message) in historyToSend.enumerated() {
                    print("   [\(index)] \(message.isUser ? "User" : "Assistant"): \(message.content.prefix(100))...")
                }
                
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
                
                // CRITICAL FIX: Add assistant response to history AFTER completion
                if !Task.isCancelled {
                    await MainActor.run {
                        let assistantMessage = ChatMessage(content: self.transcript, isUser: false, timestamp: Date())
                        self.messageHistory?.append(assistantMessage)
                        print("🔍 ChatViewModel: Added assistant response to history. Total messages: \(self.messageHistory?.count ?? 0)")
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
        print("🔍 ChatViewModel: buildSafeHistory called with \(fullHistory.count) messages")
        print("🔍 ChatViewModel: Full history content:")
        for (index, message) in fullHistory.enumerated() {
            print("   [\(index)] \(message.isUser ? "User" : "Assistant"): \(message.content.prefix(100))...")
        }
        
        // FIXED: More reasonable limits that preserve conversation context
        let maxMessages = 8  // Keep last 8 messages (4 exchanges) for better context
        let maxCharacters = 3400  // Increased to allow more context retention

        // Take the most recent messages up to maxMessages
        var trimmed = Array(fullHistory.suffix(maxMessages))
        print("🔍 ChatViewModel: After maxMessages trim: \(trimmed.count) messages")

        // If still too long, trim from the oldest in this window until below character cap
        func totalChars(_ msgs: [ChatMessage]) -> Int {
            msgs.reduce(0) { $0 + $1.content.count }
        }

        let initialChars = totalChars(trimmed)
        print("🔍 ChatViewModel: Initial character count: \(initialChars)")

        while totalChars(trimmed) > maxCharacters && !trimmed.isEmpty {
            trimmed.removeFirst()
        }

        let finalChars = totalChars(trimmed)
        print("🔍 ChatViewModel: Final result: \(trimmed.count) messages, \(finalChars) characters")
        print("🔍 ChatViewModel: Final history content:")
        for (index, message) in trimmed.enumerated() {
            print("   [\(index)] \(message.isUser ? "User" : "Assistant"): \(message.content.prefix(100))...")
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