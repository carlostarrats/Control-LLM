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
    
    private init() {
        setupCleanupTimer()
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
        }
    }
    
    /// Performs comprehensive data cleanup
    func performComprehensiveCleanup() {
        print("🧹 DataCleanupManager: Starting comprehensive data cleanup")
        
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
            
            print("✅ DataCleanupManager: Comprehensive cleanup completed")
        }
        
        // End the background task after completion
        if let taskId = taskId {
            BackgroundTaskManager.shared.endBackgroundTask(taskId: taskId)
        }
        
        if taskId == nil {
            print("⚠️ DataCleanupManager: Could not start background task, performing cleanup on main thread")
            // Fallback to immediate cleanup if background task unavailable
            performImmediateCleanup()
        }
    }
    
    // MARK: - Specific Cleanup Methods
    
    private func clearConversationData() {
        print("🧹 DataCleanupManager: Clearing conversation data")
        
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
        print("🧹 DataCleanupManager: Clearing performance data")
        
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
        
        print("✅ DataCleanupManager: Performance data cleared")
    }
    
    private func clearTemporaryFiles() {
        print("🧹 DataCleanupManager: Clearing temporary files")
        
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
        
        print("✅ DataCleanupManager: Temporary files cleared")
    }
    
    private func clearMetalMemory() {
        print("🧹 DataCleanupManager: Clearing Metal memory")
        MetalMemoryManager.shared.performSecurityCleanup()
    }
    
    private func clearCppBridgeMemory() {
        print("🧹 DataCleanupManager: Clearing C++ bridge memory")
        
        // Call the C++ bridge reset context function to clear memory
        llm_bridge_reset_context(nil)
        
        // Also post notification for any other cleanup handlers
        NotificationCenter.default.post(name: .clearCppBridgeMemory, object: nil)
    }
    
    private func clearSecureStorage() {
        print("🧹 DataCleanupManager: Clearing secure storage")
        
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
        print("🧹 DataCleanupManager: Clearing UserDefaults")
        
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
        
        print("✅ DataCleanupManager: UserDefaults cleared")
    }
    
    private func clearSystemCaches() {
        print("🧹 DataCleanupManager: Clearing system caches")
        
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
        
        print("✅ DataCleanupManager: System caches cleared")
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
        print("🧹 DataCleanupManager: Performing immediate cleanup")
        performComprehensiveCleanup()
    }
    
    /// Clears all data immediately (for app reset)
    func clearAllData() {
        print("🧹 DataCleanupManager: Clearing all data")
        
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
        
        print("✅ DataCleanupManager: All data cleared")
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
            
            print("✅ ChatViewModel: All conversation data cleared")
        }
    }
}
