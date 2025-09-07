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
    private let maxConcurrentTasks = 3
    private let taskQueue = DispatchQueue(label: "com.controlllm.backgroundtasks", attributes: .concurrent)
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
        return taskQueue.sync {
            // Check if we've reached the limit
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
            for (taskId, backgroundTaskId) in self.activeTasks {
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
        // Monitor app state changes
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppEnteredBackground()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppWillEnterForeground()
        }
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
}
