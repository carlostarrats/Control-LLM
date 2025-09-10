import Foundation
import SwiftUI

// MARK: - Model Performance Data

struct ModelPerformanceData: Codable {
    var averageResponseTime: TimeInterval = 0.0
    var responseCount: Int = 0
    var totalResponseTime: TimeInterval = 0.0
    var isFastModel: Bool = false
    var lastUpdated: Date = Date()
    
    mutating func updateResponseTime(_ responseTime: TimeInterval) {
        totalResponseTime += responseTime
        responseCount += 1
        averageResponseTime = totalResponseTime / Double(responseCount)
        
        // Mark as fast if average response time is under 3 seconds
        isFastModel = averageResponseTime < 3.0
        
        lastUpdated = Date()
    }
}

// MARK: - Error Types

enum ChatViewModelError: Error, LocalizedError {
    case modelSwitchInProgress
    
    var errorDescription: String? {
        switch self {
        case .modelSwitchInProgress:
            return NSLocalizedString("Model switch in progress. Please wait a moment before sending your message.", comment: "")
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
    
    // Response timing for latency calculation
    var lastResponseTime: Date = Date()
    var averageResponseDuration: TimeInterval = 0.0 // Average response time in seconds
    private var requestStartTime: Date?
    private var totalResponseTime: TimeInterval = 0.0
    private var responseCount: Int = 0
    
    // Model-specific performance tracking
    private var modelPerformanceData: [String: ModelPerformanceData] = [:]
    
    // MARK: - Message Management
    
    var lastSentMessage: String?
    var messageHistory: [ChatMessage]?
    
    // MARK: - Session Management
    
    private var appOpenTime: Date = Date()
    private let sessionDurationKey = "AppSessionStartTime"
    
    // MARK: - Notification Management
    
    private var modelChangeObserver: NSObjectProtocol?
    private var updateTimer: Timer?
    
    private var currentGenerationTask: Task<Void, Never>?
    
    init() {
        debugPrint("ChatViewModel: init", category: .general)
        initializeSession()
        
        // CRITICAL FIX: Ensure processing state is clean on startup
        isProcessing = false
        // transcript = "" // REMOVED: Don't clear transcript on startup
        
        // Load saved timing data from secure storage
        let savedAverage = SecureStorage.retrieveDouble(forKey: "AverageResponseTime") ?? 0.0
        let savedTotalTime = SecureStorage.retrieveDouble(forKey: "TotalResponseTime") ?? 0.0
        let savedResponseCount = SecureStorage.retrieveInt(forKey: "ResponseCount") ?? 0
        
        if savedAverage > 0 {
            self.averageResponseDuration = savedAverage
            self.totalResponseTime = savedTotalTime
            self.responseCount = savedResponseCount
            SecureLogger.log("Loaded saved timing data - avg: \(savedAverage)s, total: \(savedTotalTime)s, count: \(savedResponseCount)")
        }
        
        // Load model-specific performance data
        loadModelPerformanceData()
        
        setupModelChangeObserver()
        
        // CRITICAL FIX: Check initial model state on startup
        Task {
            await syncModelState()
        }
    }
    
    deinit {
        // Clean up notification observer
        if let observer = modelChangeObserver {
            NotificationCenter.default.removeObserver(observer)
            modelChangeObserver = nil
        }
        // Clean up timers
        updateTimer?.invalidate()
        // PERFORMANCE FIX: Cancel any ongoing generation tasks
        currentGenerationTask?.cancel()
        currentGenerationTask = nil
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
        
        // Listen for data cleanup notifications
        NotificationCenter.default.addObserver(
            forName: .clearAllConversationData,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.clearAllConversationData()
        }
    }
    
    private func handleModelChange() {
        
        // FIXED: Set model switching flag to prevent new messages
        isModelSwitching = true
        
        // OPTIMIZATION: Use async/await for better performance
        Task { [weak self] in
            guard let self = self else { return }
            
            // OPTIMIZATION: Clear UI state immediately for better responsiveness
            await MainActor.run {
                // self.transcript = "" // REMOVED: Don't clear transcript during model switch
                self.modelLoaded = false
                self.lastLoadedModel = nil
                self.isProcessing = false  // CRITICAL FIX: Reset processing state
            }
            
            // Clear duplicate message state to allow re-sending
            self.clearDuplicateMessageState()
            
            // CRITICAL FIX: DO NOT clear messageHistory during model switch
            // This preserves conversation context across model changes
            
            // FIXED: Ensure proper sequencing - unload first, then load new model
            do {
                // Step 1: Unload current model
                try await HybridLLMService.shared.forceUnloadModel()
                
                // Step 2: Load new model
                try await self.ensureModel()
                
                // Step 3: Verify model is ready
                let isReady = await HybridLLMService.shared.isModelLoaded
                let modelName = await HybridLLMService.shared.currentModelFilename
                
                await MainActor.run {
                    self.modelLoaded = isReady
                    self.lastLoadedModel = modelName
                }
                
                // FIXED: Add delay to ensure model is fully ready
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                // Step 5: Verify history is intact
                if let history = self.messageHistory {
                    for (index, message) in history.enumerated() {
                        #if DEBUG
                        print("   [\(index)] \(message.isUser ? "User" : "Assistant"): \(message.content.prefix(100))...")
                        #endif
                    }
                }
                
                // FIXED: Clear model switching flag to allow new messages
                await MainActor.run {
                    self.isModelSwitching = false
                }
                
            } catch {
                await MainActor.run {
                    self.modelLoaded = false
                    self.isModelSwitching = false
                }
            }
        }
    }
    
    func send(_ userText: String, addUserMessageToHistory: Bool = true) async throws {
        NSLog("ChatViewModel: send() called with: '\(userText)'")
        // Check session expiry before processing message
        checkSessionExpiry()
        
        // Prevent duplicate messages if already sent
        if lastSentMessage == userText, isProcessing {
            debugPrint("ChatViewModel: ⚠️ Duplicate message detected while processing, skipping send.", category: .general)
            return
        }
        
        NSLog("ChatViewModel: Setting isProcessing = true")
        // Ensure isProcessing is handled correctly, even if errors occur
        await MainActor.run { 
            self.isProcessing = true
        }
        // CRITICAL FIX: Removed defer block - let MainViewModel handle state reset after async completion
        
        lastSentMessage = userText

        // CRITICAL FIX: Always clear transcript for each new user message
        // Each user question should start with a fresh transcript
        NSLog("ChatViewModel: Message history count: \(messageHistory?.count ?? 0)")
        if let lastMessage = messageHistory?.last {
            NSLog("ChatViewModel: Last message isUser: \(lastMessage.isUser)")
        }
        NSLog("ChatViewModel: Clearing transcript for new user message")
        await MainActor.run { self.transcript = "" }

        if addUserMessageToHistory {
            let userMessage = ChatMessage(content: userText, isUser: true, timestamp: Date())
            if messageHistory == nil { messageHistory = [] }
            messageHistory?.append(userMessage)
            debugPrint("ChatViewModel: Added user message to history.", category: .general)
        }

        // Cancel any existing generation task
        currentGenerationTask?.cancel()
        
        // Create new cancellable task for generation and wait for it to complete
        currentGenerationTask = Task { [weak self] in
            guard let self = self else { return }
            
            // Start timing the response
            let startTime = Date()
            
            do {
                let currentHistory = messageHistory ?? []
                let historyToSend = buildSafeHistory(from: currentHistory)

                // SIMPLIFIED: LLMService now handles concurrent loading automatically
                // Multiple requests for the same model will queue and share the result
                NSLog("ChatViewModel: About to load selected model")
                try await HybridLLMService.shared.loadSelectedModel()
                NSLog("ChatViewModel: Model loaded successfully")
                
                NSLog("ChatViewModel: About to call generateResponse")
                try await HybridLLMService.shared.generateResponse(
                    userText: userText,
                    history: historyToSend,
                    onToken: { [weak self] partialResponse in
                        NSLog("ChatViewModel: onToken called with: '\(partialResponse)'")
                        NSLog("ChatViewModel: About to call MainActor.run")
                        await MainActor.run {
                            NSLog("ChatViewModel: Inside MainActor.run")
                            if Task.isCancelled { 
                                NSLog("ChatViewModel: Task is cancelled, returning")
                                return 
                            }
                            NSLog("ChatViewModel: Updating transcript with: '\(partialResponse)'")
                            NSLog("ChatViewModel: Current transcript length: \(self?.transcript.count ?? 0)")
                            self?.transcript += partialResponse
                            NSLog("ChatViewModel: New transcript length: \(self?.transcript.count ?? 0)")
                            NSLog("ChatViewModel: Transcript update completed")
                        }
                    }
                )

                // After the stream is complete, save the final message and update performance
                if !Task.isCancelled {
                    let finalMessage = ChatMessage(content: self.transcript, isUser: false, timestamp: Date())
                    self.messageHistory?.append(finalMessage)
                    
                    // Update model performance tracking
                    let responseTime = Date().timeIntervalSince(startTime)
                    if let currentModel = await HybridLLMService.shared.currentModelFilename {
                        await MainActor.run {
                            self.updateModelPerformance(for: currentModel, responseTime: responseTime)
                            // Update the global average response duration for settings display
                            self.updateGlobalResponseDuration(responseTime: responseTime)
                        }
                    }
                    
                    // CRITICAL FIX: DO NOT clear transcript after successful generation
                    // Keep the generated content visible for the user
                }
                
            } catch is CancellationError {
                // Ensure a partial message is saved if cancelled
                if !transcript.isEmpty {
                    let partialMessage = ChatMessage(content: transcript, isUser: false, timestamp: Date())
                    self.messageHistory?.append(partialMessage)
                }
                // CRITICAL FIX: DO NOT clear transcript on cancellation - keep partial content
                // await MainActor.run {
                //     self.transcript = ""
                // }
            } catch {
                let errorMessage = ChatMessage(content: String(format: NSLocalizedString("Error: %@", comment: ""), error.localizedDescription), isUser: false, timestamp: Date(), messageType: .error)
                self.messageHistory?.append(errorMessage)
                // CRITICAL FIX: DO NOT clear transcript on error - keep partial content
                // await MainActor.run {
                //     self.transcript = ""
                // }
            }
            
            await MainActor.run {
                self.requestStartTime = nil
                self.lastSentMessage = nil // Allow sending the same message again
                // CRITICAL FIX: Reset processing state after Task completes
                self.isProcessing = false
                // CRITICAL FIX: DO NOT clear transcript - keep generated content visible
            }
        }
        
        // Wait for the task to complete, handling cancellation properly
        do {
            try await currentGenerationTask?.value
        } catch {
            // Task was cancelled or failed - isProcessing already reset in stopGeneration()
            if error is CancellationError {
                debugPrint("ChatViewModel: Generation task was cancelled", category: .general)
            } else {
                debugPrint("ChatViewModel: Generation task failed: \(error)", category: .general)
                // Reset processing state on error
                await MainActor.run {
                    self.isProcessing = false
                }
            }
        }
    }
    
    // MARK: - History Safeguard
    private func buildSafeHistory(from fullHistory: [ChatMessage]) -> [ChatMessage] {
        SecureLogger.log("buildSafeHistory called - \(fullHistory.count) messages")
        
        // FIXED: More reasonable limits that preserve conversation context
        let maxMessages = 8  // Keep last 8 messages (4 exchanges) for better context
        let maxCharacters = 3400  // Increased to allow more context retention

        // Take the most recent messages up to maxMessages
        var trimmed = Array(fullHistory.suffix(maxMessages))
        SecureLogger.log("ChatViewModel: After maxMessages trim: \(trimmed.count) messages")

        // If still too long, trim from the oldest in this window until below character cap
        func totalChars(_ msgs: [ChatMessage]) -> Int {
            msgs.reduce(0) { $0 + $1.content.count }
        }

        let initialChars = totalChars(trimmed)
        SecureLogger.log("ChatViewModel: Initial character count: \(initialChars)")

        while totalChars(trimmed) > maxCharacters && !trimmed.isEmpty {
            trimmed.removeFirst()
        }

        let finalChars = totalChars(trimmed)
        SecureLogger.log("Final result - \(trimmed.count) messages, \(finalChars) characters")

        // SECURITY: Clear original history from memory after processing
        // Note: Removed string wiping as it can cause memory corruption
        // The strings will be deallocated naturally when they go out of scope

        return trimmed
    }
    
    func clearConversation() {
        DispatchQueue.main.async {
            // self.transcript = "" // REMOVED: Don't clear transcript in clearConversation
            self.messageHistory = []
            self.lastSentMessage = nil
            // Keep response timing stats - don't reset them
            // self.totalResponseTime = 0.0
            // self.responseCount = 0
            // self.averageResponseDuration = 0.0
        }
    }
    
    func clearDuplicateMessageState() {
        DispatchQueue.main.async {
            self.lastSentMessage = nil
        }
    }
    
    func ensureModel() async throws {
        // Use the HybridLLMService to manage model state
        if !(await HybridLLMService.shared.isModelLoaded) {
            try await HybridLLMService.shared.loadSelectedModel()
        } else {
            let engineInfo = await HybridLLMService.shared.getCurrentEngineInfo()
        }
        
        // Sync local state for UI purposes by fetching async properties first
        let isLoaded = await HybridLLMService.shared.isModelLoaded
        let filename = await HybridLLMService.shared.currentModelFilename
        
        await MainActor.run {
            self.modelLoaded = isLoaded
            self.lastLoadedModel = filename
        }
    }
    
    /// CRITICAL FIX: Sync model state on startup to ensure UI shows correct status
    private func syncModelState() async {
        
        // Check if model is already loaded in HybridLLMService
        let isLoaded = await HybridLLMService.shared.isModelLoaded
        let filename = await HybridLLMService.shared.currentModelFilename
        
        if isLoaded {
            // Model is already loaded, sync the state
            await MainActor.run {
                self.modelLoaded = isLoaded
                self.lastLoadedModel = filename
            }
        } else {
            // No model loaded, check if there's a selected model and load it
            if let selectedModelFilename = ModelManager.shared.getSelectedModelFilename() {
                
                do {
                    try await HybridLLMService.shared.loadSelectedModel()
                    
                    // Update state after successful loading
                    let newIsLoaded = await HybridLLMService.shared.isModelLoaded
                    let newFilename = await HybridLLMService.shared.currentModelFilename
                    
                    await MainActor.run {
                        self.modelLoaded = newIsLoaded
                        self.lastLoadedModel = newFilename
                    }
                    
                } catch {
                    await MainActor.run {
                        self.modelLoaded = false
                        self.lastLoadedModel = nil
                    }
                }
            } else {
                await MainActor.run {
                    self.modelLoaded = false
                    self.lastLoadedModel = nil
                }
            }
        }
    }
    


    func calculateMessageOpacity(for message: ChatMessage) -> Double {
        // All messages in current session have full opacity
        return 1.0
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
    
    // MARK: - Model Performance Management
    
    private func loadModelPerformanceData() {
        if let decoded = SecureStorage.retrieve([String: ModelPerformanceData].self, forKey: "ModelPerformanceData") {
            modelPerformanceData = decoded
            SecureLogger.log("Loaded model performance data - \(decoded.count) models")
            for (model, perf) in decoded {
                SecureLogger.log("Model performance - \(model): avg=\(String(format: "%.2f", perf.averageResponseTime))s, fast=\(perf.isFastModel)")
            }
        }
    }
    
    private func saveModelPerformanceData() {
        SecureStorage.store(modelPerformanceData, forKey: "ModelPerformanceData")
        SecureLogger.log("Saved model performance data - \(modelPerformanceData.count) models")
    }
    
    func updateModelPerformance(for modelFilename: String, responseTime: TimeInterval) {
        if modelPerformanceData[modelFilename] == nil {
            modelPerformanceData[modelFilename] = ModelPerformanceData()
        }
        
        modelPerformanceData[modelFilename]?.updateResponseTime(responseTime)
        saveModelPerformanceData()
    }
    
    func updateGlobalResponseDuration(responseTime: TimeInterval) {
        totalResponseTime += responseTime
        responseCount += 1
        averageResponseDuration = totalResponseTime / Double(responseCount)
        
        // Save to secure storage for persistence
        SecureStorage.storeDouble(averageResponseDuration, forKey: "AverageResponseTime")
        SecureStorage.storeDouble(totalResponseTime, forKey: "TotalResponseTime")
        SecureStorage.storeInt(responseCount, forKey: "ResponseCount")
        
        SecureLogger.log("Updated global response duration - \(String(format: "%.2f", responseTime))s (avg: \(String(format: "%.2f", averageResponseDuration))s)")
    }
    
    func isModelFast(_ modelFilename: String) -> Bool {
        return modelPerformanceData[modelFilename]?.isFastModel ?? false
    }
    
    func getModelPerformance(_ modelFilename: String) -> ModelPerformanceData? {
        return modelPerformanceData[modelFilename]
    }
    
    // MARK: - Cancellation Support
    
    @MainActor
    func stopGeneration() {
        currentGenerationTask?.cancel()
        currentGenerationTask = nil
        
        // Also stop the HybridLLMService generation
        HybridLLMService.shared.stopGeneration()
        
        self.isProcessing = false
    }
    
    // MARK: - Session Management
    
    private func initializeSession() {
        // Check if we need to start a new session
        if let savedTime = SecureStorage.retrieveDate(forKey: sessionDurationKey) {
            let timeSinceOpen = Date().timeIntervalSince(savedTime)
            let twentyFourHours: TimeInterval = 24 * 60 * 60 // 24 hours in seconds
            
            if timeSinceOpen >= twentyFourHours {
                // 24 hours have passed, start fresh session
                SecureLogger.log("24 hours passed, starting fresh session")
                startNewSession()
            } else {
                // Continue existing session
                appOpenTime = savedTime
                SecureLogger.log("Continuing existing session started at \(savedTime)")
            }
        } else {
            // First time or no saved session, start fresh
            startNewSession()
        }
    }
    
    private func startNewSession() {
        appOpenTime = Date()
        messageHistory = []
        
        // Save new session start time securely
        SecureStorage.storeDate(appOpenTime, forKey: sessionDurationKey)
        
        SecureLogger.log("Started new session at \(appOpenTime)")
    }
    
    private func checkSessionExpiry() {
        let timeSinceOpen = Date().timeIntervalSince(appOpenTime)
        let twentyFourHours: TimeInterval = 24 * 60 * 60
        
        if timeSinceOpen >= twentyFourHours {
            SecureLogger.log("Session expired, resetting history")
            startNewSession()
        }
    }
}