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
    
    // MARK: - Public Storage Methods
    
    /// Stores an encrypted object in UserDefaults
    /// - Parameters:
    ///   - object: The object to store (must conform to Codable)
    ///   - key: The key to store the object under
    static func store<T: Codable>(_ object: T, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(object)
            let encryptedData = try encrypt(data)
            UserDefaults.standard.set(encryptedData, forKey: key)
            SecureLogger.log("Stored encrypted data for key: \(key)")
        } catch {
            SecureLogger.logError(error, context: "SecureStorage.store")
        }
    }
    
    /// Retrieves and decrypts an object from UserDefaults
    /// - Parameters:
    ///   - type: The type of object to retrieve
    ///   - key: The key the object is stored under
    /// - Returns: The decrypted object, or nil if not found or decryption fails
    static func retrieve<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let encryptedData = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        do {
            let decryptedData = try decrypt(encryptedData)
            let object = try JSONDecoder().decode(type, from: decryptedData)
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
        data.withUnsafeMutableBytes { bytes in
            memset_s(bytes.baseAddress, bytes.count, 0, bytes.count)
        }
    }
    
    /// Securely wipes a string from memory
    /// - Parameter string: The string to wipe
    static func secureWipe(_ string: inout String) {
        string.withUTF8 { utf8 in
            var mutableBytes = UnsafeMutableRawPointer(mutating: utf8.baseAddress!)
            memset_s(mutableBytes, utf8.count, 0, utf8.count)
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
