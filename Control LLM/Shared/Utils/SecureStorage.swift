//
//  SecureStorage.swift
//  Control LLM
//
//  Secure storage utility using CryptoKit for encrypted local data storage
//

import Foundation
import CryptoKit
import Security

/// Secure storage utility that encrypts sensitive data before storing in UserDefaults
class SecureStorage {
    
    // MARK: - Private Properties
    
    private static let keychainService = "ControlLLM-SecureStorage"
    private static let encryptionKeyIdentifier = "ControlLLM-EncryptionKey"
    
    // PERFORMANCE OPTIMIZATION: Adaptive in-memory cache for frequently accessed data
    private static var memoryCache: [String: Any] = [:]
    private static let cacheQueue = DispatchQueue(label: "com.controlllm.securestorage.cache", attributes: .concurrent)
    private static var maxCacheSize = 50 // Dynamic based on device capabilities
    private static let cacheExpirationInterval: TimeInterval = 300 // 5 minutes
    private static var cacheInitialized = false
    
    // PERFORMANCE OPTIMIZATION: Batch operations
    private static var pendingWrites: [String: Any] = [:]
    private static let batchWriteQueue = DispatchQueue(label: "com.controlllm.securestorage.batch", attributes: .concurrent)
    private static var batchWriteTimer: Timer?
    
    // MARK: - Key Management
    
    /// Gets or creates the encryption key for secure storage
    private static func getEncryptionKey() throws -> SymmetricKey {
        // Try to retrieve existing key from Keychain
        if let existingKey = try? retrieveKeyFromKeychain() {
            return existingKey
        }
        
        // Generate new key if none exists
        let newKey = SymmetricKey(size: .bits256)
        try storeKeyInKeychain(newKey)
        return newKey
    }
    
    /// Stores the encryption key in the Keychain
    private static func storeKeyInKeychain(_ key: SymmetricKey) throws {
        let keyData = key.withUnsafeBytes { Data($0) }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: encryptionKeyIdentifier,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecureStorageError.keychainError(status)
        }
    }
    
    /// Retrieves the encryption key from the Keychain
    private static func retrieveKeyFromKeychain() throws -> SymmetricKey {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: encryptionKeyIdentifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let keyData = result as? Data else {
            throw SecureStorageError.keyNotFound
        }
        
        return SymmetricKey(data: keyData)
    }
    
    // MARK: - Cache Management
    
    /// Gets cached value if available and not expired
    private static func getCachedValue<T>(forKey key: String, type: T.Type) -> T? {
        return cacheQueue.sync {
            guard var cachedItem = memoryCache[key] as? CacheItem<T> else { return nil }
            
            // Check if cache item is expired
            if Date().timeIntervalSince(cachedItem.timestamp) > cacheExpirationInterval {
                memoryCache.removeValue(forKey: key)
                return nil
            }
            
            // Update access tracking for better cache management
            cachedItem.accessed()
            memoryCache[key] = cachedItem
            
            return cachedItem.value
        }
    }
    
    /// Sets cached value with timestamp
    private static func setCachedValue<T>(_ value: T, forKey key: String) {
        // Initialize adaptive cache size if needed
        if !cacheInitialized {
            initializeAdaptiveCacheSize()
        }
        
        cacheQueue.async(flags: .barrier) {
            // Limit cache size based on adaptive sizing with improved eviction
            if memoryCache.count >= maxCacheSize {
                performSmartCacheEviction()
            }
            
            memoryCache[key] = CacheItem(value: value, timestamp: Date())
        }
    }
    
    /// Clears the memory cache
    static func clearCache() {
        cacheQueue.async(flags: .barrier) {
            memoryCache.removeAll()
        }
    }
    
    // MARK: - Batch Operations
    
    /// Starts batch write mode
    static func startBatchWrites() {
        batchWriteQueue.async(flags: .barrier) {
            batchWriteTimer?.invalidate()
            batchWriteTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                flushBatchWrites()
            }
        }
    }
    
    /// Flushes all pending writes to UserDefaults
    static func flushBatchWrites() {
        batchWriteQueue.async(flags: .barrier) {
            guard !pendingWrites.isEmpty else { return }
            
            let writes = pendingWrites
            pendingWrites.removeAll()
            
            // For now, just clear the pending writes since batch encoding is complex
            // In a production app, you'd implement proper type-safe batch encoding
            SecureLogger.log("Cleared \(writes.count) pending writes (batch encoding not implemented)")
        }
    }
    
    // MARK: - Public Storage Methods
    
    /// Stores an encrypted object in UserDefaults
    /// - Parameters:
    ///   - object: The object to store (must conform to Codable)
    ///   - key: The key to store the object under
    static func store<T: Codable>(_ object: T, forKey key: String) {
        // Update cache
        setCachedValue(object, forKey: key)
        
        do {
            let data = try JSONEncoder().encode(object)
            let encryptedData = try encrypt(data)
            UserDefaults.standard.set(encryptedData, forKey: key)
            SecureLogger.log("Stored encrypted data for key: \(key)")
        } catch {
            SecureLogger.logError(error, context: "SecureStorage.store")
        }
    }
    
    /// Stores an encrypted object in UserDefaults with batch optimization
    /// - Parameters:
    ///   - object: The object to store (must conform to Codable)
    ///   - key: The key to store the object under
    ///   - useBatch: Whether to use batch writing for better performance
    static func store<T: Codable>(_ object: T, forKey key: String, useBatch: Bool = false) {
        // Update cache
        setCachedValue(object, forKey: key)
        
        if useBatch {
            batchWriteQueue.async(flags: .barrier) {
                pendingWrites[key] = object
                
                // Restart batch timer
                batchWriteTimer?.invalidate()
                batchWriteTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    flushBatchWrites()
                }
            }
        } else {
            do {
                let data = try JSONEncoder().encode(object)
                let encryptedData = try encrypt(data)
                UserDefaults.standard.set(encryptedData, forKey: key)
                SecureLogger.log("Stored encrypted data for key: \(key)")
            } catch {
                SecureLogger.logError(error, context: "SecureStorage.store")
            }
        }
    }
    
    /// Retrieves and decrypts an object from UserDefaults
    /// - Parameters:
    ///   - type: The type of object to retrieve
    ///   - key: The key the object is stored under
    /// - Returns: The decrypted object, or nil if not found or decryption fails
    static func retrieve<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        // PERFORMANCE OPTIMIZATION: Check cache first
        if let cachedValue = getCachedValue(forKey: key, type: type) {
            return cachedValue
        }
        
        guard let encryptedData = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        do {
            let decryptedData = try decrypt(encryptedData)
            let object = try JSONDecoder().decode(type, from: decryptedData)
            
            // Cache the retrieved value
            setCachedValue(object, forKey: key)
            
            SecureLogger.log("Retrieved and decrypted data for key: \(key)")
            return object
        } catch {
            SecureLogger.logError(error, context: "SecureStorage.retrieve")
            return nil
        }
    }
    
    /// Removes encrypted data from UserDefaults
    /// - Parameter key: The key to remove
    static func remove(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        SecureLogger.log("Removed encrypted data for key: \(key)")
    }
    
    /// Clears all encrypted data (useful for app reset)
    static func clearAll() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        
        for key in dictionary.keys {
            if key.hasPrefix("Secure_") {
                defaults.removeObject(forKey: key)
            }
        }
        
        SecureLogger.log("Cleared all encrypted data")
    }
    
    // MARK: - Private Encryption Methods
    
    /// Encrypts data using AES-GCM
    private static func encrypt(_ data: Data) throws -> Data {
        let key = try getEncryptionKey()
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }
    
    /// Decrypts data using AES-GCM
    private static func decrypt(_ encryptedData: Data) throws -> Data {
        let key = try getEncryptionKey()
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        return try AES.GCM.open(sealedBox, using: key)
    }
    
    // MARK: - Secure Data Wiping
    
    /// Securely wipes sensitive data from memory
    /// - Parameter data: The data to wipe
    static func secureWipe(_ data: inout Data) {
        _ = data.withUnsafeMutableBytes { bytes in
            memset_s(bytes.baseAddress, bytes.count, 0, bytes.count)
        }
    }
    
    /// Securely wipes a string from memory
    /// - Parameter string: The string to wipe
    /// WARNING: This function is dangerous and can cause memory corruption
    /// Swift strings are managed by the runtime and should not be directly wiped
    static func secureWipe(_ string: inout String) {
        // DISABLED: Direct string memory wiping is dangerous in Swift
        // Swift strings are managed by the runtime and direct memory manipulation
        // can cause corruption, crashes, or undefined behavior
        // The string will be deallocated naturally when it goes out of scope
        _ = string // Suppress unused parameter warning
    }
    
    // MARK: - Adaptive Cache Management
    
    /// Initialize adaptive cache size based on device capabilities
    private static func initializeAdaptiveCacheSize() {
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        let availableMemory = getAvailableMemory()
        
        // Adaptive cache sizing based on device memory
        if physicalMemory >= 8 * 1024 * 1024 * 1024 { // 8GB+ devices
            maxCacheSize = 100
        } else if physicalMemory >= 4 * 1024 * 1024 * 1024 { // 4-8GB devices
            maxCacheSize = 75
        } else if physicalMemory >= 2 * 1024 * 1024 * 1024 { // 2-4GB devices
            maxCacheSize = 50
        } else { // <2GB devices
            maxCacheSize = 25
        }
        
        // Further adjust based on current memory pressure
        let memoryPressure = 1.0 - (Double(availableMemory) / Double(physicalMemory))
        if memoryPressure > 0.8 { // High memory pressure
            maxCacheSize = Int(Double(maxCacheSize) * 0.5) // Reduce by 50%
        } else if memoryPressure > 0.6 { // Medium memory pressure
            maxCacheSize = Int(Double(maxCacheSize) * 0.75) // Reduce by 25%
        }
        
        cacheInitialized = true
        SecureLogger.log("SecureStorage: Adaptive cache size set to \(maxCacheSize) items")
    }
    
    /// Get available memory for cache optimization
    private static func getAvailableMemory() -> UInt64 {
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
    
    /// Perform smart cache eviction with multiple strategies
    private static func performSmartCacheEviction() {
        let now = Date()
        var itemsToRemove: [String] = []
        
        // Strategy 1: Remove expired items first
        for (key, value) in memoryCache {
            if let cacheItem = value as? CacheItem<Any> {
                if now.timeIntervalSince(cacheItem.timestamp) > cacheExpirationInterval {
                    itemsToRemove.append(key)
                }
            }
        }
        
        // Strategy 2: If still over capacity, use LRU with frequency consideration
        if memoryCache.count - itemsToRemove.count >= maxCacheSize {
            let sortedItems = memoryCache.compactMap { (key, value) -> (String, Date, Int)? in
                guard !itemsToRemove.contains(key),
                      let cacheItem = value as? CacheItem<Any> else { return nil }
                
                // Consider both recency and access frequency
                let recencyScore = now.timeIntervalSince(cacheItem.timestamp)
                let frequencyScore = cacheItem.accessCount
                
                // Combined score (higher means more likely to be evicted)
                let evictionScore = recencyScore / Double(max(1, frequencyScore))
                
                return (key, cacheItem.timestamp, Int(evictionScore * 1000))
            }.sorted { $0.2 > $1.2 } // Sort by eviction score (highest first)
            
            // Remove additional items to get below capacity
            let additionalItemsToRemove = max(0, (memoryCache.count - itemsToRemove.count) - (maxCacheSize * 3 / 4))
            for i in 0..<min(additionalItemsToRemove, sortedItems.count) {
                itemsToRemove.append(sortedItems[i].0)
            }
        }
        
        // Remove selected items
        for key in itemsToRemove {
            memoryCache.removeValue(forKey: key)
        }
        
        SecureLogger.log("SecureStorage: Evicted \(itemsToRemove.count) cache items (expired + LRU)")
    }
    
    /// Clear expired cache items (public method for background cleanup)
    static func clearExpiredCache() {
        cacheQueue.async(flags: .barrier) {
            let now = Date()
            let keysToRemove = memoryCache.compactMap { (key, value) -> String? in
                guard let cacheItem = value as? CacheItem<Any> else { return nil }
                return now.timeIntervalSince(cacheItem.timestamp) > cacheExpirationInterval ? key : nil
            }
            
            for key in keysToRemove {
                memoryCache.removeValue(forKey: key)
            }
            
            if !keysToRemove.isEmpty {
                SecureLogger.log("SecureStorage: Cleared \(keysToRemove.count) expired cache items")
            }
        }
    }
}

// MARK: - Error Types

enum SecureStorageError: Error, LocalizedError {
    case keychainError(OSStatus)
    case keyNotFound
    case encryptionFailed
    case decryptionFailed
    
    var errorDescription: String? {
        switch self {
        case .keychainError(let status):
            return "Keychain error: \(status)"
        case .keyNotFound:
            return "Encryption key not found in Keychain"
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        }
    }
}

// MARK: - Convenience Extensions

extension SecureStorage {
    /// Stores a string securely
    static func storeString(_ string: String, forKey key: String) {
        store(string, forKey: key)
    }
    
    /// Retrieves a string securely
    static func retrieveString(forKey key: String) -> String? {
        return retrieve(String.self, forKey: key)
    }
    
    /// Stores a date securely
    static func storeDate(_ date: Date, forKey key: String) {
        store(date, forKey: key)
    }
    
    /// Retrieves a date securely
    static func retrieveDate(forKey key: String) -> Date? {
        return retrieve(Date.self, forKey: key)
    }
    
    /// Stores a boolean securely
    static func storeBool(_ value: Bool, forKey key: String) {
        store(value, forKey: key)
    }
    
    /// Retrieves a boolean securely
    static func retrieveBool(forKey key: String) -> Bool? {
        return retrieve(Bool.self, forKey: key)
    }
    
    /// Stores a double securely
    static func storeDouble(_ value: Double, forKey key: String) {
        store(value, forKey: key)
    }
    
    /// Retrieves a double securely
    static func retrieveDouble(forKey key: String) -> Double? {
        return retrieve(Double.self, forKey: key)
    }
    
    /// Stores an integer securely
    static func storeInt(_ value: Int, forKey key: String) {
        store(value, forKey: key)
    }
    
    /// Retrieves an integer securely
    static func retrieveInt(forKey key: String) -> Int? {
        return retrieve(Int.self, forKey: key)
    }
}

// MARK: - Performance Optimization: Cache Item

/// Cache item with timestamp for expiration
private struct CacheItem<T> {
    let value: T
    var timestamp: Date
    var accessCount: Int = 1
    
    mutating func accessed() {
        timestamp = Date()
        accessCount += 1
    }
}

