//
//  ModelIntegrityChecker.swift
//  Control LLM
//
//  Model integrity verification and validation
//

import Foundation
import CryptoKit

/// Validates model file integrity and security
class ModelIntegrityChecker {
    
    // MARK: - Constants
    
    private static let minModelSize: Int64 = 1_000_000 // 1MB minimum
    private static let maxModelSize: Int64 = 50_000_000_000 // 50GB maximum
    private static let validExtensions = ["gguf", "bin", "safetensors"]
    
    // MARK: - Model Validation
    
    /// Quick validation for performance-critical scenarios
    /// - Parameter modelPath: Path to the model file
    /// - Throws: ModelIntegrityError if validation fails
    static func quickValidate(_ modelPath: String) throws {
        debugPrint("ModelIntegrityChecker: Quick validating model at \(modelPath)", category: .security)
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: modelPath) else {
            throw ModelIntegrityError.fileNotFound
        }
        
        // Validate file extension (fast)
        try validateFileExtension(modelPath)
        
        // Validate file size (fast)
        try validateFileSize(modelPath)
        
        debugPrint("ModelIntegrityChecker: Quick validation passed", category: .security)
    }
    
    /// Validates a model file for integrity and security
    /// - Parameter modelPath: Path to the model file
    /// - Throws: ModelIntegrityError if validation fails
    static func validateModel(_ modelPath: String) throws {
        debugPrint("ModelIntegrityChecker: Validating model at \(modelPath)", category: .security)
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: modelPath) else {
            throw ModelIntegrityError.fileNotFound
        }
        
        // Validate file extension
        try validateFileExtension(modelPath)
        
        // Validate file size
        try validateFileSize(modelPath)
        
        // Validate file permissions
        try validateFilePermissions(modelPath)
        
        // Validate file format
        try validateFileFormat(modelPath)
        
        // Check for corruption
        try checkForCorruption(modelPath)
        
        debugPrint("ModelIntegrityChecker: Model validation passed", category: .security)
    }
    
    /// Validates file extension
    private static func validateFileExtension(_ modelPath: String) throws {
        let fileExtension = URL(fileURLWithPath: modelPath).pathExtension.lowercased()
        
        guard validExtensions.contains(fileExtension) else {
            throw ModelIntegrityError.invalidFileExtension(
                found: fileExtension,
                valid: validExtensions
            )
        }
    }
    
    /// Validates file size
    private static func validateFileSize(_ modelPath: String) throws {
        let attributes = try FileManager.default.attributesOfItem(atPath: modelPath)
        guard let fileSize = attributes[.size] as? Int64 else {
            throw ModelIntegrityError.cannotReadFileSize
        }
        
        if fileSize < minModelSize {
            throw ModelIntegrityError.fileTooSmall(
                actual: fileSize,
                minimum: minModelSize
            )
        }
        
        if fileSize > maxModelSize {
            throw ModelIntegrityError.fileTooLarge(
                actual: fileSize,
                maximum: maxModelSize
            )
        }
        
        debugPrint("ModelIntegrityChecker: File size validation passed (\(fileSize) bytes)", category: .security)
    }
    
    /// Validates file permissions
    private static func validateFilePermissions(_ modelPath: String) throws {
        let fileURL = URL(fileURLWithPath: modelPath)
        
        // Check if file is readable
        guard FileManager.default.isReadableFile(atPath: modelPath) else {
            throw ModelIntegrityError.fileNotReadable
        }
        
        // Check if file is not executable (security measure)
        let attributes = try FileManager.default.attributesOfItem(atPath: modelPath)
        if let permissions = attributes[.posixPermissions] as? NSNumber {
            let posixPermissions = permissions.intValue
            let isExecutable = (posixPermissions & 0o111) != 0
            
            if isExecutable {
                print("⚠️ ModelIntegrityChecker: Warning - model file has execute permissions")
                // Don't throw error, just log warning
            }
        }
    }
    
    /// Validates file format
    private static func validateFileFormat(_ modelPath: String) throws {
        let fileURL = URL(fileURLWithPath: modelPath)
        let fileExtension = fileURL.pathExtension.lowercased()
        
        switch fileExtension {
        case "gguf":
            try validateGGUFFormat(modelPath)
        case "bin":
            try validateBINFormat(modelPath)
        case "safetensors":
            try validateSafeTensorsFormat(modelPath)
        default:
            throw ModelIntegrityError.unsupportedFormat(fileExtension)
        }
    }
    
    /// Validates GGUF format
    private static func validateGGUFFormat(_ modelPath: String) throws {
        guard let fileHandle = FileHandle(forReadingAtPath: modelPath) else {
            throw ModelIntegrityError.cannotOpenFile
        }
        defer { fileHandle.closeFile() }
        
        // Read GGUF magic number
        let magicData = fileHandle.readData(ofLength: 4)
        guard magicData.count == 4 else {
            throw ModelIntegrityError.invalidFileFormat("GGUF magic number too short")
        }
        
        let magic = String(data: magicData, encoding: .ascii) ?? ""
        guard magic == "GGUF" else {
            throw ModelIntegrityError.invalidFileFormat("Invalid GGUF magic number: \(magic)")
        }
        
        print("🔍 ModelIntegrityChecker: GGUF format validation passed")
    }
    
    /// Validates BIN format (basic validation)
    private static func validateBINFormat(_ modelPath: String) throws {
        // Basic BIN format validation
        // This is a simplified check - in practice, you'd want more thorough validation
        let fileHandle = FileHandle(forReadingAtPath: modelPath)
        defer { fileHandle?.closeFile() }
        
        guard fileHandle != nil else {
            throw ModelIntegrityError.cannotOpenFile
        }
        
        print("🔍 ModelIntegrityChecker: BIN format validation passed")
    }
    
    /// Validates SafeTensors format
    private static func validateSafeTensorsFormat(_ modelPath: String) throws {
        // Basic SafeTensors format validation
        // This is a simplified check - in practice, you'd want more thorough validation
        let fileHandle = FileHandle(forReadingAtPath: modelPath)
        defer { fileHandle?.closeFile() }
        
        guard fileHandle != nil else {
            throw ModelIntegrityError.cannotOpenFile
        }
        
        print("🔍 ModelIntegrityChecker: SafeTensors format validation passed")
    }
    
    /// Checks for file corruption
    private static func checkForCorruption(_ modelPath: String) throws {
        let fileHandle = FileHandle(forReadingAtPath: modelPath)
        guard let fileHandle = fileHandle else {
            throw ModelIntegrityError.cannotOpenFile
        }
        defer { fileHandle.closeFile() }
        
        // Read first 1KB to check for basic corruption
        let sampleData = fileHandle.readData(ofLength: 1024)
        guard !sampleData.isEmpty else {
            throw ModelIntegrityError.fileCorrupted("Empty file")
        }
        
        // Check for null bytes in the beginning (potential corruption)
        let nullByteCount = sampleData.filter { $0 == 0 }.count
        if nullByteCount > sampleData.count / 2 {
            throw ModelIntegrityError.fileCorrupted("Excessive null bytes detected")
        }
        
        print("🔍 ModelIntegrityChecker: Corruption check passed")
    }
    
    // MARK: - Model Security Checks
    
    /// Performs security checks on a model file
    /// - Parameter modelPath: Path to the model file
    /// - Throws: ModelIntegrityError if security check fails
    static func performSecurityChecks(_ modelPath: String) throws {
        print("🔍 ModelIntegrityChecker: Performing security checks on \(modelPath)")
        
        // Check file location (should be in app bundle or documents)
        try validateFileLocation(modelPath)
        
        // Check for suspicious file names
        try validateFileName(modelPath)
        
        // Check file modification time
        try validateFileModificationTime(modelPath)
        
        print("✅ ModelIntegrityChecker: Security checks passed")
    }
    
    /// Validates file location
    private static func validateFileLocation(_ modelPath: String) throws {
        let fileURL = URL(fileURLWithPath: modelPath)
        
        // Check if file is in allowed locations
        let allowedPaths = [
            Bundle.main.bundlePath,
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? "",
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.path ?? ""
        ]
        
        let isInAllowedLocation = allowedPaths.contains { allowedPath in
            fileURL.path.hasPrefix(allowedPath)
        }
        
        guard isInAllowedLocation else {
            throw ModelIntegrityError.fileInUnsafeLocation(modelPath)
        }
    }
    
    /// Validates file name
    private static func validateFileName(_ modelPath: String) throws {
        let fileName = URL(fileURLWithPath: modelPath).lastPathComponent
        
        // Check for suspicious characters
        let suspiciousCharacters = ["..", "/", "\\", ":", "*", "?", "\"", "<", ">", "|"]
        for character in suspiciousCharacters {
            if fileName.contains(character) {
                throw ModelIntegrityError.suspiciousFileName(fileName)
            }
        }
        
        // Check for suspicious patterns
        let suspiciousPatterns = ["..", "cmd", "exec", "system", "admin", "root"]
        let lowercasedFileName = fileName.lowercased()
        for pattern in suspiciousPatterns {
            if lowercasedFileName.contains(pattern) {
                print("⚠️ ModelIntegrityChecker: Warning - suspicious pattern in filename: \(pattern)")
            }
        }
    }
    
    /// Validates file modification time
    private static func validateFileModificationTime(_ modelPath: String) throws {
        let attributes = try FileManager.default.attributesOfItem(atPath: modelPath)
        guard let modificationDate = attributes[.modificationDate] as? Date else {
            throw ModelIntegrityError.cannotReadFileModificationDate
        }
        
        let now = Date()
        let timeDifference = now.timeIntervalSince(modificationDate)
        
        // Check if file was modified in the future (potential clock manipulation)
        if timeDifference < 0 {
            throw ModelIntegrityError.fileModifiedInFuture(modificationDate)
        }
        
        // Check if file is too old (potential security issue)
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now
        if modificationDate < oneYearAgo {
            print("⚠️ ModelIntegrityChecker: Warning - model file is over 1 year old")
        }
    }
    
    // MARK: - Model Hash Verification
    
    /// Calculates SHA-256 hash of a model file
    /// - Parameter modelPath: Path to the model file
    /// - Returns: SHA-256 hash as hex string
    /// - Throws: ModelIntegrityError if hash calculation fails
    static func calculateModelHash(_ modelPath: String) throws -> String {
        guard let fileHandle = FileHandle(forReadingAtPath: modelPath) else {
            throw ModelIntegrityError.cannotOpenFile
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
    
    /// Verifies model hash against expected hash
    /// - Parameters:
    ///   - modelPath: Path to the model file
    ///   - expectedHash: Expected SHA-256 hash
    /// - Throws: ModelIntegrityError if hash verification fails
    static func verifyModelHash(_ modelPath: String, expectedHash: String) throws {
        let actualHash = try calculateModelHash(modelPath)
        
        guard actualHash == expectedHash else {
            throw ModelIntegrityError.hashMismatch(
                expected: expectedHash,
                actual: actualHash
            )
        }
        
        print("✅ ModelIntegrityChecker: Hash verification passed")
    }
}

// MARK: - Error Types

enum ModelIntegrityError: Error, LocalizedError {
    case fileNotFound
    case invalidFileExtension(found: String, valid: [String])
    case fileTooSmall(actual: Int64, minimum: Int64)
    case fileTooLarge(actual: Int64, maximum: Int64)
    case fileNotReadable
    case cannotOpenFile
    case invalidFileFormat(String)
    case unsupportedFormat(String)
    case fileCorrupted(String)
    case fileInUnsafeLocation(String)
    case suspiciousFileName(String)
    case cannotReadFileSize
    case cannotReadFileModificationDate
    case fileModifiedInFuture(Date)
    case hashMismatch(expected: String, actual: String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Model file not found"
        case .invalidFileExtension(let found, let valid):
            return "Invalid file extension '\(found)'. Valid extensions: \(valid.joined(separator: ", "))"
        case .fileTooSmall(let actual, let minimum):
            return "Model file too small (\(actual) bytes). Minimum size: \(minimum) bytes"
        case .fileTooLarge(let actual, let maximum):
            return "Model file too large (\(actual) bytes). Maximum size: \(maximum) bytes"
        case .fileNotReadable:
            return "Model file is not readable"
        case .cannotOpenFile:
            return "Cannot open model file"
        case .invalidFileFormat(let reason):
            return "Invalid file format: \(reason)"
        case .unsupportedFormat(let format):
            return "Unsupported model format: \(format)"
        case .fileCorrupted(let reason):
            return "Model file appears corrupted: \(reason)"
        case .fileInUnsafeLocation(let path):
            return "Model file in unsafe location: \(path)"
        case .suspiciousFileName(let fileName):
            return "Suspicious filename: \(fileName)"
        case .cannotReadFileSize:
            return "Cannot read file size"
        case .cannotReadFileModificationDate:
            return "Cannot read file modification date"
        case .fileModifiedInFuture(let date):
            return "Model file modified in the future: \(date)"
        case .hashMismatch(let expected, let actual):
            return "Model hash mismatch. Expected: \(expected), Actual: \(actual)"
        }
    }
}
