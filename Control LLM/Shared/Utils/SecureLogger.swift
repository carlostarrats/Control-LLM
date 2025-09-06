//
//  SecureLogger.swift
//  Control LLM
//
//  Security-focused logging utility that prevents sensitive data leakage
//

import Foundation
import os.log

/// Secure logging utility that prevents sensitive user data from being logged
class SecureLogger {
    
    /// Logs a message with optional sensitive data that gets redacted in production
    /// - Parameters:
    ///   - message: The log message
    ///   - sensitiveData: Optional sensitive data to redact
    ///   - category: Log category for filtering
    static func log(_ message: String, sensitiveData: String? = nil, category: String = "SecureLogger") {
        #if DEBUG
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ControlLLM", category: category)
        
        if let data = sensitiveData {
            // In debug builds, show sanitized version with length info
            let sanitized = String(data.prefix(20)) + (data.count > 20 ? "..." : "")
            logger.info("\(message): [SENSITIVE DATA REDACTED - \(data.count) chars, preview: \(sanitized)]")
        } else {
            logger.info("\(message)")
        }
        #else
        // In production builds, only log non-sensitive messages
        if sensitiveData == nil {
            let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ControlLLM", category: category)
            logger.info("\(message)")
        }
        #endif
    }
    
    /// Logs user interaction events without exposing sensitive content
    /// - Parameters:
    ///   - action: The action being performed
    ///   - context: Additional context (non-sensitive)
    static func logUserAction(_ action: String, context: String? = nil) {
        let message = context != nil ? "\(action) - \(context!)" : action
        log(message)
    }
    
    /// Logs system events with optional non-sensitive data
    /// - Parameters:
    ///   - event: The system event
    ///   - details: Optional non-sensitive details
    static func logSystemEvent(_ event: String, details: String? = nil) {
        let message = details != nil ? "\(event) - \(details!)" : event
        log(message)
    }
    
    /// Logs errors without exposing sensitive data
    /// - Parameters:
    ///   - error: The error to log
    ///   - context: Additional context (non-sensitive)
    static func logError(_ error: Error, context: String? = nil) {
        let message = context != nil ? "Error in \(context!): \(error.localizedDescription)" : "Error: \(error.localizedDescription)"
        log(message)
    }
    
    /// Logs performance metrics without sensitive data
    /// - Parameters:
    ///   - metric: The performance metric name
    ///   - value: The metric value
    ///   - unit: The unit of measurement
    static func logPerformance(_ metric: String, value: Double, unit: String = "seconds") {
        log("Performance: \(metric) = \(String(format: "%.2f", value)) \(unit)")
    }
    
    /// Logs model operations without exposing user data
    /// - Parameters:
    ///   - operation: The model operation
    ///   - modelName: The model name (safe to log)
    ///   - additionalInfo: Any additional non-sensitive info
    static func logModelOperation(_ operation: String, modelName: String, additionalInfo: String? = nil) {
        let message = additionalInfo != nil ? "\(operation) - Model: \(modelName) - \(additionalInfo!)" : "\(operation) - Model: \(modelName)"
        log(message)
    }
}
