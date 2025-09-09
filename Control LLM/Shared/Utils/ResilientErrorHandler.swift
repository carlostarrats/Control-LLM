//
//  ResilientErrorHandler.swift
//  Control LLM
//
//  Created during Phase 5: Execution Flow Resilience
//  Provides robust error handling and recovery mechanisms
//

import Foundation

/// Centralized error handling for resilient execution flow
class ResilientErrorHandler {
    
    // MARK: - Singleton
    static let shared = ResilientErrorHandler()
    private init() {}
    
    // MARK: - Error Tracking
    private var consecutiveFailures: [String: Int] = [:]
    private var operationStartTimes: [String: Date] = [:]
    private var partialResults: [String: [String]] = [:]
    
    // MARK: - Error Recovery
    
    /// Attempts to recover from an error with retry logic
    func attemptRecovery<T>(
        for operationName: String,
        maxRetries: Int = Constants.maxLLMRetryAttempts,
        operation: () async throws -> T
    ) async throws -> T {
        
        var lastError: Error?
        var attempt = 0
        
        while attempt < maxRetries {
            attempt += 1
            
            do {
                // Track operation start time
                operationStartTimes[operationName] = Date()
                
                // Attempt the operation
                let result = try await operation()
                
                // Success - reset failure count and clear tracking
                consecutiveFailures[operationName] = 0
                operationStartTimes.removeValue(forKey: operationName)
                
                return result
                
            } catch {
                lastError = error
                consecutiveFailures[operationName, default: 0] += 1
                
                
                // Check if we should abort due to too many consecutive failures
                if consecutiveFailures[operationName, default: 0] >= Constants.maxConsecutiveFailures {
                    throw ResilientError.tooManyConsecutiveFailures(operation: operationName, count: consecutiveFailures[operationName, default: 0])
                }
                
                // If this isn't the last attempt, wait before retrying
                if attempt < maxRetries {
                    try await Task.sleep(nanoseconds: UInt64(Constants.retryDelaySeconds * 1_000_000_000))
                }
            }
        }
        
        // All retries failed
        throw ResilientError.maxRetriesExceeded(operation: operationName, lastError: lastError)
    }
    
    /// Checks if an operation is stuck and needs recovery
    func isOperationStuck(_ operation: String) -> Bool {
        guard let startTime = operationStartTimes[operation] else { return false }
        
        let elapsed = Date().timeIntervalSince(startTime)
        return elapsed > Constants.maxLLMResponseTime
    }
    
    /// Attempts to recover from a stuck operation
    func recoverFromStuckOperation(_ operation: String) async -> Bool {
        guard isOperationStuck(operation) else { return false }
        
        
        // Clear the stuck operation tracking
        operationStartTimes.removeValue(forKey: operation)
        
        // Reset failure count for this operation
        consecutiveFailures[operation] = 0
        
        return true
    }
    
    /// Stores partial results for potential recovery
    func storePartialResult(_ operation: String, result: String) {
        if partialResults[operation] == nil {
            partialResults[operation] = []
        }
        
        partialResults[operation]?.append(result)
        
        // Keep only the most recent results
        if let results = partialResults[operation], results.count > Constants.maxPartialResults {
            partialResults[operation] = Array(results.suffix(Constants.maxPartialResults))
        }
    }
    
    /// Retrieves stored partial results
    func getPartialResults(_ operation: String) -> [String] {
        return partialResults[operation] ?? []
    }
    
    /// Clears stored partial results
    func clearPartialResults(_ operation: String) {
        partialResults.removeValue(forKey: operation)
    }
    
    /// Checks if we have enough progress to continue after a failure
    func hasSufficientProgress(_ operation: String, totalExpected: Int) -> Bool {
        let completed = partialResults[operation]?.count ?? 0
        let progress = Double(completed) / Double(totalExpected)
        return progress >= Constants.minProgressThreshold
    }
    
    /// Provides a summary of the current error state
    func getErrorSummary() -> String {
        var summary = "🔍 ResilientErrorHandler Status:\n"
        
        for (operation, failures) in consecutiveFailures {
            let isStuck = isOperationStuck(operation)
            let partialCount = partialResults[operation]?.count ?? 0
            summary += "• \(operation): \(failures) failures, \(partialCount) partial results\(isStuck ? " (STUCK)" : "")\n"
        }
        
        return summary
    }
    
    /// Resets all error tracking for a fresh start
    func resetAllTracking() {
        consecutiveFailures.removeAll()
        operationStartTimes.removeAll()
        partialResults.removeAll()
    }
}

// MARK: - Resilient Error Types

enum ResilientError: Error, LocalizedError {
    case tooManyConsecutiveFailures(operation: String, count: Int)
    case maxRetriesExceeded(operation: String, lastError: Error?)
    case operationStuck(operation: String, elapsedTime: TimeInterval)
    case insufficientProgress(operation: String, progress: Double, required: Double)
    
    var errorDescription: String? {
        switch self {
        case .tooManyConsecutiveFailures(let operation, let count):
            return "Operation '\(operation)' failed \(count) consecutive times"
        case .maxRetriesExceeded(let operation, let lastError):
            if let lastError = lastError {
                return "Operation '\(operation)' exceeded maximum retries. Last error: \(lastError.localizedDescription)"
            } else {
                return "Operation '\(operation)' exceeded maximum retries"
            }
        case .operationStuck(let operation, let elapsedTime):
            return "Operation '\(operation)' appears stuck after \(String(format: "%.1f", elapsedTime)) seconds"
        case .insufficientProgress(let operation, let progress, let required):
            return "Operation '\(operation)' has insufficient progress (\(String(format: "%.1f", progress * 100))%) - requires \(String(format: "%.1f", required * 100))%"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .tooManyConsecutiveFailures:
            return "Try again later or check system resources"
        case .maxRetriesExceeded:
            return "Check network connection and try again"
        case .operationStuck:
            return "Operation may be stuck - try stopping and restarting"
        case .insufficientProgress:
            return "Not enough progress to continue - consider restarting from beginning"
        }
    }
}
