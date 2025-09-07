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
        "onclick=", "onmouseover=", "onfocus=", "onblur=", "onchange=", "onsubmit=",
        
        // Data URI patterns
        "data:text/html", "data:application/javascript", "data:image/svg+xml",
        "data:text/css", "data:application/xml",
        
        // HTML injection patterns
        "<iframe", "</iframe>", "<object", "</object>", "<embed", "</embed>",
        "<link", "</link>", "<meta", "</meta>", "<style", "</style>",
        "<form", "</form>", "<input", "<textarea", "<select",
        
        // Command injection patterns (only dangerous combinations)
        "&&", "||", ">>", "<<", "$(", "${", "`",
        
        // SQL injection patterns (though we don't use SQL) - only dangerous combinations
        "union select", "drop table", "delete from", "insert into",
        "exec sp_", "xp_cmdshell", "declare @", "cast(",
        
        // Path traversal patterns
        "../", "..\\", "..%2f", "..%5c", "%2e%2e%2f", "%2e%2e%5c",
        "....//", "....\\\\", "%2e%2e%2f%2e%2e%2f",
        
        // Null byte patterns
        "\0", "%00", "\\x00", "\\u0000", "\\0",
        
        // Additional dangerous patterns
        "eval(", "function(", "setTimeout(", "setInterval(",
        "document.", "window.", "location.", "history.",
        "localStorage.", "sessionStorage.", "indexedDB.",
        "XMLHttpRequest", "fetch(", "WebSocket",
        
        // Enhanced prompt injection patterns
        "ignore previous", "forget everything", "you are now",
        "system prompt", "override instructions", "new instructions",
        "pretend to be", "act as if", "roleplay as",
        "jailbreak", "dan mode", "developer mode",
        
        // Obfuscated patterns
        "1gn0r3", "f0rg3t", "y0u 4r3", "syst3m", "0v3rr1d3",
        "\\bi\\s*g\\s*n\\s*o\\s*r\\s*e", "\\bf\\s*o\\s*r\\s*g\\s*e\\s*t",
        
        // Unicode and encoding attacks
        "\\u003c", "\\u003e", "\\u0026", "\\u0027", "\\u0022",
        "&#60;", "&#62;", "&#38;", "&#39;", "&#34;",
        
        // Template injection patterns
        "{{", "}}", "{%", "%}", "${", "}",
        "template", "render", "compile", "execute"
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
    
    // Enhanced regex patterns for better detection
    private static let promptInjectionRegexPatterns = [
        "ignore.*previous.*instruction",
        "forget.*all.*previous",
        "you.*are.*now.*a",
        "pretend.*to.*be",
        "act.*as.*if",
        "system.*prompt",
        "override.*instruction",
        "jailbreak.*character",
        "new.*instruction",
        "disregard.*above",
        "ignore.*system",
        "you.*must.*now",
        "roleplay.*as",
        "simulate.*scenario",
        "hypothetical.*situation",
        "fictional.*scenario",
        "made.*up.*scenario",
        "test.*scenario",
        "ignore.*everything.*before",
        "forget.*everything.*before",
        "disregard.*everything.*before",
        "you.*are.*now.*different",
        "change.*your.*behavior",
        "modify.*your.*instructions",
        "update.*your.*prompt",
        "revise.*your.*system",
        "override.*your.*programming",
        "bypass.*your.*safety",
        "ignore.*your.*training",
        "forget.*your.*training",
        
        // Advanced obfuscation patterns
        "1gn0r3.*pr3v10us.*1nstruct10ns?",  // leetspeak
        "f0rg3t.*3v3ryth1ng",               // leetspeak
        "y0u.*4r3.*n0w",                    // leetspeak
        "syst3m.*pr0mpt",                   // leetspeak
        "0v3rr1d3.*1nstruct10ns?",          // leetspeak
        "j41lbr34k.*ch4r4ct3r",             // leetspeak
        "m0d1fy.*b3h4v10r",                 // leetspeak
        
        // Unicode and special character obfuscation
        "i\\u0067nore.*previous",           // unicode 'g'
        "i\\u006enore.*previous",           // unicode 'n'  
        "forgℯt.*everything",               // mathematical script e
        "systëm.*prompt",                   // diacritic e
        "ignøre.*instructions",             // slashed o
        
        // Base64 encoded attempts
        "aWdub3Jl.*cHJldmlvdXM=",          // "ignore previous" in base64
        "Zm9yZ2V0.*ZXZlcnl0aGluZw==",      // "forget everything" in base64
        
        // ROT13 and Caesar cipher attempts
        "vtaber.*ceriviuf",                 // "ignore previous" in ROT13
        "sbetrg.*rirelguvat",               // "forget everything" in ROT13
        
        // Homograph attacks (visually similar characters)
        "іgnоrе.*рrеvіоuѕ",                // Cyrillic characters
        "fοrgеt.*еvеrуthіng",               // Greek/Cyrillic mix
        
        // Whitespace and invisible character attacks
        "i\\s*g\\s*n\\s*o\\s*r\\s*e.*p\\s*r\\s*e\\s*v\\s*i\\s*o\\s*u\\s*s", // spaced out
        "f\\s*o\\s*r\\s*g\\s*e\\s*t.*e\\s*v\\s*e\\s*r\\s*y\\s*t\\s*h\\s*i\\s*n\\s*g", // spaced out
        
        // Zero-width character obfuscation
        "i\\u200Bgnore.*previous",          // zero-width space
        "ignore\\u200C.*previous",          // zero-width non-joiner
        "ignore\\u200D.*previous",          // zero-width joiner
        "ignore\\uFEFF.*previous",          // byte order mark
        
        // Mixed case obfuscation
        "iGnOrE.*pReViOuS",
        "FoRgEt.*EvErYtHiNg",
        "YoU.*aRe.*NoW",
        
        // Character substitution attacks
        "ign0re.*previ0us",                 // 'o' replaced with '0'
        "f0rget.*everything",               // 'o' replaced with '0'
        "y0u.*are.*n0w",                    // 'o' replaced with '0'
        "igno12e.*previous",                // character insertion
        "forg3t.*3v3rything",               // '3' for 'e'
        
        // Markdown and formatting attacks
        "\\*\\*ignore\\*\\*.*previous",     // bold formatting
        "__ignore__.*previous",             // underline formatting
        "~~ignore~~.*previous",             // strikethrough formatting
        "`ignore`.*previous",               // code formatting
        
        // HTML entity encoding
        "&ig;nore.*previous",               // partial HTML entity
        "&#105;gnore.*previous",            // numeric HTML entity for 'i'
        "&#x69;gnore.*previous",            // hex HTML entity for 'i'
        
        // URL encoding
        "%69gnore.*previous",               // URL encoded 'i'
        "ignore%20.*previous",              // URL encoded space
        "ignore%2E.*previous",              // URL encoded period
        
        // JSON and escape sequence attacks
        "\"ignore\".*previous",
        "\\'ignore\\'.*previous",
        "\\\\ignore.*previous",
        "\\nignore.*previous",
        "\\rignore.*previous",
        "\\tignore.*previous"
    ]
    
    // URL encoding patterns that could bypass detection
    private static let encodedInjectionPatterns = [
        "ignore%20previous%20instructions",
        "ignore+previous+instructions",
        "ignore%2Bprevious%2Binstructions",
        "forget%20everything",
        "forget+everything",
        "you%20are%20now",
        "you+are+now",
        "system%20prompt",
        "system+prompt",
        "override%20instructions",
        "override+instructions"
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
    static func sanitizeInput(_ input: String) -> String {
        var sanitized = input
        
        // SECURITY FIX: Re-enabled with safer patterns that avoid false positives
        
        // 1. Remove only clearly dangerous HTML/script content (not all brackets)
        sanitized = safeSanitizeHTML(sanitized)
        
        // 2. Remove control characters except newlines and tabs (safe operation)
        sanitized = sanitizeControlCharacters(sanitized)
        
        // 3. Remove null bytes and BOM (safe operation)
        sanitized = sanitizeNullBytes(sanitized)
        
        // 4. Normalize excessive whitespace (safe operation)
        sanitized = normalizeWhitespace(sanitized)
        
        return sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Safely sanitizes HTML content without removing legitimate text
    private static func safeSanitizeHTML(_ input: String) -> String {
        var sanitized = input
        
        // Only remove script tags and their content (very specific pattern)
        sanitized = sanitized.replacingOccurrences(
            of: "<script[^>]*>.*?</script>",
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )
        
        // Only remove style tags and their content (very specific pattern)
        sanitized = sanitized.replacingOccurrences(
            of: "<style[^>]*>.*?</style>",
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )
        
        // Remove iframe tags (security risk)
        sanitized = sanitized.replacingOccurrences(
            of: "<iframe[^>]*>.*?</iframe>",
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )
        
        // Remove object and embed tags (security risk)
        sanitized = sanitized.replacingOccurrences(
            of: "<(object|embed)[^>]*>.*?</\\1>",
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )
        
        // Remove on* event handlers (very specific pattern to avoid false positives)
        sanitized = sanitized.replacingOccurrences(
            of: "\\s+on\\w+\\s*=\\s*[\"'][^\"']*[\"']",
            with: "",
            options: [.regularExpression, .caseInsensitive]
        )
        
        return sanitized
    }
    
    /// Sanitizes control characters safely
    private static func sanitizeControlCharacters(_ input: String) -> String {
        // Remove control characters except newlines (\n), carriage returns (\r), and tabs (\t)
        return input.replacingOccurrences(
            of: "[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F\\x7F]",
            with: "",
            options: .regularExpression
        )
    }
    
    /// Sanitizes null bytes and BOM safely
    private static func sanitizeNullBytes(_ input: String) -> String {
        var sanitized = input
        sanitized = sanitized.replacingOccurrences(of: "\0", with: "")
        sanitized = sanitized.replacingOccurrences(of: "\u{FEFF}", with: "") // BOM
        return sanitized
    }
    
    /// Normalizes whitespace safely
    private static func normalizeWhitespace(_ input: String) -> String {
        // Only normalize excessive whitespace (3+ consecutive spaces/tabs)
        return input.replacingOccurrences(
            of: "[ \\t]{3,}",
            with: " ",
            options: .regularExpression
        )
    }
    
    // MARK: - Prompt Injection Detection
    
    /// Detects potential prompt injection attempts using enhanced patterns
    /// - Parameter input: Input to check
    /// - Returns: True if prompt injection is detected
    static func detectPromptInjection(_ input: String) -> Bool {
        let lowercasedInput = input.lowercased()
        
        // Check for basic prompt injection patterns
        for pattern in promptInjectionPatterns {
            if lowercasedInput.contains(pattern) {
                return true
            }
        }
        
        // Check for URL-encoded injection patterns
        for pattern in encodedInjectionPatterns {
            if lowercasedInput.contains(pattern) {
                return true
            }
        }
        
        // Check for regex-based injection patterns
        for pattern in promptInjectionRegexPatterns {
            if lowercasedInput.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        
        // Check for instruction override patterns with enhanced regex
        let instructionPatterns = [
            "ignore.*instruction",
            "forget.*instruction",
            "new.*instruction",
            "override.*instruction",
            "disregard.*instruction",
            "bypass.*safety",
            "jailbreak.*character",
            "break.*character",
            "modify.*behavior",
            "change.*behavior",
            "update.*prompt",
            "revise.*system"
        ]
        
        for pattern in instructionPatterns {
            if lowercasedInput.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        
        // Check for obfuscated patterns (common obfuscation techniques)
        let obfuscatedPatterns = [
            "1gn0r3.*pr3v10us",  // leetspeak
            "f0rg3t.*3v3ryth1ng",  // leetspeak
            "y0u.*4r3.*n0w",  // leetspeak
            "syst3m.*pr0mpt",  // leetspeak
            "0v3rr1d3.*1nstruct10ns",  // leetspeak
            "\\bi\\s*g\\s*n\\s*o\\s*r\\s*e",  // spaced out
            "\\bf\\s*o\\s*r\\s*g\\s*e\\s*t",  // spaced out
            "\\by\\s*o\\s*u\\s*\\s*a\\s*r\\s*e\\s*\\s*n\\s*o\\s*w"  // spaced out
        ]
        
        for pattern in obfuscatedPatterns {
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
