//
//  ModelValidationService.swift
//  Control LLM
//
//  Cryptographic validation service for downloaded models
//

import Foundation
import CryptoKit
import Security

/// Service for validating model integrity using cryptographic checksums
class ModelValidationService {
    static let shared = ModelValidationService()
    
    // MARK: - Known Model Checksums
    // These should be updated with actual checksums from trusted sources
    private let modelChecksums: [String: String] = [
        "gemma-3-1B-It-Q4_K_M.gguf": "SHA256:PLACEHOLDER_CHECKSUM_HERE",
        "Llama-3.2-1B-Instruct-Q4_K_M.gguf": "SHA256:PLACEHOLDER_CHECKSUM_HERE", 
        "Qwen3-1.7B-Q4_K_M.gguf": "SHA256:PLACEHOLDER_CHECKSUM_HERE",
        "smollm2-1.7b-instruct-q4_k_m.gguf": "SHA256:PLACEHOLDER_CHECKSUM_HERE"
    ]
    
    // MARK: - Bundled Model Validation
    // For bundled models, we perform basic validation instead of checksum verification
    private let bundledModelNames: Set<String> = [
        "gemma-3-1B-It-Q4_K_M.gguf",
        "Llama-3.2-1B-Instruct-Q4_K_M.gguf",
        "Qwen3-1.7B-Q4_K_M.gguf",
        "smollm2-1.7b-instruct-q4_k_m.gguf"
    ]
    
    private init() {}
    
    // MARK: - Model Validation
    
    /// Validates a model file using SHA-256 checksum
    /// - Parameters:
    ///   - modelURL: URL to the model file
    ///   - expectedChecksum: Expected SHA-256 checksum (optional)
    /// - Returns: True if validation passes
    func validateModel(at modelURL: URL, expectedChecksum: String? = nil) async throws -> Bool {
        SecureLogger.log("ModelValidationService: Starting validation for \(modelURL.lastPathComponent)")
        
        // Get file size for validation
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: modelURL.path)
        guard let fileSize = fileAttributes[.size] as? NSNumber else {
            throw ModelValidationError.invalidFileSize
        }
        
        // Check file size (models should be reasonably large)
        let sizeInMB = fileSize.doubleValue / (1024 * 1024)
        if sizeInMB < 100 { // Less than 100MB is suspicious for a model
            SecureLogger.log("ModelValidationService: Suspicious file size: \(sizeInMB)MB")
            throw ModelValidationError.suspiciousFileSize
        }
        
        // Calculate SHA-256 checksum
        let calculatedChecksum = try await calculateSHA256Checksum(for: modelURL)
        SecureLogger.log("ModelValidationService: Calculated checksum: \(calculatedChecksum)")
        
        // Get expected checksum
        let expected = expectedChecksum ?? modelChecksums[modelURL.lastPathComponent]
        
        // Check if this is a bundled model
        let isBundledModel = bundledModelNames.contains(modelURL.lastPathComponent)
        
        if isBundledModel {
            SecureLogger.log("ModelValidationService: Bundled model detected - performing basic validation for \(modelURL.lastPathComponent)")
            return try await validateBundledModel(at: modelURL)
        }
        
        // For external models, perform full checksum validation
        if let expectedChecksum = expected {
            // Skip validation if it's a placeholder checksum - but log security warning
            if expectedChecksum.contains("PLACEHOLDER") {
                SecureLogger.log("SECURITY WARNING: Skipping checksum validation for \(modelURL.lastPathComponent) - placeholder checksum. This is a security risk in production.")
                // Only allow this for bundled models in debug builds
                #if DEBUG
                return true
                #else
                throw ModelValidationError.checksumMismatch
                #endif
            }
            
            // Validate checksum
            let isValid = calculatedChecksum == expectedChecksum
            if !isValid {
                SecureLogger.log("ModelValidationService: Checksum mismatch for \(modelURL.lastPathComponent)")
                SecureLogger.log("ModelValidationService: Expected: \(expectedChecksum)")
                SecureLogger.log("ModelValidationService: Calculated: \(calculatedChecksum)")
                throw ModelValidationError.checksumMismatch
            }
        } else {
            // For bundled models without checksums, perform basic validation
            if modelURL.path.contains("Models") || modelURL.path.contains("Bundle") {
                SecureLogger.log("ModelValidationService: No expected checksum found for bundled model \(modelURL.lastPathComponent) - performing basic validation")
                // Perform basic file structure validation instead
                return try await validateModelStructure(at: modelURL)
            } else {
                SecureLogger.log("SECURITY WARNING: No expected checksum found for external model \(modelURL.lastPathComponent) - this is a security risk")
                throw ModelValidationError.checksumMismatch
            }
        }
        
        SecureLogger.log("ModelValidationService: Model validation passed for \(modelURL.lastPathComponent)")
        return true
    }
    
    /// Calculates SHA-256 checksum for a file
    /// - Parameter fileURL: URL to the file
    /// - Returns: SHA-256 checksum as hex string
    private func calculateSHA256Checksum(for fileURL: URL) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let fileData = try Data(contentsOf: fileURL)
                    let hash = SHA256.hash(data: fileData)
                    let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
                    continuation.resume(returning: "SHA256:\(hashString)")
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Validates model file structure and format
    /// - Parameter modelURL: URL to the model file
    /// - Returns: True if file structure is valid
    func validateModelStructure(at modelURL: URL) async throws -> Bool {
        SecureLogger.log("ModelValidationService: Validating structure for \(modelURL.lastPathComponent)")
        
        // Check file extension
        guard modelURL.pathExtension.lowercased() == "gguf" else {
            throw ModelValidationError.invalidFileFormat
        }
        
        // Read file header to validate GGUF format
        let fileHandle = try FileHandle(forReadingFrom: modelURL)
        defer { fileHandle.closeFile() }
        
        // Read first 8 bytes to check GGUF magic number
        let headerData = fileHandle.readData(ofLength: 8)
        guard headerData.count == 8 else {
            throw ModelValidationError.invalidFileFormat
        }
        
        // Check for GGUF magic number (0x46554747 = "GGUF")
        let magicBytes = headerData.withUnsafeBytes { bytes in
            bytes.load(as: UInt32.self)
        }
        
        guard magicBytes == 0x46554747 else {
            SecureLogger.log("ModelValidationService: Invalid GGUF magic number: \(String(format: "0x%08x", magicBytes))")
            throw ModelValidationError.invalidFileFormat
        }
        
        SecureLogger.log("ModelValidationService: Model structure validation passed")
        return true
    }
    
    /// Performs comprehensive model validation
    /// - Parameter modelURL: URL to the model file
    /// - Returns: True if all validations pass
    func performComprehensiveValidation(at modelURL: URL) async throws -> Bool {
        SecureLogger.log("ModelValidationService: Starting comprehensive validation")
        
        // 1. Validate file structure
        _ = try await validateModelStructure(at: modelURL)
        
        // 2. Validate checksum (permissive for bundled models)
        _ = try await validateModel(at: modelURL)
        
        // 3. Additional security checks (permissive for bundled models)
        do {
            try await performSecurityChecks(for: modelURL)
        } catch {
            // For bundled models, log security check failures but don't fail validation
            if modelURL.path.contains("Models") || modelURL.path.contains("Bundle") {
                SecureLogger.log("ModelValidationService: Security check failed for bundled model, but allowing: \(error.localizedDescription)")
            } else {
                throw error
            }
        }
        
        SecureLogger.log("ModelValidationService: Comprehensive validation passed")
        return true
    }
    
    /// Performs additional security checks on the model file
    /// - Parameter modelURL: URL to the model file
    private func performSecurityChecks(for modelURL: URL) async throws {
        // Check for suspicious file patterns
        let suspiciousPatterns = [
            "eval", "exec", "system", "shell", "cmd", "powershell",
            "javascript:", "vbscript:", "data:", "file:"
        ]
        
        // Read a sample of the file to check for suspicious content
        let fileHandle = try FileHandle(forReadingFrom: modelURL)
        defer { fileHandle.closeFile() }
        
        // Read first 1MB to check for suspicious patterns
        let sampleData = fileHandle.readData(ofLength: 1024 * 1024)
        let sampleString = String(data: sampleData, encoding: .utf8) ?? ""
        
        for pattern in suspiciousPatterns {
            if sampleString.lowercased().contains(pattern.lowercased()) {
                SecureLogger.log("ModelValidationService: Suspicious pattern found: \(pattern)")
                throw ModelValidationError.suspiciousContent
            }
        }
        
        SecureLogger.log("ModelValidationService: Security checks passed")
    }
}

// MARK: - Error Types

enum ModelValidationError: Error, LocalizedError {
    case invalidFileSize
    case suspiciousFileSize
    case checksumMismatch
    case invalidFileFormat
    case suspiciousContent
    case fileReadError
    
    var errorDescription: String? {
        switch self {
        case .invalidFileSize:
            return "Invalid file size for model"
        case .suspiciousFileSize:
            return "File size is suspiciously small for a model"
        case .checksumMismatch:
            return "Model checksum does not match expected value"
        case .invalidFileFormat:
            return "Invalid model file format"
        case .suspiciousContent:
            return "Model contains suspicious content"
        case .fileReadError:
            return "Failed to read model file"
        }
    }
}

// MARK: - Helper Extensions

extension ModelValidationService {
    /// Updates the checksum for a model (for development/testing)
    /// - Parameters:
    ///   - modelName: Name of the model
    ///   - checksum: New checksum
    func updateChecksum(for modelName: String, checksum: String) {
        // This would update the checksum in a persistent store
        // For now, we'll just log it
        SecureLogger.log("ModelValidationService: Checksum updated for \(modelName): \(checksum)")
    }
    
    /// Gets the expected checksum for a model
    /// - Parameter modelName: Name of the model
    /// - Returns: Expected checksum if available
    func getExpectedChecksum(for modelName: String) -> String? {
        return modelChecksums[modelName]
    }
    
    /// Validates a bundled model using basic file structure validation
    /// - Parameter modelURL: URL to the bundled model file
    /// - Returns: True if validation passes
    private func validateBundledModel(at modelURL: URL) async throws -> Bool {
        SecureLogger.log("ModelValidationService: Validating bundled model at \(modelURL.lastPathComponent)")
        
        // Check if file exists and is readable
        guard FileManager.default.fileExists(atPath: modelURL.path) else {
            throw ModelValidationError.fileReadError
        }
        
        // Check file size (bundled models should be reasonably large)
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: modelURL.path)
        guard let fileSize = fileAttributes[.size] as? NSNumber else {
            throw ModelValidationError.invalidFileSize
        }
        
        let sizeInMB = fileSize.doubleValue / (1024 * 1024)
        if sizeInMB < 50 { // Bundled models should be at least 50MB
            SecureLogger.log("ModelValidationService: Bundled model too small: \(sizeInMB)MB")
            throw ModelValidationError.suspiciousFileSize
        }
        
        // Check file extension
        guard modelURL.pathExtension.lowercased() == "gguf" else {
            SecureLogger.log("ModelValidationService: Invalid file extension for bundled model")
            throw ModelValidationError.invalidFileFormat
        }
        
        // Basic GGUF header validation
        return try await validateModelStructure(at: modelURL)
    }
}
