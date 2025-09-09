//
//  DataCleanupManager.swift
//  Control LLM
//
//  Comprehensive data cleanup to ensure 24-hour retention policy compliance
//

import Foundation
import Security

// MARK: - Notification Names
extension Notification.Name {
    static let clearAllConversationData = Notification.Name("clearAllConversationData")
    static let clearPerformanceData = Notification.Name("clearPerformanceData")
    static let clearCppBridgeMemory = Notification.Name("clearCppBridgeMemory")
    static let clearCoreDataCache = Notification.Name("clearCoreDataCache")
    static let clearSystemCaches = Notification.Name("clearSystemCaches")
}

/// Manages comprehensive data cleanup to ensure 24-hour retention policy compliance
class DataCleanupManager {
    static let shared = DataCleanupManager()
    
    private let cleanupInterval: TimeInterval = 24 * 60 * 60 // 24 hours
    private let lastCleanupKey = "LastDataCleanup"
    private var cleanupTimer: Timer?
    
    // PERFORMANCE OPTIMIZATION: Incremental cleanup system
    private var incrementalCleanupManager: IncrementalCleanupManager?
    
    private init() {
        setupCleanupTimer()
        initializeIncrementalCleanup()
    }
    
    private func initializeIncrementalCleanup() {
        // PERFORMANCE OPTIMIZATION: Initialize incremental cleanup system
        incrementalCleanupManager = IncrementalCleanupManager()
    }
    
    deinit {
        cleanupTimer?.invalidate()
    }
    
    // MARK: - Setup
    
    private func setupCleanupTimer() {
        // Set up timer for regular cleanup checks (don't run cleanup on startup)
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.checkAndPerformCleanup()
        }
    }
    
    // MARK: - Cleanup Management
    
    /// Checks if cleanup is needed and performs it
    func checkAndPerformCleanup() {
        // Only run cleanup if we have a previous cleanup timestamp and 24 hours have passed
        guard let lastCleanup = SecureStorage.retrieveDate(forKey: lastCleanupKey) else {
            // No previous cleanup timestamp - set one but don't run cleanup yet
            SecureStorage.storeDate(Date(), forKey: lastCleanupKey)
            return
        }
        
        let timeSinceLastCleanup = Date().timeIntervalSince(lastCleanup)
        
        if timeSinceLastCleanup >= cleanupInterval {
            performComprehensiveCleanup()
        } else {
            // PERFORMANCE OPTIMIZATION: Schedule incremental cleanup for better performance
            scheduleIncrementalCleanup()
        }
    }
    
    /// Schedule incremental cleanup for better performance
    func scheduleIncrementalCleanup() {
        incrementalCleanupManager?.scheduleIncrementalCleanup()
    }
    
    /// Performs comprehensive data cleanup
    func performComprehensiveCleanup() {
        
        // PERFORMANCE OPTIMIZATION: Use background task for cleanup
        let taskId = BackgroundTaskManager.shared.startDataCleanupTask {
            // 1. Clear conversation data
            self.clearConversationData()
            
            // 2. Clear performance data
            self.clearPerformanceData()
            
            // 3. Clear temporary files
            self.clearTemporaryFiles()
            
            // 4. Clear Metal memory
            self.clearMetalMemory()
            
            // 5. Clear C++ bridge memory
            self.clearCppBridgeMemory()
            
            // 6. Clear secure storage
            self.clearSecureStorage()
            
            // 7. Clear UserDefaults
            self.clearUserDefaults()
            
            // 8. Clear system caches
            self.clearSystemCaches()
            
            // Update last cleanup time
            SecureStorage.storeDate(Date(), forKey: self.lastCleanupKey)
            
        }
        
        // End the background task after completion
        if let taskId = taskId {
            BackgroundTaskManager.shared.endBackgroundTask(taskId: taskId)
        }
        
        if taskId == nil {
            // Fallback to immediate cleanup if background task unavailable
            performImmediateCleanup()
        }
    }
    
    // MARK: - Specific Cleanup Methods
    
    private func clearConversationData() {
        
        // Clear ChatViewModel data
        NotificationCenter.default.post(name: .clearAllConversationData, object: nil)
        
        // Clear any cached conversation data
        let conversationKeys = [
            "messageHistory",
            "transcript",
            "lastSentMessage",
            "conversationCount"
        ]
        
        for key in conversationKeys {
            do {
                SecureStorage.remove(forKey: key)
                SecureLogger.log("DataCleanupManager: Removed conversation key: \(key)")
            } catch {
                SecureLogger.logError(error, context: "DataCleanupManager: Failed to remove conversation key: \(key)")
            }
        }
    }
    
    private func clearPerformanceData() {
        
        // Clear performance tracking data
        let performanceKeys = [
            "totalResponseTime",
            "responseCount", 
            "averageResponseDuration",
            "modelPerformanceData",
            "lastResponseTime"
        ]
        
        for key in performanceKeys {
            do {
                SecureStorage.remove(forKey: key)
                SecureLogger.log("DataCleanupManager: Removed performance key: \(key)")
            } catch {
                SecureLogger.logError(error, context: "DataCleanupManager: Failed to remove performance key: \(key)")
            }
        }
        
        // Clear any cached performance metrics
        NotificationCenter.default.post(name: .clearPerformanceData, object: nil)
        
    }
    
    private func clearTemporaryFiles() {
        
        let tempDir = FileManager.default.temporaryDirectory
        
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            for file in tempFiles {
                try FileManager.default.removeItem(at: file)
                SecureLogger.log("DataCleanupManager: Removed temporary file: \(file.lastPathComponent)")
            }
        } catch {
            SecureLogger.logError(error, context: "DataCleanupManager: Failed to clear temporary files")
        }
        
        // Clear app-specific temp directory
        if let appTempDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            do {
                let cacheFiles = try FileManager.default.contentsOfDirectory(at: appTempDir, includingPropertiesForKeys: nil)
                for file in cacheFiles {
                    try FileManager.default.removeItem(at: file)
                    SecureLogger.log("DataCleanupManager: Removed cache file: \(file.lastPathComponent)")
                }
            } catch {
                SecureLogger.logError(error, context: "DataCleanupManager: Failed to clear cache files")
            }
        }
        
    }
    
    private func clearMetalMemory() {
        MetalMemoryManager.shared.performSecurityCleanup()
    }
    
    private func clearCppBridgeMemory() {
        
        // Call the C++ bridge reset context function to clear memory
        llm_bridge_reset_context(nil)
        
        // Also post notification for any other cleanup handlers
        NotificationCenter.default.post(name: .clearCppBridgeMemory, object: nil)
    }
    
    private func clearSecureStorage() {
        
        // Clear all secure storage except essential app data
        let essentialKeys = [
            "LastDataCleanup",
            "selectedLLMModel",
            "AppSessionStartTime"
        ]
        
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        for key in dictionary.keys {
            if key.hasPrefix("Secure_") && !essentialKeys.contains(key) {
                do {
                    SecureStorage.remove(forKey: key)
                    SecureLogger.log("DataCleanupManager: Removed secure storage key: \(key)")
                } catch {
                    SecureLogger.logError(error, context: "DataCleanupManager: Failed to remove secure storage key: \(key)")
                }
            }
        }
    }
    
    private func clearUserDefaults() {
        
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        // Clear all non-essential UserDefaults
        let essentialKeys = [
            "LastDataCleanup",
            "selectedLLMModel",
            "AppSessionStartTime",
            "NSUbiquitousKeyValueStore"
        ]
        
        for key in dictionary.keys {
            if !essentialKeys.contains(key) {
                defaults.removeObject(forKey: key)
                SecureLogger.log("DataCleanupManager: Removed UserDefaults key: \(key)")
            }
        }
        
        // Force synchronization
        defaults.synchronize()
        
    }
    
    private func clearSystemCaches() {
        
        // Clear URL cache
        URLCache.shared.removeAllCachedResponses()
        
        // Clear image cache
        if let imageCache = URLCache.shared as? URLCache {
            imageCache.removeAllCachedResponses()
        }
        
        // Clear any Core Data caches
        NotificationCenter.default.post(name: .clearCoreDataCache, object: nil)
        
        // Clear any other system caches
        NotificationCenter.default.post(name: .clearSystemCaches, object: nil)
        
    }
    
    // MARK: - Helper Methods
    
    /// Securely wipes a file by overwriting it with random data
    private func secureWipeFile(at url: URL) {
        do {
            // Read file data
            let data = try Data(contentsOf: url)
            
            // Overwrite with random data multiple times
            for _ in 0..<3 {
                let randomData = Data((0..<data.count).map { _ in UInt8.random(in: 0...255) })
                try randomData.write(to: url)
            }
            
            // Delete the file
            try FileManager.default.removeItem(at: url)
            
            SecureLogger.log("DataCleanupManager: Securely wiped file: \(url.lastPathComponent)")
        } catch {
            SecureLogger.logError(error, context: "DataCleanupManager: Failed to securely wipe file: \(url.lastPathComponent)")
        }
    }
    
    // MARK: - Manual Cleanup
    
    /// Performs immediate cleanup (for testing or manual triggers)
    func performImmediateCleanup() {
        performComprehensiveCleanup()
    }
    
    /// Clears all data immediately (for app reset)
    func clearAllData() {
        
        // Clear everything
        SecureStorage.clearAll()
        
        // Clear UserDefaults
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        for key in dictionary.keys {
            defaults.removeObject(forKey: key)
        }
        
        // Clear temporary files
        clearTemporaryFiles()
        
        // Clear Metal memory
        clearMetalMemory()
        
        // Clear system caches
        clearSystemCaches()
        
    }
    
}

// MARK: - ChatViewModel Integration

extension ChatViewModel {
    /// Clears all conversation data when cleanup is requested
    func clearAllConversationData() {
        DispatchQueue.main.async {
            self.transcript = ""
            self.messageHistory = []
            self.lastSentMessage = nil
            // Conversation count will be reset by ChatViewModel's clearAllConversationData method
            
            // Clear any cached data (handled by ChatViewModel's clearAllConversationData method)
            
        }
    }
}

// MARK: - Performance Optimization: Incremental Cleanup System

/// Manages incremental cleanup tasks with prioritization and queuing
class IncrementalCleanupManager {
    private var taskQueue: [CleanupTask] = []
    private let maxCleanupTasks = 10
    private let cleanupQueue = DispatchQueue(label: "com.controlllm.cleanup.incremental", attributes: .concurrent)
    private var isProcessing = false
    
    enum CleanupTaskType: String, CaseIterable {
        case conversationData = "conversation_data"
        case temporaryFiles = "temporary_files"
        case metalMemory = "metal_memory"
        case cppBridgeMemory = "cpp_bridge_memory"
        case secureStorage = "secure_storage"
        case userDefaults = "user_defaults"
        case systemCaches = "system_caches"
    }
    
    enum TaskPriority: Int, CaseIterable, Comparable {
        case low = 0
        case medium = 1
        case high = 2
        
        static func < (lhs: TaskPriority, rhs: TaskPriority) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
    
    struct CleanupTask {
        let id: String
        let type: CleanupTaskType
        let priority: TaskPriority
        let createdAt: Date
        let estimatedDuration: TimeInterval
        
        init(type: CleanupTaskType, priority: TaskPriority) {
            self.id = UUID().uuidString
            self.type = type
            self.priority = priority
            self.createdAt = Date()
            self.estimatedDuration = Self.estimatedDuration(for: type)
        }
        
        private static func estimatedDuration(for type: CleanupTaskType) -> TimeInterval {
            switch type {
            case .conversationData: return 2.0
            case .temporaryFiles: return 1.0
            case .metalMemory: return 0.5
            case .cppBridgeMemory: return 0.5
            case .secureStorage: return 1.5
            case .userDefaults: return 0.3
            case .systemCaches: return 3.0
            }
        }
    }
    
    /// Schedule incremental cleanup tasks
    func scheduleIncrementalCleanup() {
        cleanupQueue.async(flags: .barrier) {
            guard !self.isProcessing else { return }
            
            let tasks = [
                CleanupTask(type: .conversationData, priority: .high),
                CleanupTask(type: .temporaryFiles, priority: .medium),
                CleanupTask(type: .metalMemory, priority: .low),
                CleanupTask(type: .cppBridgeMemory, priority: .low),
                CleanupTask(type: .secureStorage, priority: .medium),
                CleanupTask(type: .userDefaults, priority: .low),
                CleanupTask(type: .systemCaches, priority: .high)
            ]
            
            // Add tasks to queue, avoiding duplicates
            for task in tasks {
                if !self.taskQueue.contains(where: { $0.type == task.type }) {
                    self.taskQueue.append(task)
                }
            }
            
            // Sort by priority (high first)
            self.taskQueue.sort { $0.priority > $1.priority }
            
            self.processNextCleanupTask()
        }
    }
    
    private func processNextCleanupTask() {
        cleanupQueue.async(flags: .barrier) {
            guard !self.isProcessing, !self.taskQueue.isEmpty else { return }
            
            self.isProcessing = true
            let task = self.taskQueue.removeFirst()
            
            
            Task.detached(priority: .background) {
                await self.executeCleanupTask(task)
                
                // Schedule next task after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.cleanupQueue.async(flags: .barrier) {
                        self.isProcessing = false
                        self.processNextCleanupTask()
                    }
                }
            }
        }
    }
    
    private func executeCleanupTask(_ task: CleanupTask) async {
        let startTime = Date()
        
        switch task.type {
        case .conversationData:
            await clearConversationDataIncremental()
        case .temporaryFiles:
            await clearTemporaryFilesIncremental()
        case .metalMemory:
            await clearMetalMemoryIncremental()
        case .cppBridgeMemory:
            await clearCppBridgeMemoryIncremental()
        case .secureStorage:
            await clearSecureStorageIncremental()
        case .userDefaults:
            await clearUserDefaultsIncremental()
        case .systemCaches:
            await clearSystemCachesIncremental()
        }
        
        let duration = Date().timeIntervalSince(startTime)
    }
    
    // MARK: - Incremental Cleanup Methods
    
    private func clearConversationDataIncremental() async {
        // Clear conversation data in smaller chunks
        NotificationCenter.default.post(name: .clearAllConversationData, object: nil)
    }
    
    private func clearTemporaryFilesIncremental() async {
        // Clear temporary files incrementally
        let tempDir = FileManager.default.temporaryDirectory
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: [.creationDateKey], options: [])
            let oldFiles = tempFiles.filter { url in
                if let creationDate = try? url.resourceValues(forKeys: [.creationDateKey]).creationDate {
                    return Date().timeIntervalSince(creationDate) > 3600 // 1 hour
                }
                return false
            }
            
            for file in oldFiles.prefix(10) { // Process max 10 files at a time
                try? FileManager.default.removeItem(at: file)
            }
        } catch {
        }
    }
    
    private func clearMetalMemoryIncremental() async {
        // Clear Metal memory incrementally
        MetalMemoryManager.shared.clearMetalMemory()
    }
    
    private func clearCppBridgeMemoryIncremental() async {
        // Clear C++ bridge memory incrementally
        NotificationCenter.default.post(name: .clearCppBridgeMemory, object: nil)
    }
    
    private func clearSecureStorageIncremental() async {
        // Clear secure storage incrementally (only old cache entries)
        SecureStorage.clearCache()
    }
    
    private func clearUserDefaultsIncremental() async {
        // Clear UserDefaults incrementally (only non-essential keys)
        let keysToRemove = ["tempCache", "debugFlags", "performanceMetrics"]
        for key in keysToRemove {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    private func clearSystemCachesIncremental() async {
        // Clear system caches incrementally
        NotificationCenter.default.post(name: .clearSystemCaches, object: nil)
    }
}
