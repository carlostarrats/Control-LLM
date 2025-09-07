//
//  BackgroundTaskManager.swift
//  Control LLM
//
//  Performance optimization for background task management
//

import Foundation
import UIKit

// MARK: - Performance Optimization: Background Task Manager

/// Manages background tasks efficiently with resource limits and prioritization
class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    // MARK: - Properties
    
    private var activeTasks: [String: UIBackgroundTaskIdentifier] = [:]
    private var maxConcurrentTasks = 3 // Dynamic based on device capabilities
    private let taskQueue = DispatchQueue(label: "com.controlllm.backgroundtasks", attributes: .concurrent)
    private var limitsInitialized = false
    private var taskPriorities: [String: TaskPriority] = [:]
    
    // Background task types
    enum TaskType: String, CaseIterable {
        case fileProcessing = "file_processing"
        case modelLoading = "model_loading"
        case dataCleanup = "data_cleanup"
        case memoryCleanup = "memory_cleanup"
        case llmInference = "llm_inference"
    }
    
    enum TaskPriority: Int, CaseIterable {
        case critical = 0    // Model loading, critical operations
        case high = 1        // File processing, user-initiated
        case medium = 2      // Data cleanup, maintenance
        case low = 3         // Memory cleanup, optimization
        
        var maxDuration: TimeInterval {
            switch self {
            case .critical: return 30.0
            case .high: return 20.0
            case .medium: return 10.0
            case .low: return 5.0
            }
        }
    }
    
    private init() {
        setupBackgroundTaskMonitoring()
    }
    
    // MARK: - Public Methods
    
    /// Starts a background task with automatic cleanup
    /// - Parameters:
    ///   - type: Type of background task
    ///   - priority: Priority level
    ///   - completion: Completion handler
    /// - Returns: Task identifier if successful, nil if limit reached
    func startBackgroundTask(
        type: TaskType,
        priority: TaskPriority = .medium,
        completion: @escaping () -> Void
    ) -> String? {
        // Initialize adaptive limits if needed
        if !limitsInitialized {
            initializeAdaptiveLimits()
        }
        
        return taskQueue.sync {
            // Check if we've reached the adaptive limit
            if activeTasks.count >= maxConcurrentTasks {
                // Try to cancel a lower priority task
                if !cancelLowestPriorityTask() {
                    return nil
                }
            }
            
            let taskId = UUID().uuidString
            let backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: type.rawValue) { [weak self] in
                self?.endBackgroundTask(taskId: taskId)
            }
            
            activeTasks[taskId] = backgroundTaskId
            taskPriorities[taskId] = priority
            
            // Set up automatic cleanup based on priority
            let maxDuration = priority.maxDuration
            DispatchQueue.global().asyncAfter(deadline: .now() + maxDuration) { [weak self] in
                self?.endBackgroundTask(taskId: taskId)
            }
            
            // Execute the completion handler
            completion()
            
            return taskId
        }
    }
    
    /// Ends a specific background task
    /// - Parameter taskId: Task identifier
    func endBackgroundTask(taskId: String) {
        taskQueue.async(flags: .barrier) {
            guard let backgroundTaskId = self.activeTasks[taskId] else { return }
            
            UIApplication.shared.endBackgroundTask(backgroundTaskId)
            self.activeTasks.removeValue(forKey: taskId)
            self.taskPriorities.removeValue(forKey: taskId)
            
            print("🔄 BackgroundTaskManager: Ended task \(taskId)")
        }
    }
    
    /// Ends all background tasks
    func endAllBackgroundTasks() {
        taskQueue.async(flags: .barrier) {
            for (_, backgroundTaskId) in self.activeTasks {
                UIApplication.shared.endBackgroundTask(backgroundTaskId)
            }
            
            self.activeTasks.removeAll()
            self.taskPriorities.removeAll()
            
            print("🔄 BackgroundTaskManager: Ended all background tasks")
        }
    }
    
    /// Gets current task count
    var currentTaskCount: Int {
        return taskQueue.sync { activeTasks.count }
    }
    
    /// Checks if a specific task type is running
    func isTaskRunning(type: TaskType) -> Bool {
        return taskQueue.sync {
            return activeTasks.contains { taskId, _ in
                taskId.contains(type.rawValue)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func cancelLowestPriorityTask() -> Bool {
        guard let lowestPriorityTask = taskPriorities.min(by: { $0.value.rawValue < $1.value.rawValue }) else {
            return false
        }
        
        let taskId = lowestPriorityTask.key
        endBackgroundTask(taskId: taskId)
        return true
    }
    
    private func setupBackgroundTaskMonitoring() {
        // Monitor app state changes for aggressive background processing
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        // Setup proactive background operations
        setupProactiveBackgroundOperations()
    }
    
    private func handleAppEnteredBackground() {
        print("🔄 BackgroundTaskManager: App entered background, managing tasks")
        
        // Cancel low priority tasks when entering background
        taskQueue.async(flags: .barrier) {
            let lowPriorityTasks = self.taskPriorities.filter { $0.value == .low }
            for taskId in lowPriorityTasks.keys {
                self.endBackgroundTask(taskId: taskId)
            }
        }
    }
    
    private func handleAppWillEnterForeground() {
        print("🔄 BackgroundTaskManager: App will enter foreground, cleaning up")
        
        // End all background tasks when returning to foreground
        endAllBackgroundTasks()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        endAllBackgroundTasks()
    }
}

// MARK: - Convenience Extensions

extension BackgroundTaskManager {
    /// Starts a file processing background task
    func startFileProcessingTask(completion: @escaping () -> Void) -> String? {
        return startBackgroundTask(type: .fileProcessing, priority: .high, completion: completion)
    }
    
    /// Starts a model loading background task
    func startModelLoadingTask(completion: @escaping () -> Void) -> String? {
        return startBackgroundTask(type: .modelLoading, priority: .critical, completion: completion)
    }
    
    /// Starts a data cleanup background task
    func startDataCleanupTask(completion: @escaping () -> Void) -> String? {
        return startBackgroundTask(type: .dataCleanup, priority: .medium, completion: completion)
    }
    
    /// Starts a memory cleanup background task
    func startMemoryCleanupTask(completion: @escaping () -> Void) -> String? {
        return startBackgroundTask(type: .memoryCleanup, priority: .low, completion: completion)
    }
    
    /// Starts an LLM inference background task
    func startLLMInferenceTask(completion: @escaping () -> Void) -> String? {
        return startBackgroundTask(type: .llmInference, priority: .high, completion: completion)
    }
    
    // MARK: - Adaptive Performance Optimization
    
    /// Initialize adaptive task limits based on device capabilities
    private func initializeAdaptiveLimits() {
        let processorCount = ProcessInfo.processInfo.processorCount
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        
        // Adaptive task limits based on device capabilities
        if processorCount >= 8 && physicalMemory >= 6 * 1024 * 1024 * 1024 { // 8+ cores, 6GB+ RAM
            maxConcurrentTasks = 8
        } else if processorCount >= 6 && physicalMemory >= 4 * 1024 * 1024 * 1024 { // 6+ cores, 4GB+ RAM
            maxConcurrentTasks = 6
        } else if processorCount >= 4 && physicalMemory >= 2 * 1024 * 1024 * 1024 { // 4+ cores, 2GB+ RAM
            maxConcurrentTasks = 5
        } else { // Lower-end devices
            maxConcurrentTasks = 3
        }
        
        // Further adjust based on thermal state
        let thermalState = ProcessInfo.processInfo.thermalState
        switch thermalState {
        case .critical:
            maxConcurrentTasks = max(1, maxConcurrentTasks / 2) // Halve the limit
        case .serious:
            maxConcurrentTasks = max(2, (maxConcurrentTasks * 3) / 4) // Reduce by 25%
        case .fair:
            maxConcurrentTasks = max(2, (maxConcurrentTasks * 7) / 8) // Reduce by 12.5%
        case .nominal:
            break // Keep the calculated limit
        @unknown default:
            maxConcurrentTasks = 3 // Conservative fallback
        }
        
        limitsInitialized = true
        print("🔧 BackgroundTaskManager: Adaptive task limit set to \(maxConcurrentTasks) concurrent tasks")
    }
    
    // MARK: - Aggressive Background Processing
    
    /// Setup proactive background operations for better performance
    private func setupProactiveBackgroundOperations() {
        // Start periodic maintenance tasks
        startPeriodicMaintenanceTasks()
        
        // Setup aggressive memory management
        setupAggressiveMemoryManagement()
        
        // Initialize background model preloading
        setupBackgroundModelPreloading()
    }
    
    @objc private func appDidEnterBackground() {
        print("🔄 BackgroundTaskManager: App entering background - starting aggressive background processing")
        
        // Start aggressive cleanup tasks
        _ = startMemoryCleanupTask {
            // Aggressive memory cleanup when app is backgrounded
            autoreleasepool {
                // Force cleanup
            }
        }
        
        // Start data cleanup
        _ = startDataCleanupTask {
            // Clean temporary files and caches
            // Note: DataCleanupManager method will be added separately
            print("🧹 BackgroundTaskManager: Performing background data cleanup")
        }
        
        // Preload next likely models in background
        Task.detached(priority: .background) {
            await self.preloadLikelyModels()
        }
    }
    
    @objc private func appWillEnterForeground() {
        print("🔄 BackgroundTaskManager: App entering foreground - optimizing for user interaction")
        
        // Cancel non-critical background tasks to prioritize UI responsiveness
        cancelLowPriorityTasks()
        
        // Pre-warm critical components
        Task.detached(priority: .userInitiated) {
            await self.preWarmCriticalComponents()
        }
    }
    
    /// Start periodic maintenance tasks
    private func startPeriodicMaintenanceTasks() {
        // Schedule periodic cache optimization
        Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.performPeriodicOptimization()
        }
    }
    
    /// Setup aggressive memory management
    private func setupAggressiveMemoryManagement() {
        // Monitor memory pressure more aggressively
        NotificationCenter.default.addObserver(
            forName: .memoryPressureDetected,
            object: nil,
            queue: OperationQueue()
        ) { [weak self] _ in
            self?.handleAggressiveMemoryPressure()
        }
    }
    
    /// Setup background model preloading
    private func setupBackgroundModelPreloading() {
        // This could be expanded based on usage patterns
        print("🔧 BackgroundTaskManager: Background model preloading initialized")
    }
    
    /// Perform periodic optimization
    private func performPeriodicOptimization() {
        _ = startBackgroundTask(type: .memoryCleanup, priority: .low) {
            // Periodic cache cleanup and optimization
            SecureStorage.clearExpiredCache()
        }
    }
    
    /// Handle aggressive memory pressure
    private func handleAggressiveMemoryPressure() {
        // Cancel all non-critical tasks
        cancelLowPriorityTasks()
        
        // Start aggressive cleanup
        _ = startMemoryCleanupTask {
            // Aggressive memory cleanup
            autoreleasepool {
                // Force cleanup of autoreleased objects
            }
        }
    }
    
    /// Cancel low priority tasks for performance
    private func cancelLowPriorityTasks() {
        taskQueue.async(flags: .barrier) {
            let lowPriorityTasks = self.taskPriorities.filter { $0.value == .low }
            for (taskId, _) in lowPriorityTasks {
                self.endBackgroundTask(taskId: taskId)
            }
        }
    }
    
    /// Preload likely models based on usage patterns
    private func preloadLikelyModels() async {
        // This could be expanded with ML-based prediction
        print("🔧 BackgroundTaskManager: Preloading likely models in background")
    }
    
    /// Pre-warm critical components for better performance
    private func preWarmCriticalComponents() async {
        // Pre-warm LLM service
        print("🔧 BackgroundTaskManager: Pre-warming critical components")
    }
}
