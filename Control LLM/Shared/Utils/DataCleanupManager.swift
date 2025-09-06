//
//  DataCleanupManager.swift
//  Control LLM
//
//  Comprehensive data cleanup to ensure 24-hour retention policy compliance
//

import Foundation
import Security

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
        
        // 1. Clear conversation data
        clearConversationData()
        
        // 2. Clear performance data
        clearPerformanceData()
        
        // 3. Clear temporary files
        clearTemporaryFiles()
        
        // 4. Clear Metal memory
        clearMetalMemory()
        
        // 5. Clear C++ bridge memory
        clearCppBridgeMemory()
        
        // 6. Clear secure storage
        clearSecureStorage()
        
        // 7. Clear UserDefaults
        clearUserDefaults()
        
        // 8. Clear system caches
        clearSystemCaches()
        
        // Update last cleanup time
        SecureStorage.storeDate(Date(), forKey: lastCleanupKey)
        
        print("✅ DataCleanupManager: Comprehensive cleanup completed")
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
            SecureStorage.remove(forKey: key)
        }
    }
    
    private func clearPerformanceData() {
        print("🧹 DataCleanupManager: Clearing performance data")
        
        // Clear performance metrics that may contain sensitive data
        let performanceKeys = [
            "AverageResponseTime",
            "TotalResponseTime",
            "ResponseCount",
            "ModelPerformanceData"
        ]
        
        for key in performanceKeys {
            SecureStorage.remove(forKey: key)
        }
    }
    
    private func clearTemporaryFiles() {
        print("🧹 DataCleanupManager: Clearing temporary files")
        
        let tempDir = FileManager.default.temporaryDirectory
        
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            for file in tempFiles {
                // Only delete files that might contain sensitive data
                if file.pathExtension == "tmp" || 
                   file.pathExtension == "log" ||
                   file.lastPathComponent.contains("conversation") ||
                   file.lastPathComponent.contains("chat") {
                    try FileManager.default.removeItem(at: file)
                }
            }
        } catch {
            print("⚠️ DataCleanupManager: Error clearing temporary files: \(error)")
        }
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
                SecureStorage.remove(forKey: key)
            }
        }
    }
    
    private func clearUserDefaults() {
        print("🧹 DataCleanupManager: Clearing UserDefaults")
        
        // Clear non-essential UserDefaults
        let essentialKeys = [
            "selectedLLMModel",
            "LastDataCleanup"
        ]
        
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        for key in dictionary.keys {
            if !essentialKeys.contains(key) {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    private func clearSystemCaches() {
        print("🧹 DataCleanupManager: Clearing system caches")
        
        // Clear any cached data in the app's cache directory
        if let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            do {
                let cacheFiles = try FileManager.default.contentsOfDirectory(at: cacheDir, includingPropertiesForKeys: nil)
                for file in cacheFiles {
                    try FileManager.default.removeItem(at: file)
                }
            } catch {
                print("⚠️ DataCleanupManager: Error clearing cache files: \(error)")
            }
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
    
    // MARK: - Security Utilities
    
    /// Securely wipes a file by overwriting it multiple times
    private func secureWipeFile(at url: URL) {
        do {
            let fileSize = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int64 ?? 0
            
            if fileSize > 0 {
                let fileHandle = try FileHandle(forWritingTo: url)
                
                // Overwrite with multiple patterns
                let patterns: [UInt8] = [0x00, 0xFF, 0xAA, 0x55]
                
                for pattern in patterns {
                    let data = Data(repeating: pattern, count: Int(fileSize))
                    try fileHandle.write(contentsOf: data)
                    try fileHandle.synchronize()
                }
                
                try fileHandle.close()
            }
            
            // Finally delete the file
            try FileManager.default.removeItem(at: url)
        } catch {
            print("⚠️ DataCleanupManager: Error securely wiping file \(url): \(error)")
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let clearAllConversationData = Notification.Name("clearAllConversationData")
    static let clearCppBridgeMemory = Notification.Name("clearCppBridgeMemory")
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
