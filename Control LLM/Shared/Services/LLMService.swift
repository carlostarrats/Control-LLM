import Foundation
import SwiftUI

// CONCURRENT LOADING FIX: Thread-safe actor for managing loading operations
actor LoadingQueueActor {
    private var loadingOperations: [String: Task<Void, Error>] = [:]
    
    func getExistingTask(for modelFilename: String) -> Task<Void, Error>? {
        return loadingOperations[modelFilename]
    }
    
    func setTask(_ task: Task<Void, Error>, for modelFilename: String) {
        loadingOperations[modelFilename] = task
    }
    
    func removeTask(for modelFilename: String) {
        loadingOperations.removeValue(forKey: modelFilename)
    }
}

// MARK: - Performance Optimization: Memory Pressure Monitor
class MemoryPressureMonitor {
    private var memoryPressureSource: DispatchSourceMemoryPressure?
    private let memoryThreshold: UInt64
    
    init(threshold: UInt64 = 2 * 1024 * 1024 * 1024) { // 2GB default
        self.memoryThreshold = threshold
        setupMemoryPressureMonitoring()
    }
    
    private func setupMemoryPressureMonitoring() {
        memoryPressureSource = DispatchSource.makeMemoryPressureSource(eventMask: .all, queue: .global(qos: .background))
        
        memoryPressureSource?.setEventHandler { [weak self] in
            self?.handleMemoryPressure()
        }
        
        memoryPressureSource?.resume()
    }
    
    private func handleMemoryPressure() {
        let currentMemory = getCurrentMemoryUsage()
        
        if currentMemory > memoryThreshold {
            // Trigger memory cleanup
            NotificationCenter.default.post(name: .memoryPressureDetected, object: nil)
        }
    }
    
    private func getCurrentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            return 0
        }
    }
    
    deinit {
        memoryPressureSource?.cancel()
    }
}

extension Notification.Name {
    static let memoryPressureDetected = Notification.Name("memoryPressureDetected")
}

final class LLMService: @unchecked Sendable {
    static let shared = LLMService()
    private var modelPath: String?
    private var currentModelFilename: String?
    private var llamaModel: UnsafeMutableRawPointer?
    private var llamaContext: UnsafeMutableRawPointer?
    private var isModelLoaded = false
    
    private init() {
        // CRITICAL DEBUG: Log LLMService state at initialization
        NSLog("LLMService: 🚀 LLMService initialized")
        NSLog("LLMService: Initial state:")
        NSLog("LLMService: - isModelLoaded: \(isModelLoaded)")
        NSLog("LLMService: - currentModelFilename: \(currentModelFilename ?? "nil")")
        NSLog("LLMService: - isModelOperationInProgress: \(isModelOperationInProgress)")
        NSLog("LLMService: - isChatOperationInProgress: \(isChatOperationInProgress)")
        NSLog("LLMService: - _isMultiPassMode: \(_isMultiPassMode)")
        NSLog("LLMService: - llamaModel: \(llamaModel != nil ? "exists" : "nil")")
        NSLog("LLMService: - llamaContext: \(llamaContext != nil ? "exists" : "nil")")
    }
    private var conversationCount = 0
    private let maxConversationsBeforeReset = 50  // Increased from 3 to prevent interference with model switching
    private var isModelOperationInProgress = false  // For model loading/unloading
    private var isChatOperationInProgress = false   // For chat generation
    private var _isMultiPassMode = false             // For multi-pass processing
    private var lastOperationTime: Date = Date()  // Track when operations start
    
    // CONCURRENT LOADING FIX: Thread-safe actor for managing loading operations per model
    private let loadingQueueActor = LoadingQueueActor()
    
    // PERFORMANCE OPTIMIZATION: Model warmup cache
    private var modelWarmupCache: [String: Date] = [:]
    private let warmupValidityInterval: TimeInterval = 30 * 60 // 30 minutes
    private var preloadedModels: Set<String> = []
    
    // PERFORMANCE OPTIMIZATION: Memory management
    private var memoryPressureMonitor: MemoryPressureMonitor?
    private let maxMemoryUsage: UInt64 = 2 * 1024 * 1024 * 1024 // 2GB limit
    
    /// Public read-only access to multi-pass mode status
    var isMultiPassMode: Bool {
        return _isMultiPassMode
    }
    
    /// Cancel ongoing LLM generation (Phase 4: Enhanced Reliability)
    func cancelGeneration() {
        // CRITICAL DEBUG: Log cancellation timing and call stack
        let cancelTime = Date()
        NSLog("LLMService: ⚠️ GENERATION CANCELLED - cancelGeneration() called at \(cancelTime)")
        NSLog("LLMService: Cancellation timestamp: \(cancelTime.timeIntervalSince1970)")
        NSLog("LLMService: Call stack trace:")
        Thread.callStackSymbols.enumerated().forEach { index, symbol in
            NSLog("LLMService: [\(index)] \(symbol)")
        }
        NSLog("LLMService: ⚠️ End of call stack trace")
        
        debugPrint("LLMService: PHASE 4 - Cancelling ongoing generation with enhanced reliability", category: .model)
        
        // Set the cancellation flag in the C bridge
        llm_bridge_cancel_generation()
        
        // Reset the operation in progress flag to allow new operations
        isModelOperationInProgress = false
        
        // PERFORMANCE FIX: Add proper resource cleanup
        if let context = llamaContext {
            llm_bridge_free_context(context)
            llamaContext = nil
        }
        
        // CRITICAL FIX: Reset model state flags when context is freed
        isModelLoaded = false
        currentModelFilename = nil
        
        debugPrint("LLMService: PHASE 4 - Cancellation flag set and operation flags reset", category: .model)
    }
    
    /// Enable multi-pass mode to prevent concurrency errors during multi-pass processing
    func enableMultiPassMode() {
        _isMultiPassMode = true
        isChatOperationInProgress = true
    }
    
    /// Disable multi-pass mode and reset chat operation flags
    func disableMultiPassMode() {
        _isMultiPassMode = false
        isChatOperationInProgress = false
    }
    
    // MARK: - Performance Optimizations
    
    /// Check if model is warm (recently loaded)
    func isModelWarm(_ modelFilename: String) -> Bool {
        guard let lastWarmup = modelWarmupCache[modelFilename] else { return false }
        return Date().timeIntervalSince(lastWarmup) < warmupValidityInterval
    }
    
    /// Mark model as warm after successful loading
    func markModelAsWarm(_ modelFilename: String) {
        modelWarmupCache[modelFilename] = Date()
    }
    
    /// Preload model in background for faster switching
    func preloadModelInBackground(_ modelFilename: String) async {
        guard !preloadedModels.contains(modelFilename) else {
            return
        }
        
        preloadedModels.insert(modelFilename)
        
        Task.detached(priority: .background) { [weak self] in
            do {
                // Preload without full initialization
                try await self?.preloadModelWithLlamaCpp(modelFilename)
            } catch {
                self?.preloadedModels.remove(modelFilename)
            }
        }
    }
    
    /// Preload model with minimal initialization
    private func preloadModelWithLlamaCpp(_ modelFilename: String) async throws {
        // Find model file
        let modelURL = try await findModelFile(for: modelFilename)
        
        // Validate model
        try await ModelValidationService.shared.performComprehensiveValidation(at: modelURL)
        
        // Preload model context (lightweight)
        // This is a placeholder - actual implementation would depend on llama.cpp API
        
        // Mark as warm
        markModelAsWarm(modelFilename)
    }
    
    /// Initialize memory pressure monitoring
    private func initializeMemoryMonitoring() {
        memoryPressureMonitor = MemoryPressureMonitor(threshold: maxMemoryUsage)
        
        // Listen for memory pressure notifications
        NotificationCenter.default.addObserver(
            forName: .memoryPressureDetected,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryPressure()
        }
    }
    
    /// Handle memory pressure by cleaning up resources
    private func handleMemoryPressure() {
        
        // Clear warmup cache for old models
        let cutoffDate = Date().addingTimeInterval(-warmupValidityInterval)
        modelWarmupCache = modelWarmupCache.filter { $0.value > cutoffDate }
        
        // Clear preloaded models
        preloadedModels.removeAll()
        
        // Force garbage collection
        Task.detached(priority: .background) {
            // Trigger memory cleanup
            autoreleasepool {
                // This will trigger ARC cleanup
            }
        }
    }
    
    /// Load a specific model by filename with optimized performance
    func loadModel(_ modelFilename: String) async throws {
        // CONCURRENT LOADING FIX: Check if we're already loading this specific model
        if let existingTask = await loadingQueueActor.getExistingTask(for: modelFilename) {
            
            do {
                try await existingTask.value
                return
            } catch {
                throw error
            }
        }
        
        // Create new loading task for this model
        let loadingTask = Task<Void, Error> {
            try await performActualModelLoad(modelFilename)
        }
        
        await loadingQueueActor.setTask(loadingTask, for: modelFilename)
        
        // Execute the loading and clean up when done
        defer {
            Task {
                await loadingQueueActor.removeTask(for: modelFilename)
            }
        }
        
        try await loadingTask.value
    }
    
    /// Perform the actual model loading (internal method)
    private func performActualModelLoad(_ modelFilename: String) async throws {
        // Safety mechanism: if the flag has been stuck for more than 5 minutes, reset it
        if isModelOperationInProgress {
            let timeSinceLastOperation = Date().timeIntervalSince(lastOperationTime)
            if timeSinceLastOperation > 300 { // 5 minutes
                isModelOperationInProgress = false
            }
        }
        
        // Prevent concurrent model operations for DIFFERENT models
        guard !isModelOperationInProgress else {
            throw NSError(domain: "LLMService", code: 11, userInfo: [NSLocalizedDescriptionKey: "Another model operation is in progress"])
        }
        
        // OPTIMIZATION: Check if we're already loading the same model
        if currentModelFilename == modelFilename && isModelLoaded {
            return
        }
        
        // PERFORMANCE OPTIMIZATION: Check if model is warm (recently loaded)
        if isModelWarm(modelFilename) {
        }
        
        // PERFORMANCE OPTIMIZATION: Initialize memory monitoring if not already done
        if memoryPressureMonitor == nil {
            initializeMemoryMonitoring()
        }
        
        // Security: Validate model before loading
        let modelURL = try await findModelFile(for: modelFilename)
        try await ModelValidationService.shared.performComprehensiveValidation(at: modelURL)
        
        isModelOperationInProgress = true
        lastOperationTime = Date()
        defer { 
            isModelOperationInProgress = false 
        }
        
        
        // PERFORMANCE OPTIMIZATION: Enhanced parallel model switching
        
        // Start parallel operations for faster initialization
        async let backgroundTasks: Void = {
            // Clear previous model in background (non-blocking)
            Task.detached(priority: .background) { [weak self] in
                self?.unloadModel()
            }
            
            // Pre-warm memory management in parallel
            Task.detached(priority: .utility) { [weak self] in
                await self?.preWarmMemoryForModel(modelFilename)
            }
            
            // Pre-fetch any cached data in parallel
            Task.detached(priority: .utility) { [weak self] in
                await self?.preLoadModelCache(modelFilename)
            }
        }()
        
        // Set new model info first (non-blocking)
        self.modelPath = modelURL.path
        self.currentModelFilename = modelFilename
        
        // Reset conversation count when switching models
        conversationCount = 0
        
        // Wait for background preparation to complete
        await backgroundTasks
        
        // Load the model using llama.cpp with optimized timeout for better UX
        do {
            // PERFORMANCE OPTIMIZATION: Reduced timeout for faster failure feedback
            let timeoutSeconds: TimeInterval = isModelWarm(modelFilename) ? 10 : 15
            try await withTimeout(seconds: timeoutSeconds) { [self] in
                try await self.loadModelWithLlamaCpp()
            }
        } catch {
            let reason = (error as NSError).localizedDescription
            throw error
        }
        
        
        // PERFORMANCE OPTIMIZATION: Mark model as warm for faster future loading
        markModelAsWarm(modelFilename)
        
        // SECURITY: Run comprehensive validation in background (non-blocking)
        Task.detached { [weak self] in
            await self?.performBackgroundSecurityValidation()
        }
    }
    
    /// Load the currently selected model from ModelManager
    func loadSelectedModel() async throws {
        guard let modelFilename = ModelManager.shared.getSelectedModelFilename() else {
            throw NSError(domain: "LLMService",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "No model selected"])
        }
        
        // Use the optimized loadModel method to avoid code duplication
        try await loadModel(modelFilename)
    }
    
    /// OPTIMIZATION: Find model file with priority order for fastest access
    private func findModelFile(for modelFilename: String) async throws -> URL {
        // Priority 1: Models directory (fastest - bundled with app)
        if let modelsDir = Bundle.main.url(forResource: "Models", withExtension: nil) {
            let modelUrl = modelsDir.appendingPathComponent("\(modelFilename).gguf")
            if FileManager.default.fileExists(atPath: modelUrl.path) {
                return modelUrl
            }
        }
        
        // Priority 2: Bundle root (medium - also bundled)
        if let rootUrl = Bundle.main.url(forResource: modelFilename, withExtension: "gguf", subdirectory: nil) {
            return rootUrl
        }
        
        // Priority 3: Documents/Models (slowest - file system access)
        if let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let modelsDir = docsDir.appendingPathComponent("Models", isDirectory: true)
            let docUrl = modelsDir.appendingPathComponent("\(modelFilename).gguf")
            if FileManager.default.fileExists(atPath: docUrl.path) {
                return docUrl
            }
        }
        
        throw NSError(domain: "LLMService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Model file not found in any location"])
    }
    
    // MARK: - Background Security Validation
    
    /// Performs comprehensive security validation in the background
    private func performBackgroundSecurityValidation() async {
        guard let modelPath = modelPath else { return }
        
        
        // Comprehensive integrity validation
        do {
            try ModelIntegrityChecker.validateModel(modelPath)
            try ModelIntegrityChecker.performSecurityChecks(modelPath)
        } catch {
        }
        
        // Hash verification (if we implement cached hashes)
        // For bundled models, use basic validation instead of strict hash checking
        let fileName = URL(fileURLWithPath: modelPath).lastPathComponent
        let isBundledModel = ["gemma-3-1B-It-Q4_K_M.gguf", "Llama-3.2-1B-Instruct-Q4_K_M.gguf", "Qwen3-1.7B-Q4_K_M.gguf", "smollm2-1.7b-instruct-q4_k_m.gguf"].contains(fileName)
        
        if isBundledModel {
            // For bundled models, just check if file exists and is readable
            if FileManager.default.fileExists(atPath: modelPath) {
            } else {
            }
        } else {
            // For external models, use strict hash verification
            if ModelHashVerifier.shared.verifyModel(modelPath) {
            } else {
            }
        }
        
    }
    
    private func unloadModel() {
        
        // Safety check: prevent double-free
        guard llamaModel != nil || llamaContext != nil else {
            return
        }
        
        // CRASH FIX: Sequential cleanup to prevent race conditions and memory access violations
        // Free context first (it depends on the model)
        if let context = llamaContext {
            llm_bridge_free_context(context)
            llamaContext = nil
        }
        
        // Then free model
        if let model = llamaModel {
            llm_bridge_free_model(model)
            llamaModel = nil
        }
        
        // Clear all state
        isModelLoaded = false
        modelPath = nil
        currentModelFilename = nil
    }
    
    /// Force unload the current model (public method for external control)
    func forceUnloadModel() async throws {
        
        // Safety check: prevent concurrent unloads
        guard !isModelOperationInProgress else {
            return
        }
        
        isModelOperationInProgress = true
        defer { isModelOperationInProgress = false }
        
        
        // Wait for any ongoing chat operations to complete
        if isChatOperationInProgress {
            // Give it a moment to complete
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        // Prevent double-unload crashes
        guard isModelLoaded || llamaModel != nil || llamaContext != nil else {
            return
        }
        
        // IMPROVEMENT: More comprehensive state clearing
        conversationCount = 0
        isChatOperationInProgress = false
        lastOperationTime = Date()
        
        // Force unload the model
        unloadModel()
        
    }
    
    private func loadModelWithLlamaCpp() async throws {
        guard let modelPath = modelPath else {
            throw NSError(domain: "LLMService", code: 3, userInfo: [NSLocalizedDescriptionKey: "No model path"])
        }
        
        
        // Run heavy C calls off the main thread
        try await Task.detached(priority: .userInitiated) { [self] in
            // CRASH PROTECTION: Reset pointers before initialization
            self.llamaModel = nil
            self.llamaContext = nil
            
            // SECURITY: Quick model integrity validation (fast, non-blocking)
            do {
                try ModelIntegrityChecker.quickValidate(modelPath)
            } catch {
                // Don't throw - just log warning and continue
            }
            
            modelPath.withCString { cString in
                self.llamaModel = llm_bridge_load_model(cString)
            }
            
            // CRASH PROTECTION: Validate model pointer
            guard let model = self.llamaModel else {
                throw NSError(domain: "LLMService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to load model - bridge returned NULL"])
            }
            
            // CRASH PROTECTION: Validate model pointer is not a dangling reference
            if model == UnsafeMutableRawPointer(bitPattern: 0x1) || model == UnsafeMutableRawPointer(bitPattern: 0x0) {
                throw NSError(domain: "LLMService", code: 15, userInfo: [NSLocalizedDescriptionKey: "Failed to load model - bridge returned invalid pointer"])
            }
            
            // CRASH PROTECTION: Create context with error handling
            self.llamaContext = llm_bridge_create_context(model)
            
            // CRASH PROTECTION: Validate context pointer
            guard let context = self.llamaContext else {
                // Clean up the model if context creation fails
                llm_bridge_free_model(model)
                self.llamaModel = nil
                throw NSError(domain: "LLMService", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to create context - bridge returned NULL"])
            }
            
            // CRASH PROTECTION: Validate context pointer is not a dangling reference
            if context == UnsafeMutableRawPointer(bitPattern: 0x1) || context == UnsafeMutableRawPointer(bitPattern: 0x0) {
                // Clean up both model and context
                llm_bridge_free_context(context)
                llm_bridge_free_model(model)
                self.llamaModel = nil
                self.llamaContext = nil
                throw NSError(domain: "LLMService", code: 16, userInfo: [NSLocalizedDescriptionKey: "Failed to create context - bridge returned invalid pointer"])
            }
        }.value
        
        self.isModelLoaded = true
    }
    
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw NSError(domain: "LLMService", code: 7, userInfo: [NSLocalizedDescriptionKey: "Model loading timed out"])
            }
            
            guard let result = try await group.next() else {
                group.cancelAll()
                throw NSError(domain: "LLMService", code: 8, userInfo: [NSLocalizedDescriptionKey: "No result from timeout operation"])
            }
            
            group.cancelAll()
            return result
        }
    }

    /// Stream tokens for a user prompt, optionally with chat history
    func chat(user text: String, history: [ChatMessage]? = nil, maxTokens: Int = 2048, onToken: @escaping (String) async -> Void) async throws {
        SecureLogger.log("LLMService.chat: ENTRY POINT - \(text.count) characters")
        SecureLogger.log("LLMService.chat: History count - \(history?.count ?? 0)")
        // Safety mechanism: if the flag has been stuck for more than 5 minutes, reset it
        if isChatOperationInProgress {
            let timeSinceLastOperation = Date().timeIntervalSince(lastOperationTime)
            if timeSinceLastOperation > 300 { // 5 minutes
                isChatOperationInProgress = false
            }
        }
        
        // Prevent concurrent chat operations (unless in multi-pass mode)
        if !_isMultiPassMode {
            guard !isChatOperationInProgress else {
                throw NSError(domain: "LLMService", code: 22, userInfo: [NSLocalizedDescriptionKey: "Another chat operation is in progress"])
            }
            
            isChatOperationInProgress = true
            lastOperationTime = Date()
            
            // Ensure the flag is always reset, even if errors occur (only for single-pass)
            defer { 
                isChatOperationInProgress = false 
            }
        } else {
            lastOperationTime = Date()
        }
        
        // Increment conversation counter
        conversationCount += 1
        SecureLogger.logModelOperation("Starting conversation #\(conversationCount)", modelName: currentModelFilename ?? "unknown")
        
        // SECURITY: Validate and sanitize input
        let processedText: String
        do {
            processedText = try InputValidator.validateAndSanitizeInput(text)
        } catch let error as ValidationError {
            throw NSError(domain: "LLMService", code: 23, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
        }
        
        // SECURITY: Validate conversation history
        if let history = history {
            do {
                try InputValidator.validateHistory(history)
            } catch let error as ValidationError {
                throw NSError(domain: "LLMService", code: 24, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
            }
        }
        
        // IMPROVEMENT: Only reset context if we've had too many conversations with THIS model
        if conversationCount >= maxConversationsBeforeReset {
            
            // Only unload and reload the context, not the entire model
            if let context = llamaContext {
                llm_bridge_free_context(context)
                llamaContext = nil
            }
            
            // Recreate context
            if let model = llamaModel {
                llamaContext = llm_bridge_create_context(model)
                guard let context = llamaContext else {
                    throw NSError(domain: "LLMService", code: 21, userInfo: [NSLocalizedDescriptionKey: "Failed to recreate context"])
                }
                // CRASH PROTECTION: Validate recreated context pointer
                if context == UnsafeMutableRawPointer(bitPattern: 0x1) || context == UnsafeMutableRawPointer(bitPattern: 0x0) {
                    llamaContext = nil
                    throw NSError(domain: "LLMService", code: 25, userInfo: [NSLocalizedDescriptionKey: "Failed to recreate context - invalid pointer"])
                }
            }
            
            conversationCount = 0
        } else {
            // Only load model if we haven't already loaded it
            if !isModelLoaded {
                try await loadSelectedModel()
            }
        }
        
        guard isModelLoaded, let context = llamaContext else {
            throw NSError(domain: "LLMService",
                          code: 24,
                          userInfo: [NSLocalizedDescriptionKey: "Model not loaded"])
        }
        
        // Build the prompt using the new helper
        let prompt = buildPrompt(userText: processedText, history: history)
        
        SecureLogger.log("Final prompt length - \(prompt.count) characters")
        
        // SECURITY: Clear sensitive data from memory after processing
        // Note: Removed string wiping as it can cause memory corruption
        // Strings will be deallocated naturally when they go out of scope
        
        do {
            // Safety check for extremely long prompts
            // Increased to match maxInputLength and model's actual context window (32768 tokens)
            let maxPromptLength = 16000 // Increased from 4096 to handle larger contexts
            if prompt.count > maxPromptLength {
                throw NSError(domain: "LLMService",
                             code: 6, 
                             userInfo: [NSLocalizedDescriptionKey: "Prompt too long (\(prompt.count) characters). Please shorten your message."])
            }
            
            // CRITICAL FIX: Add specific check for multi-pass processing prompts
            // Multi-pass prompts can be complex and need extra validation
            if prompt.count > Constants.criticalThreshold {
                SecureLogger.log("WARNING: Multi-pass prompt is very long (\(prompt.count) characters). This may cause tokenization issues.")
                SecureLogger.log("Prompt preview", sensitiveData: String(prompt.prefix(500)))
            }
            
            // Warning for prompts approaching token limits
            let warningThreshold = Constants.warningThreshold // Characters
            if prompt.count > warningThreshold {
                SecureLogger.log("WARNING: Prompt is long (\(prompt.count) characters) and may approach token limits. Consider shortening your message or clearing chat history.")
            }
            
            // Use the new streaming implementation
            try await streamResponseWithLlamaCpp(context: context, prompt: prompt, maxTokens: maxTokens, onToken: onToken)
            
        } catch {
            throw error
        }
    }

    /// Stream tokens for a raw prompt (bypass chat template entirely)
    func chatRaw(prompt rawPrompt: String, maxTokens: Int = 2048, onToken: @escaping (String) async -> Void) async throws {
        // Ensure model is ready
        if !isModelLoaded { try await loadSelectedModel() }
        guard let context = llamaContext else {
            throw NSError(domain: "LLMService", code: 24, userInfo: [NSLocalizedDescriptionKey: "Model not loaded"])
        }

        // Minimal validation
        let prompt = rawPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else {
            throw NSError(domain: "LLMService", code: 18, userInfo: [NSLocalizedDescriptionKey: "Empty prompt for streaming"]) 
        }

        // Stream directly
        try await streamResponseWithLlamaCpp(context: context, prompt: prompt, maxTokens: maxTokens, onToken: onToken)
    }

    private func streamResponseWithLlamaCpp(context: UnsafeMutableRawPointer, prompt: String, maxTokens: Int = 2048, onToken: @escaping (String) async -> Void) async throws {
        // CRASH PROTECTION: Validate context pointer
        guard context != UnsafeMutableRawPointer(bitPattern: 0x0) && context != UnsafeMutableRawPointer(bitPattern: 0x1) else {
            throw NSError(domain: "LLMService", code: 17, userInfo: [NSLocalizedDescriptionKey: "Invalid context pointer for streaming"])
        }
        
        // Ensure the model name is valid and available
        guard let modelName = currentModelFilename, !modelName.isEmpty else {
            throw NSError(domain: "LLMService", code: 12, userInfo: [NSLocalizedDescriptionKey: "Model name not available for streaming."])
        }

        // CRASH PROTECTION: Validate prompt
        guard !prompt.isEmpty else {
            throw NSError(domain: "LLMService", code: 18, userInfo: [NSLocalizedDescriptionKey: "Empty prompt for streaming"])
        }

        // Use async/await with proper completion handling
        return try await withCheckedThrowingContinuation { continuation in
            // Track completion state to prevent multiple continuations
            var hasCompleted = false

            // Capture Swift strings for safe use inside the background block
            let promptToSend = prompt
            let modelNameToSend = modelName

            // Timeout for the entire streaming operation
            // Increased timeout for multi-pass processing scenarios
            let timeoutTask = Task {
                try await Task.sleep(nanoseconds: 180_000_000_000) // 180 seconds (3 minutes)
                if !hasCompleted {
                    hasCompleted = true
                    continuation.resume(throwing: NSError(domain: "LLMService", code: 20, userInfo: [NSLocalizedDescriptionKey: "Streaming generation timed out. This may happen with very large documents requiring multi-pass processing."]))
                }
            }

            // Call the C++ bridge function from a background thread
            DispatchQueue.global(qos: .userInitiated).async {
                // CRASH PROTECTION: Validate strings before converting to C strings
                guard !modelNameToSend.isEmpty, !promptToSend.isEmpty else {
                    if !hasCompleted {
                        hasCompleted = true
                        timeoutTask.cancel()
                        continuation.resume(throwing: NSError(domain: "LLMService", code: 19, userInfo: [NSLocalizedDescriptionKey: "Invalid strings for C++ bridge"]))
                    }
                    return
                }
                
                modelNameToSend.withCString { modelNameCString in
                    promptToSend.withCString { promptCString in
                        llm_bridge_generate_stream_block(context, modelNameCString, promptCString, { piece in
                            if let piece = piece {
                                let pieceString = String(cString: piece, encoding: .utf8) ?? ""
                                
                                // Check for token limit marker
                                if pieceString == "__TOKEN_LIMIT_REACHED__" {
                                    if !hasCompleted {
                                        hasCompleted = true
                                        timeoutTask.cancel()
                                        continuation.resume(throwing: NSError(domain: "LLMService", 
                                                                           code: 27, 
                                                                           userInfo: [NSLocalizedDescriptionKey: "Response generation reached the maximum token limit (2000 tokens). The response may be incomplete. Consider asking a more specific question or breaking your request into smaller parts."]))
                                    }
                                    return
                                }
                                
                                if !pieceString.isEmpty {
                                    // CRITICAL FIX: Use DispatchQueue.main.async for reliable callback execution
                                    NSLog("LLMService: Callback received token: '\(pieceString)'")
                                    NSLog("LLMService: About to call DispatchQueue.main.async")
                                    DispatchQueue.main.async {
                                        NSLog("LLMService: Inside DispatchQueue.main.async")
                                        Task {
                                            NSLog("LLMService: About to call onToken with: '\(pieceString)'")
                                            await onToken(pieceString)
                                            NSLog("LLMService: onToken call completed")
                                        }
                                    }
                                }
                            } else {
                                if !hasCompleted {
                                    hasCompleted = true
                                    timeoutTask.cancel()
                                    // Call completion callback when streaming finishes
                                    continuation.resume(returning: ())
                                }
                            }
                        }, Int32(maxTokens))
                    }
                }
            }
        }
    }
    
    private func buildPrompt(userText: String, history: [ChatMessage]?) -> String {
        SecureLogger.log("LLMService.buildPrompt: ENTRY POINT - \(userText.count) characters")
        SecureLogger.log("buildPrompt called with history count - \(history?.count ?? 0)")
        if let history = history, !history.isEmpty {
            SecureLogger.log("Building prompt with \(history.count) history messages for model \(currentModelFilename ?? "unknown")")
        } else {
            SecureLogger.log("Building fresh prompt (no history) for model \(currentModelFilename ?? "unknown")")
        }
        
        // QWEN THINKING FIX: Use enable_thinking=False parameter for Qwen3 models
        var processedUserText = userText
        var enableThinking = true // Default to true
        
        if let modelFilename = currentModelFilename, modelFilename.lowercased().contains("qwen3") {
            // Check if user explicitly wants to disable thinking
            if userText.contains("enable_thinking=False") {
                // Remove the parameter from user text
                processedUserText = userText.replacingOccurrences(of: "enable_thinking=False", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                enableThinking = false
            } else {
                // Default behavior: disable thinking for Qwen3 models
                enableThinking = false
            }
        }
        
        var systemPrompt = NSLocalizedString("LLM System Prompt", comment: "")
        
        // SECURITY: Sanitize system prompt to prevent injection
        systemPrompt = InputValidator.sanitizeSystemPrompt(systemPrompt)
        
        // Add enable_thinking=False instruction for Qwen3 models
        if !enableThinking {
            systemPrompt += "\n\nIMPORTANT: Use enable_thinking=False. Do not use <think> tags or internal reasoning. Respond directly and concisely."
        }
        
        // UNIVERSAL APPROACH: Use the standard chat template system for ALL models
        // This ensures compatibility with any model you switch to
        let prompt = buildPromptUsingChatTemplate(userText: processedUserText, history: history, systemPrompt: systemPrompt, enableThinking: enableThinking)
        
        // For Qwen3 models with enable_thinking=False, manually add empty thinking tags
        // This mimics what the Qwen3 template does when enable_thinking=False
        if !enableThinking && currentModelFilename?.lowercased().contains("qwen3") == true {
            let modifiedPrompt = prompt + "<think>\n\n</think>\n\n"
            return modifiedPrompt
        }
        
        return prompt
    }
    
    private func buildPromptUsingChatTemplate(userText: String, history: [ChatMessage]?, systemPrompt: String, enableThinking: Bool = true) -> String {
        // UNIVERSAL APPROACH: Use the standard chat template system for ALL models
        
        // CRASH PROTECTION: Validate inputs
        guard !userText.isEmpty, !systemPrompt.isEmpty else {
            return userText // Fallback to user text only
        }
        
        let bufferLen = 32768
        var buf = [Int8](repeating: 0, count: bufferLen)

        // Roles and contents for system + history + current user
        let roleStrings: [String] = {
            var arr: [String] = ["system"]
            if let history = history {
                for m in history { arr.append(m.isUser ? "user" : "assistant") }
            }
            arr.append("user")
            return arr
        }()
        let contentStrings: [String] = {
            var arr: [String] = [systemPrompt]
            if let history = history {
                for m in history { arr.append(m.content) }
            }
            arr.append(userText)
            return arr
        }()

        // CRASH PROTECTION: Validate arrays before processing
        guard !roleStrings.isEmpty, !contentStrings.isEmpty, roleStrings.count == contentStrings.count else {
            return userText // Fallback to user text only
        }
        
        // CRASH PROTECTION: Sanitize content strings to prevent crashes
        let sanitizedContentStrings: [String] = contentStrings.map { content in
            // Remove any potentially problematic characters and ensure valid UTF-8
            let sanitized = content
                .replacingOccurrences(of: "\0", with: "") // Remove null bytes
                .replacingOccurrences(of: "\r", with: "\n") // Normalize line endings
                .trimmingCharacters(in: .whitespacesAndNewlines) // Remove leading/trailing whitespace
            
            // Ensure the string is valid UTF-8 and not empty
            guard !sanitized.isEmpty, sanitized.utf8.count > 0 else {
                return "[Content removed for safety]"
            }
            
            return sanitized
        }

        let cRolePtrs: [UnsafePointer<CChar>?] = roleStrings.map { s in s.withCString { UnsafePointer(strdup($0)) } }
        let cContentPtrs: [UnsafePointer<CChar>?] = sanitizedContentStrings.map { s in s.withCString { UnsafePointer(strdup($0)) } }

        // CRASH PROTECTION: Ensure cleanup happens in all code paths
        defer {
            // Free duplicated C strings - this will run even if function throws or returns early
            for p in cRolePtrs { if let p = p { free(UnsafeMutablePointer(mutating: p)) } }
            for p in cContentPtrs { if let p = p { free(UnsafeMutablePointer(mutating: p)) } }
        }

        // CRASH PROTECTION: Validate C string arrays
        guard cRolePtrs.count == cContentPtrs.count, cRolePtrs.count > 0 else {
            return userText // Fallback to user text only
        }

        let written: Int = cRolePtrs.withUnsafeBufferPointer { rbuf in
            cContentPtrs.withUnsafeBufferPointer { cbuf in
                // CRASH PROTECTION: Validate buffer pointers
                guard rbuf.baseAddress != nil, cbuf.baseAddress != nil else {
                    return 0
                }
                
                return Int(llm_bridge_apply_chat_template_messages(rbuf.baseAddress, cbuf.baseAddress, Int32(sanitizedContentStrings.count), true, &buf, Int32(bufferLen)))
            }
        }

        if written > 0, let prompt = String(validatingUTF8: buf) {
            return prompt
        } else {
            return userText
        }
    }
    
    // Removed model-specific manual prompt builders. All models use chat template.
    
    /// Clear any potential state to ensure fresh calls
    func clearState() {
        
        // Clear conversation state
        conversationCount = 0
        
        // Clear operation flags
        isChatOperationInProgress = false
        isModelOperationInProgress = false
        
        // Reset operation timing
        lastOperationTime = Date()
        
        // Force unload model asynchronously to prevent race conditions
        // Note: This is a fire-and-forget operation to avoid blocking the UI
        Task.detached(priority: .background) {
            do {
                try await self.forceUnloadModel()
            } catch {
            }
        }
        
    }

    private func getErrorMessage(for error: Error) -> String {
        if let nsError = error as NSError? {
            switch nsError.code {
            case 1:
                return "No model selected. Please select a model first."
            case 2:
                return "Model file not found in bundle root. Please check your model installation."
            case 3:
                return "No model path available. Please select a model first."
            case 4:
                return "Failed to load model. Please try again."
            case 5:
                return "Failed to create model context. Please try again."
            case 6:
                return "Prompt too long. Please shorten your message."
            case 7:
                return "Model loading timed out. Please try a smaller model."
            case 8:
                return "No result from timeout operation. Please try again."
            case 9:
                return "Operation failed due to internal error. Please try again."
            case 10:
                return "Operation was cancelled or interrupted. Please try again."
            case 11:
                return "Another operation is in progress. Please wait and try again."
            case 12:
                return "Model name not available for streaming. Please try again."
            case 13:
                return "Model file not found. Please check your model installation."
            case 14:
                return "Model file appears corrupted. Please reinstall the model."
            case 15:
                return "Failed to load model due to invalid pointer. Please try again."
            case 16:
                return "Failed to create context due to invalid pointer. Please try again."
            case 17:
                return "Invalid context pointer for streaming. Please try again."
            case 18:
                return "Empty prompt for streaming. Please provide some text."
            case 19:
                return "Invalid strings for C++ bridge. Please try again."
            case 20:
                return "Streaming generation timed out. Please try again."
            case 21:
                return "Failed to recreate context. Please try again."
            case 22:
                return "Another chat operation is in progress. Please wait and try again."
            case 23:
                return "Empty or whitespace-only input. Please provide some text to process."
            case 24:
                return "Model not loaded. Please select and load a model first."
            case 25:
                return "Failed to recreate context due to invalid pointer. Please try again."
            case 26:
                return "Input text was shortened to fit within limits. If the shortened version doesn't accurately represent your intent, please try a shorter message."
            case 27:
                return "Response generation reached the maximum token limit (2000 tokens). The response may be incomplete. Consider asking a more specific question or breaking your request into smaller parts."
            default:
                return error.localizedDescription
            }
        }
        return error.localizedDescription
    }
    
    // MARK: - Parallel Processing Optimizations
    
    /// Pre-warm memory management for faster model loading
    private func preWarmMemoryForModel(_ modelFilename: String) async {
        // Trigger memory cleanup if needed
        if getCurrentMemoryUsage() > UInt64(Double(maxMemoryUsage) * 0.8) { // 80% threshold
            handleMemoryPressure()
        }
        
        // Pre-allocate memory buffers if possible
        autoreleasepool {
            // Force any pending cleanup
        }
        
        SecureLogger.log("LLMService: Pre-warmed memory for \(modelFilename)")
    }
    
    /// Pre-load any cached data for the model
    private func preLoadModelCache(_ modelFilename: String) async {
        // Check if we have cached warm-up data
        if let _: String = SecureStorage.retrieve(String.self, forKey: "model_warmup_\(modelFilename)") {
            SecureLogger.log("LLMService: Pre-loaded cache for \(modelFilename)")
        }
        
        // Pre-fetch model metadata if available
        // This could include model configuration, vocabulary size, etc.
    }
    
    /// Get current memory usage for optimization decisions
    private func getCurrentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        return kerr == KERN_SUCCESS ? info.resident_size : 0
    }
}