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
        print("🔍 ChatViewModel: init")
        initializeSession()
        
        // Load saved timing data from UserDefaults
        let savedAverage = UserDefaults.standard.double(forKey: "AverageResponseTime")
        let savedTotalTime = UserDefaults.standard.double(forKey: "TotalResponseTime")
        let savedResponseCount = UserDefaults.standard.integer(forKey: "ResponseCount")
        
        if savedAverage > 0 {
            self.averageResponseDuration = savedAverage
            self.totalResponseTime = savedTotalTime
            self.responseCount = savedResponseCount
            print("🔍 ChatViewModel: Loaded saved timing data - avg: \(savedAverage)s, total: \(savedTotalTime)s, count: \(savedResponseCount)")
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
    
    func send(_ userText: String, addUserMessageToHistory: Bool = true) async throws {
        // Check session expiry before processing message
        checkSessionExpiry()
        
        // Prevent duplicate messages if already sent
        if lastSentMessage == userText, isProcessing {
            print("🔍 ChatViewModel: ⚠️ Duplicate message detected while processing, skipping send.")
            return
        }
        
        // Ensure isProcessing is handled correctly, even if errors occur
        await MainActor.run { self.isProcessing = true }
        // CRITICAL FIX: Removed defer block - let MainViewModel handle state reset after async completion
        
        lastSentMessage = userText
        await MainActor.run { self.transcript = "" }

        if addUserMessageToHistory {
            let userMessage = ChatMessage(content: userText, isUser: true, timestamp: Date())
            if messageHistory == nil { messageHistory = [] }
            messageHistory?.append(userMessage)
            print("🔍 ChatViewModel: Added user message to history.")
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

                try await HybridLLMService.shared.loadSelectedModel()
                
                try await HybridLLMService.shared.generateResponse(
                    userText: userText,
                    history: historyToSend,
                    onToken: { [weak self] partialResponse in
                        Task { @MainActor in
                            if Task.isCancelled { return }
                            self?.transcript += partialResponse
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
                    
                    // Clear transcript to stop thinking animation
                    await MainActor.run {
                        self.transcript = ""
                    }
                }
                
            } catch is CancellationError {
                print("🔍 ChatViewModel: Generation was cancelled.")
                // Ensure a partial message is saved if cancelled
                if !transcript.isEmpty {
                    let partialMessage = ChatMessage(content: transcript, isUser: false, timestamp: Date())
                    self.messageHistory?.append(partialMessage)
                }
                // Clear transcript to stop thinking animation
                await MainActor.run {
                    self.transcript = ""
                }
            } catch {
                print("❌ ChatViewModel: Llama generation failed: \(error)")
                let errorMessage = ChatMessage(content: String(format: NSLocalizedString("Error: %@", comment: ""), error.localizedDescription), isUser: false, timestamp: Date(), messageType: .error)
                self.messageHistory?.append(errorMessage)
                // Clear transcript to stop thinking animation
                await MainActor.run {
                    self.transcript = ""
                }
            }
            
            await MainActor.run {
                self.requestStartTime = nil
                self.lastSentMessage = nil // Allow sending the same message again
                // CRITICAL FIX: Reset processing state after Task completes
                self.isProcessing = false
                self.transcript = ""
            }
        }
        
        // Wait for the task to complete
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
            // Keep response timing stats - don't reset them
            // self.totalResponseTime = 0.0
            // self.responseCount = 0
            // self.averageResponseDuration = 0.0
            print("🔍 ChatViewModel: Conversation cleared (timing data preserved)")
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
    
    /// CRITICAL FIX: Sync model state on startup to ensure UI shows correct status
    private func syncModelState() async {
        print("🔍 ChatViewModel: Syncing initial model state...")
        
        // Check if model is already loaded in HybridLLMService
        let isLoaded = await HybridLLMService.shared.isModelLoaded
        let filename = await HybridLLMService.shared.currentModelFilename
        
        if isLoaded {
            // Model is already loaded, sync the state
            await MainActor.run {
                self.modelLoaded = isLoaded
                self.lastLoadedModel = filename
            }
            print("🔍 ChatViewModel: Model already loaded - loaded: \(isLoaded), model: \(filename ?? "none")")
        } else {
            // No model loaded, check if there's a selected model and load it
            if let selectedModelFilename = ModelManager.shared.getSelectedModelFilename() {
                print("🔍 ChatViewModel: No model loaded, but selected model exists: \(selectedModelFilename)")
                print("🔍 ChatViewModel: Auto-loading selected model on startup...")
                
                do {
                    try await HybridLLMService.shared.loadSelectedModel()
                    
                    // Update state after successful loading
                    let newIsLoaded = await HybridLLMService.shared.isModelLoaded
                    let newFilename = await HybridLLMService.shared.currentModelFilename
                    
                    await MainActor.run {
                        self.modelLoaded = newIsLoaded
                        self.lastLoadedModel = newFilename
                    }
                    
                    print("✅ ChatViewModel: Auto-loaded model on startup - loaded: \(newIsLoaded), model: \(newFilename ?? "none")")
                } catch {
                    print("❌ ChatViewModel: Failed to auto-load model on startup: \(error)")
                    await MainActor.run {
                        self.modelLoaded = false
                        self.lastLoadedModel = nil
                    }
                }
            } else {
                print("🔍 ChatViewModel: No model loaded and no model selected")
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
        if let data = UserDefaults.standard.data(forKey: "ModelPerformanceData"),
           let decoded = try? JSONDecoder().decode([String: ModelPerformanceData].self, from: data) {
            modelPerformanceData = decoded
            print("🔍 ChatViewModel: Loaded model performance data for \(decoded.count) models")
            for (model, perf) in decoded {
                print("   \(model): avg=\(String(format: "%.2f", perf.averageResponseTime))s, fast=\(perf.isFastModel)")
            }
        }
    }
    
    private func saveModelPerformanceData() {
        if let encoded = try? JSONEncoder().encode(modelPerformanceData) {
            UserDefaults.standard.set(encoded, forKey: "ModelPerformanceData")
            print("🔍 ChatViewModel: Saved model performance data for \(modelPerformanceData.count) models")
        }
    }
    
    func updateModelPerformance(for modelFilename: String, responseTime: TimeInterval) {
        if modelPerformanceData[modelFilename] == nil {
            modelPerformanceData[modelFilename] = ModelPerformanceData()
        }
        
        modelPerformanceData[modelFilename]?.updateResponseTime(responseTime)
        saveModelPerformanceData()
        
        print("🔍 ChatViewModel: Updated performance for \(modelFilename): \(String(format: "%.2f", responseTime))s (avg: \(String(format: "%.2f", modelPerformanceData[modelFilename]?.averageResponseTime ?? 0))s)")
    }
    
    func updateGlobalResponseDuration(responseTime: TimeInterval) {
        totalResponseTime += responseTime
        responseCount += 1
        averageResponseDuration = totalResponseTime / Double(responseCount)
        
        // Save to UserDefaults for persistence
        UserDefaults.standard.set(averageResponseDuration, forKey: "AverageResponseTime")
        UserDefaults.standard.set(totalResponseTime, forKey: "TotalResponseTime")
        UserDefaults.standard.set(responseCount, forKey: "ResponseCount")
        
        print("🔍 ChatViewModel: Updated global response duration: \(String(format: "%.2f", responseTime))s (avg: \(String(format: "%.2f", averageResponseDuration))s)")
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
        print("🔍 ChatViewModel: Stopping generation")
        currentGenerationTask?.cancel()
        currentGenerationTask = nil
        
        // Also stop the HybridLLMService generation
        HybridLLMService.shared.stopGeneration()
        
        self.isProcessing = false
    }
    
    // MARK: - Session Management
    
    private func initializeSession() {
        // Check if we need to start a new session
        if let savedTimeData = UserDefaults.standard.data(forKey: sessionDurationKey),
           let savedTime = try? JSONDecoder().decode(Date.self, from: savedTimeData) {
            
            let timeSinceOpen = Date().timeIntervalSince(savedTime)
            let twentyFourHours: TimeInterval = 24 * 60 * 60 // 24 hours in seconds
            
            if timeSinceOpen >= twentyFourHours {
                // 24 hours have passed, start fresh session
                print("🔍 ChatViewModel: 24 hours passed, starting fresh session")
                startNewSession()
            } else {
                // Continue existing session
                appOpenTime = savedTime
                print("🔍 ChatViewModel: Continuing existing session started at \(savedTime)")
            }
        } else {
            // First time or no saved session, start fresh
            startNewSession()
        }
    }
    
    private func startNewSession() {
        appOpenTime = Date()
        messageHistory = []
        
        // Save new session start time
        if let encodedTime = try? JSONEncoder().encode(appOpenTime) {
            UserDefaults.standard.set(encodedTime, forKey: sessionDurationKey)
        }
        
        print("🔍 ChatViewModel: Started new session at \(appOpenTime)")
    }
    
    private func checkSessionExpiry() {
        let timeSinceOpen = Date().timeIntervalSince(appOpenTime)
        let twentyFourHours: TimeInterval = 24 * 60 * 60
        
        if timeSinceOpen >= twentyFourHours {
            print("🔍 ChatViewModel: Session expired, resetting history")
            startNewSession()
        }
    }
}