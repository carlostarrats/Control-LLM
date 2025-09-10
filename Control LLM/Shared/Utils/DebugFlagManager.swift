//
//  DebugFlagManager.swift
//  Control LLM
//
//  Centralized debug flag management for security
//

import Foundation

/// Centralized debug flag management to prevent information leakage in production
class DebugFlagManager {
    
    // MARK: - Debug Flags
    
    /// Master debug flag - controls all debug output
    static let isDebugEnabled: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    /// Logging debug flag
    static let isLoggingEnabled: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    /// Performance debug flag
    static let isPerformanceDebugEnabled: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    /// Security debug flag (only in debug builds)
    static let isSecurityDebugEnabled: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    /// Network debug flag
    static let isNetworkDebugEnabled: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    /// UI debug flag
    static let isUIDebugEnabled: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    /// Model debug flag
    static let isModelDebugEnabled: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    // MARK: - Debug Logging
    
    /// Debug print function that only works in debug builds
    /// - Parameters:
    ///   - message: Message to print
    ///   - category: Debug category
    ///   - file: Source file name
    ///   - function: Function name
    ///   - line: Line number
    static func debugPrint(
        _ message: String,
        category: DebugCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        guard isDebugEnabled else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let timestamp = DateFormatter.debugTimestamp.string(from: Date())
        
        print("[\(timestamp)] [\(category.rawValue)] \(fileName):\(line) \(function) - \(message)")
        
        #else
        // No debug printing in production builds
        #endif
    }
    
    /// Debug print with sensitive data handling
    /// - Parameters:
    ///   - message: Message to print
    ///   - sensitiveData: Sensitive data to redact
    ///   - category: Debug category
    ///   - file: Source file name
    ///   - function: Function name
    ///   - line: Line number
    static func debugPrintWithSensitiveData(
        _ message: String,
        sensitiveData: String?,
        category: DebugCategory = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        guard isDebugEnabled else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let timestamp = DateFormatter.debugTimestamp.string(from: Date())
        
        if let data = sensitiveData {
            let sanitized = String(data.prefix(20)) + (data.count > 20 ? "..." : "")
            print("[\(timestamp)] [\(category.rawValue)] \(fileName):\(line) \(function) - \(message): [SENSITIVE DATA REDACTED - \(data.count) chars, preview: \(sanitized)]")
        } else {
            print("[\(timestamp)] [\(category.rawValue)] \(fileName):\(line) \(function) - \(message)")
        }
        #else
        // No debug printing in production builds
        #endif
    }
    
    // MARK: - Conditional Execution
    
    /// Executes code only in debug builds
    /// - Parameter block: Code block to execute
    static func debugOnly(_ block: () -> Void) {
        guard isDebugEnabled else { return }
        block()
    }
    
    /// Executes code only in debug builds with return value
    /// - Parameter block: Code block to execute
    /// - Returns: Result of block execution or nil in production
    static func debugOnly<T>(_ block: () -> T) -> T? {
        guard isDebugEnabled else { return nil }
        return block()
    }
    
    // MARK: - Performance Debugging
    
    /// Measures execution time of a block
    /// - Parameters:
    ///   - name: Name of the operation
    ///   - block: Code block to measure
    /// - Returns: Execution time in seconds
    @discardableResult
    static func measureTime<T>(_ name: String, _ block: () throws -> T) rethrows -> T {
        guard isPerformanceDebugEnabled else {
            return try block()
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        debugPrint("⏱️ \(name) took \(String(format: "%.4f", timeElapsed)) seconds", category: .performance)
        return result
    }
    
    /// Measures execution time of an async block
    /// - Parameters:
    ///   - name: Name of the operation
    ///   - block: Async code block to measure
    /// - Returns: Execution time in seconds
    @discardableResult
    static func measureTimeAsync<T>(_ name: String, _ block: () async throws -> T) async rethrows -> T {
        guard isPerformanceDebugEnabled else {
            return try await block()
        }
        
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try await block()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        debugPrint("⏱️ \(name) took \(String(format: "%.4f", timeElapsed)) seconds", category: .performance)
        return result
    }
    
    // MARK: - Security Debugging
    
    /// Logs security events (only in debug builds)
    /// - Parameters:
    ///   - event: Security event description
    ///   - details: Additional details
    ///   - file: Source file name
    ///   - function: Function name
    ///   - line: Line number
    static func logSecurityEvent(
        _ event: String,
        details: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard isSecurityDebugEnabled else { return }
        
        let message = details != nil ? "\(event) - \(details!)" : event
        debugPrint("🔒 SECURITY: \(message)", category: .security, file: file, function: function, line: line)
    }
    
    // MARK: - Network Debugging
    
    /// Logs network events (only in debug builds)
    /// - Parameters:
    ///   - event: Network event description
    ///   - details: Additional details
    ///   - file: Source file name
    ///   - function: Function name
    ///   - line: Line number
    static func logNetworkEvent(
        _ event: String,
        details: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard isNetworkDebugEnabled else { return }
        
        let message = details != nil ? "\(event) - \(details!)" : event
        debugPrint("🌐 NETWORK: \(message)", category: .network, file: file, function: function, line: line)
    }
    
    // MARK: - Model Debugging
    
    /// Logs model events (only in debug builds)
    /// - Parameters:
    ///   - event: Model event description
    ///   - details: Additional details
    ///   - file: Source file name
    ///   - function: Function name
    ///   - line: Line number
    static func logModelEvent(
        _ event: String,
        details: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard isModelDebugEnabled else { return }
        
        let message = details != nil ? "\(event) - \(details!)" : event
        debugPrint("🤖 MODEL: \(message)", category: .model, file: file, function: function, line: line)
    }
    
    // MARK: - UI Debugging
    
    /// Logs UI events (only in debug builds)
    /// - Parameters:
    ///   - event: UI event description
    ///   - details: Additional details
    ///   - file: Source file name
    ///   - function: Function name
    ///   - line: Line number
    static func logUIEvent(
        _ event: String,
        details: String? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard isUIDebugEnabled else { return }
        
        let message = details != nil ? "\(event) - \(details!)" : event
        debugPrint("🎨 UI: \(message)", category: .ui, file: file, function: function, line: line)
    }
}

// MARK: - Debug Categories

enum DebugCategory: String, CaseIterable {
    case general = "GENERAL"
    case security = "SECURITY"
    case network = "NETWORK"
    case model = "MODEL"
    case ui = "UI"
    case performance = "PERFORMANCE"
    case memory = "MEMORY"
    case file = "FILE"
    case database = "DATABASE"
    case api = "API"
}

// MARK: - Date Formatter Extension

extension DateFormatter {
    static let debugTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}

// MARK: - Debug Print Macros

    /// Debug print macro that automatically includes file, function, and line
    /// - Parameters:
    ///   - message: Message to print
    ///   - category: Debug category
    func debugPrint(_ message: String, category: DebugCategory = .general) {
        #if DEBUG
        DebugFlagManager.debugPrint(message, category: category)
        #else
        // No debug printing in production builds
        #endif
    }

/// Debug print macro with sensitive data
/// - Parameters:
///   - message: Message to print
///   - sensitiveData: Sensitive data to redact
///   - category: Debug category
func debugPrintWithSensitiveData(_ message: String, sensitiveData: String?, category: DebugCategory = .general) {
    DebugFlagManager.debugPrintWithSensitiveData(message, sensitiveData: sensitiveData, category: category)
}

/// Debug print macro for security events
/// - Parameters:
///   - event: Security event description
///   - details: Additional details
func debugSecurity(_ event: String, details: String? = nil) {
    DebugFlagManager.logSecurityEvent(event, details: details)
}

/// Debug print macro for network events
/// - Parameters:
///   - event: Network event description
///   - details: Additional details
func debugNetwork(_ event: String, details: String? = nil) {
    DebugFlagManager.logNetworkEvent(event, details: details)
}

/// Debug print macro for model events
/// - Parameters:
///   - event: Model event description
///   - details: Additional details
func debugModel(_ event: String, details: String? = nil) {
    DebugFlagManager.logModelEvent(event, details: details)
}

/// Debug print macro for UI events
/// - Parameters:
///   - event: UI event description
///   - details: Additional details
func debugUI(_ event: String, details: String? = nil) {
    DebugFlagManager.logUIEvent(event, details: details)
}
