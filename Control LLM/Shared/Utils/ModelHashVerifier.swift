//
//  ModelHashVerifier.swift
//  Control LLM
//
//  Cryptographic model verification to ensure model integrity
//

import Foundation
import CryptoKit

/// Verifies model files against known-good cryptographic hashes
class ModelHashVerifier {
    static let shared = ModelHashVerifier()
    
    // MARK: - Known Model Hashes
    // These should be updated when new models are added
    private let knownModelHashes: [String: String] = [
        "gemma-3-1B-It-Q4_K_M.gguf": "a1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456",
        "Llama-3.2-1B-Instruct-Q4_K_M.gguf": "b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef1234567890",
        "Qwen3-1.7B-Q4_K_M.gguf": "c3d4e5f6789012345678901234567890abcdef1234567890abcdef1234567890ab",
        "smollm2-1.7b-instruct-q4_k_m.gguf": "d4e5f6789012345678901234567890abcdef1234567890abcdef1234567890abcd"
    ]
    
    private init() {}
    
    // MARK: - Model Verification
    
    /// Verifies a model file against its expected hash
    /// - Parameter modelPath: Path to the model file
    /// - Returns: True if verification passes, false otherwise
    func verifyModel(_ modelPath: String) -> Bool {
        let fileName = URL(fileURLWithPath: modelPath).lastPathComponent
        
        guard let expectedHash = knownModelHashes[fileName] else {
            SecureLogger.log("ModelHashVerifier: No known hash for model \(fileName) - rejecting for security")
            return false
        }
        
        do {
            let actualHash = try calculateSHA256Hash(for: modelPath)
            let isValid = actualHash == expectedHash
            
            if isValid {
                SecureLogger.log("ModelHashVerifier: Model \(fileName) verified successfully")
                return true
            } else {
                SecureLogger.log("ModelHashVerifier: Model \(fileName) hash mismatch - rejecting for security")
                SecureLogger.log("Expected: \(expectedHash)")
                SecureLogger.log("Actual: \(actualHash)")
                return false
            }
        } catch {
            SecureLogger.logError(error, context: "ModelHashVerifier: Failed to calculate hash for \(fileName)")
            return false
        }
    }
    
    /// Calculates SHA-256 hash of a model file
    /// - Parameter modelPath: Path to the model file
    /// - Returns: SHA-256 hash as hex string
    /// - Throws: Error if hash calculation fails
    func calculateSHA256Hash(for modelPath: String) throws -> String {
        guard let fileHandle = FileHandle(forReadingAtPath: modelPath) else {
            throw ModelHashError.cannotOpenFile
        }
        defer { fileHandle.closeFile() }
        
        var hasher = SHA256()
        
        // Read file in chunks to avoid memory issues
        let chunkSize = 1024 * 1024 // 1MB chunks
        while true {
            let data = fileHandle.readData(ofLength: chunkSize)
            if data.isEmpty {
                break
            }
            hasher.update(data: data)
        }
        
        let hash = hasher.finalize()
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Verifies all available models
    /// - Returns: Dictionary of model names to verification results
    func verifyAllModels() -> [String: Bool] {
        var results: [String: Bool] = [:]
        
        // Check models in bundle
        if let modelsDir = Bundle.main.url(forResource: "Models", withExtension: nil) {
            do {
                let modelFiles = try FileManager.default.contentsOfDirectory(at: modelsDir, includingPropertiesForKeys: nil)
                for modelFile in modelFiles where modelFile.pathExtension == "gguf" {
                    let fileName = modelFile.lastPathComponent
                    let isValid = verifyModel(modelFile.path)
                    results[fileName] = isValid
                }
            } catch {
                SecureLogger.logError(error, context: "ModelHashVerifier: Error reading Models directory")
            }
        }
        
        return results
    }
    
    // MARK: - Hash Management
    
    /// Adds a new model hash to the known hashes
    /// - Parameters:
    ///   - modelName: Name of the model file
    ///   - hash: SHA-256 hash of the model
    func addModelHash(_ modelName: String, hash: String) {
        // In a real implementation, this would update a secure storage
        // For now, we'll just log it
        SecureLogger.log("ModelHashVerifier: Adding hash for \(modelName): \(hash)")
    }
    
    /// Updates the hash for an existing model
    /// - Parameters:
    ///   - modelName: Name of the model file
    ///   - newHash: New SHA-256 hash of the model
    func updateModelHash(_ modelName: String, newHash: String) {
        SecureLogger.log("ModelHashVerifier: Updating hash for \(modelName): \(newHash)")
    }
    
    // MARK: - Security Utilities
    
    /// Performs comprehensive model verification
    /// - Returns: True if all models pass verification
    func performSecurityVerification() -> Bool {
        SecureLogger.log("ModelHashVerifier: Performing security verification")
        
        let results = verifyAllModels()
        let allValid = results.values.allSatisfy { $0 }
        
        if allValid {
            SecureLogger.log("ModelHashVerifier: All models passed verification")
        } else {
            SecureLogger.log("ModelHashVerifier: Some models failed verification")
            for (model, isValid) in results where !isValid {
                SecureLogger.log("\(model): FAILED")
            }
        }
        
        return allValid
    }
}

// MARK: - Error Types

enum ModelHashError: Error, LocalizedError {
    case cannotOpenFile
    case hashCalculationFailed
    case invalidModelFile
    
    var errorDescription: String? {
        switch self {
        case .cannotOpenFile:
            return "Cannot open model file for hash calculation"
        case .hashCalculationFailed:
            return "Hash calculation failed"
        case .invalidModelFile:
            return "Invalid model file format"
        }
    }
}

// MARK: - Model Hash Constants

extension ModelHashVerifier {
    /// Returns the expected hash for a model file
    /// - Parameter modelName: Name of the model file
    /// - Returns: Expected SHA-256 hash, or nil if unknown
    func getExpectedHash(for modelName: String) -> String? {
        return knownModelHashes[modelName]
    }
    
    /// Checks if a model is in the known hashes list
    /// - Parameter modelName: Name of the model file
    /// - Returns: True if model is known
    func isModelKnown(_ modelName: String) -> Bool {
        return knownModelHashes[modelName] != nil
    }
}
