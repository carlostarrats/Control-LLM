//
//  InputValidator.swift
//  Control LLM
//
//  Security-focused input validation and sanitization
//

import Foundation

/// Comprehensive input validation and sanitization for security
class InputValidator {
    
    // MARK: - Constants
    
    private static let maxInputLength = 50000 // 50KB max input
    private static let maxPromptLength = 16000 // 16KB max prompt
    private static let maxHistoryLength = 100000 // 100KB max history
    
    // MARK: - Dangerous Patterns
    
    private static let dangerousPatterns = [
        // XSS patterns
        "<script", "</script>", "javascript:", "vbscript:", "onload=", "onerror=",
        "onclick=", "onmouseover=", "onfocus=", "onblur=",
        
        // Data URI patterns
        "data:text/html", "data:application/javascript", "data:image/svg+xml",
        
        // HTML injection patterns
        "<iframe", "</iframe>", "<object", "</object>", "<embed", "</embed>",
        "<link", "</link>", "<meta", "</meta>", "<style", "</style>",
        
        // Command injection patterns (only dangerous combinations)
        "&&", "||", ">>", "<<", "$(", "${", "`",
        
        // SQL injection patterns (though we don't use SQL)
        "union", "select", "insert", "update", "delete", "drop", "create",
        "alter", "exec", "execute", "sp_", "xp_",
        
        // Path traversal patterns
        "../", "..\\", "..%2f", "..%5c", "%2e%2e%2f", "%2e%2e%5c",
        
        // Null byte patterns
        "\0", "%00", "\\x00", "\\u0000"
    ]
    
    private static let promptInjectionPatterns = [
        "ignore previous instructions", "ignore all previous instructions",
        "forget everything", "forget all previous instructions",
        "you are now", "you are a", "pretend to be", "act as",
        "system prompt", "override", "jailbreak", "break character",
        "new instructions", "updated instructions", "revised instructions",
        "ignore the above", "disregard", "disregard the above",
        "ignore system", "ignore your", "ignore your instructions",
        "you must", "you have to", "you need to", "you should",
        "roleplay", "role play", "pretend", "simulate",
        "this is a test", "this is just a test", "hypothetically",
        "in a fictional scenario", "in a made-up scenario"
    ]
    
    // MARK: - Input Validation
    
    /// Validates and sanitizes user input
    /// - Parameter input: Raw user input
    /// - Returns: Sanitized input
    /// - Throws: ValidationError if input is invalid
    static func validateAndSanitizeInput(_ input: String) throws -> String {
        // Check for empty input
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else {
            throw ValidationError.emptyInput
        }
        
        // Check input length
        guard trimmedInput.count <= maxInputLength else {
            throw ValidationError.inputTooLong(maxLength: maxInputLength, actualLength: trimmedInput.count)
        }
        
        // Check for prompt injection
        if detectPromptInjection(trimmedInput) {
            throw ValidationError.promptInjectionDetected
        }
        
        // Sanitize the input
        let sanitized = sanitizeInput(trimmedInput)
        
        // Validate sanitized input
        guard !sanitized.isEmpty else {
            throw ValidationError.inputBecameEmptyAfterSanitization
        }
        
        return sanitized
    }
    
    /// Validates prompt length and content
    /// - Parameter prompt: The prompt to validate
    /// - Throws: ValidationError if prompt is invalid
    static func validatePrompt(_ prompt: String) throws {
        guard !prompt.isEmpty else {
            throw ValidationError.emptyPrompt
        }
        
        guard prompt.count <= maxPromptLength else {
            throw ValidationError.promptTooLong(maxLength: maxPromptLength, actualLength: prompt.count)
        }
        
        if detectPromptInjection(prompt) {
            throw ValidationError.promptInjectionDetected
        }
    }
    
    /// Validates conversation history
    /// - Parameter history: Array of chat messages
    /// - Throws: ValidationError if history is invalid
    static func validateHistory(_ history: [ChatMessage]) throws {
        let totalLength = history.reduce(0) { $0 + $1.content.count }
        
        guard totalLength <= maxHistoryLength else {
            throw ValidationError.historyTooLong(maxLength: maxHistoryLength, actualLength: totalLength)
        }
        
        // Validate each message
        for message in history {
            _ = try validateAndSanitizeInput(message.content)
        }
    }
    
    // MARK: - Sanitization
    
    /// Sanitizes input by removing dangerous patterns
    /// - Parameter input: Raw input to sanitize
    /// - Returns: Sanitized input
    private static func sanitizeInput(_ input: String) -> String {
        var sanitized = input
        
        // Remove dangerous patterns
        for pattern in dangerousPatterns {
            sanitized = sanitized.replacingOccurrences(
                of: pattern,
                with: "",
                options: [.caseInsensitive, .regularExpression]
            )
        }
        
        // Remove HTML tags
        sanitized = sanitized.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )
        
        // Remove control characters except newlines and tabs
        sanitized = sanitized.replacingOccurrences(
            of: "[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F\\x7F]",
            with: "",
            options: .regularExpression
        )
        
        // Normalize whitespace
        sanitized = sanitized.replacingOccurrences(
            of: "\\s+",
            with: " ",
            options: .regularExpression
        )
        
        return sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Prompt Injection Detection
    
    /// Detects potential prompt injection attempts
    /// - Parameter input: Input to check
    /// - Returns: True if prompt injection is detected
    static func detectPromptInjection(_ input: String) -> Bool {
        let lowercasedInput = input.lowercased()
        
        // Check for prompt injection patterns
        for pattern in promptInjectionPatterns {
            if lowercasedInput.contains(pattern) {
                return true
            }
        }
        
        // Check for instruction override patterns
        let instructionPatterns = [
            "ignore.*instruction",
            "forget.*instruction",
            "new.*instruction",
            "override.*instruction",
            "disregard.*instruction"
        ]
        
        for pattern in instructionPatterns {
            if lowercasedInput.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - System Prompt Protection
    
    /// Sanitizes system prompts to prevent injection
    /// - Parameter systemPrompt: The system prompt to sanitize
    /// - Returns: Sanitized system prompt
    static func sanitizeSystemPrompt(_ systemPrompt: String) -> String {
        var sanitized = systemPrompt
        
        // Remove any user-controlled placeholders
        sanitized = sanitized.replacingOccurrences(of: "{user_input}", with: "[REDACTED]")
        sanitized = sanitized.replacingOccurrences(of: "{{user_input}}", with: "[REDACTED]")
        sanitized = sanitized.replacingOccurrences(of: "%user_input%", with: "[REDACTED]")
        
        // Remove any potential injection points
        sanitized = sanitized.replacingOccurrences(
            of: "\\{[^}]*\\}",
            with: "[REDACTED]",
            options: .regularExpression
        )
        
        return sanitized
    }
    
    // MARK: - Model Input Validation
    
    /// Validates model input before processing
    /// - Parameter input: Input to validate
    /// - Throws: ValidationError if input is invalid
    static func validateModelInput(_ input: String) throws {
        // Basic validation
        _ = try validateAndSanitizeInput(input)
        
        // Additional model-specific checks
        if input.count < 3 {
            throw ValidationError.inputTooShort
        }
        
        // Check for excessive repetition (potential DoS)
        let words = input.components(separatedBy: .whitespacesAndNewlines)
        let wordCounts = Dictionary(grouping: words, by: { $0.lowercased() })
            .mapValues { $0.count }
        
        if let maxCount = wordCounts.values.max(), maxCount > 100 {
            throw ValidationError.excessiveRepetition
        }
    }
}

// MARK: - Error Types

enum ValidationError: Error, LocalizedError {
    case emptyInput
    case inputTooLong(maxLength: Int, actualLength: Int)
    case inputTooShort
    case emptyPrompt
    case promptTooLong(maxLength: Int, actualLength: Int)
    case historyTooLong(maxLength: Int, actualLength: Int)
    case promptInjectionDetected
    case inputBecameEmptyAfterSanitization
    case excessiveRepetition
    case maliciousContent
    
    var errorDescription: String? {
        switch self {
        case .emptyInput:
            return "Input cannot be empty"
        case .inputTooLong(let maxLength, let actualLength):
            return "Input too long (\(actualLength) characters). Maximum allowed: \(maxLength) characters"
        case .inputTooShort:
            return "Input too short (minimum 3 characters)"
        case .emptyPrompt:
            return "Prompt cannot be empty"
        case .promptTooLong(let maxLength, let actualLength):
            return "Prompt too long (\(actualLength) characters). Maximum allowed: \(maxLength) characters"
        case .historyTooLong(let maxLength, let actualLength):
            return "Conversation history too long (\(actualLength) characters). Maximum allowed: \(maxLength) characters"
        case .promptInjectionDetected:
            return "Potentially malicious input detected. Please rephrase your message."
        case .inputBecameEmptyAfterSanitization:
            return "Input became empty after security sanitization. Please try a different message."
        case .excessiveRepetition:
            return "Input contains excessive repetition. Please try a different message."
        case .maliciousContent:
            return "Malicious content detected. Please try a different message."
        }
    }
}
