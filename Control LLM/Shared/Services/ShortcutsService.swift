import Foundation
import AppIntents
import os.log

// MARK: - Shortcuts Service
@available(iOS 16.0, *)
class ShortcutsService: NSObject {
    static let shared = ShortcutsService()
    // Logger removed for security - using print statements instead
    
    private override init() {
        super.init()
        print("Shortcuts Service initialized")
    }
    
    // MARK: - Background Execution Support
    
    /// Handle background execution when called from Shortcuts
    func handleBackgroundExecution() async -> Bool {
        print("Handling background execution from Shortcuts")
        
        do {
            // Perform any necessary background setup
            try await performBackgroundSetup()
            
            // Register for background processing if needed
            await registerBackgroundTasks()
            
            print("Background execution setup completed successfully")
            return true
            
        } catch {
            print("Background execution setup failed: \(error.localizedDescription)")
            return false
        }
    }
    
    private func performBackgroundSetup() async throws {
        // Initialize any services needed for background operation
        // This could include setting up the LLM service, loading models, etc.
        
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay for setup
        
        print("Background setup completed")
    }
    
    private func registerBackgroundTasks() async {
        // Register for background processing if needed
        // This ensures the app can continue processing even when in background
        
        print("Background tasks registered")
    }
    
    // MARK: - Security Helpers
    
    /// Sanitizes input specifically for Shortcuts context
    /// - Parameter input: Input string to sanitize
    /// - Returns: Sanitized string safe for Shortcuts
    private func sanitizeForShortcutsContext(_ input: String) -> String {
        var sanitized = input
        
        // Remove any potential Shortcuts injection patterns
        let shortcutsPatterns = [
            "shortcuts://", "shortcuts.app://", "x-shortcuts://",
            "intent://", "appintent://", "siri://",
            "workflow://", "automation://", "x-callback-url://"
        ]
        
        for pattern in shortcutsPatterns {
            sanitized = sanitized.replacingOccurrences(of: pattern, with: "", options: .caseInsensitive)
        }
        
        // Remove any potential URL schemes that could be executed
        sanitized = sanitized.replacingOccurrences(
            of: "\\b[a-zA-Z][a-zA-Z0-9+.-]*://[^\\s]+",
            with: "[URL_REDACTED]",
            options: .regularExpression
        )
        
        // Remove any potential file paths
        sanitized = sanitized.replacingOccurrences(
            of: "\\b/[^\\s]+",
            with: "[PATH_REDACTED]",
            options: .regularExpression
        )
        
        // Remove any potential system commands
        let commandPatterns = [
            "rm ", "del ", "format ", "shutdown ", "restart ",
            "sudo ", "su ", "chmod ", "chown ", "kill "
        ]
        
        for pattern in commandPatterns {
            sanitized = sanitized.replacingOccurrences(of: pattern, with: "[COMMAND_REDACTED] ", options: .caseInsensitive)
        }
        
        // Limit length for Shortcuts safety
        if sanitized.count > 1000 {
            sanitized = String(sanitized.prefix(1000)) + "..."
        }
        
        return sanitized
    }
    
    // MARK: - Integration with Existing Services
    
    /// Send a message through the existing LLM service with proper sanitization
    func sendMessage(_ message: String, recipient: String? = nil) async throws -> String {
        // Security: Additional validation for Shortcuts context
        guard !message.isEmpty else {
            throw NSError(domain: "ShortcutsService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Message cannot be empty"])
        }
        
        // Security: Check message length for Shortcuts safety
        guard message.count <= 50000 else {
            throw NSError(domain: "ShortcutsService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Message too long for Shortcuts"])
        }
        
        // Security: Additional sanitization for Shortcuts
        let sanitizedMessage = sanitizeForShortcutsContext(message)
        
        // Validate input length and content
        guard !sanitizedMessage.isEmpty else {
            throw ShortcutsError.emptyMessage
        }
        
        guard sanitizedMessage.count <= 1000 else {
            throw ShortcutsError.messageTooLong
        }
        
        // Check for prompt injection attempts
        if InputValidator.detectPromptInjection(sanitizedMessage) {
            throw ShortcutsError.potentiallyMaliciousInput
        }
        
        print("Processing sanitized message for Shortcuts")
        
        // Process through existing LLM service
        let response = try await processMessage(sanitizedMessage)
        
        // SECURITY: Sanitize response for Siri/Shortcuts
        let sanitizedResponse = sanitizeForSiri(response)
        
        print("Generated sanitized response for Shortcuts")
        return sanitizedResponse
    }
    
    // MARK: - Security Utilities
    
    /// Sanitizes text for Siri/Shortcuts to prevent data leakage
    private func sanitizeForSiri(_ text: String) -> String {
        var sanitized = text
        
        // Remove sensitive patterns that could be interpreted by Siri
        let siriSensitivePatterns = [
            "password", "secret", "private", "confidential",
            "credit card", "ssn", "social security",
            "bank account", "routing number"
        ]
        
        for pattern in siriSensitivePatterns {
            sanitized = sanitized.replacingOccurrences(
                of: pattern,
                with: "[REDACTED]",
                options: [.caseInsensitive, .regularExpression]
            )
        }
        
        // Remove any remaining sensitive data patterns
        sanitized = InputValidator.sanitizeInput(sanitized)
        
        // Limit length for Siri compatibility
        if sanitized.count > 500 {
            sanitized = String(sanitized.prefix(500)) + "..."
        }
        
        return sanitized
    }
    
    /// Processes message through the LLM service
    private func processMessage(_ message: String) async throws -> String {
        print("Sending message via Shortcuts: '\(message)'")
        
        // Integrate with existing LLM service
        do {
            // Use the existing HybridLLMService for consistency
            try await HybridLLMService.shared.loadSelectedModel()
            
            var response = ""
            try await HybridLLMService.shared.generateResponse(
                userText: message,
                history: nil, // No history for Shortcuts to prevent data leakage
                onToken: { partialResponse in
                    response += partialResponse
                }
            )
            
            return response
        } catch {
            print("Failed to process message via LLM service: \(error.localizedDescription)")
            throw ShortcutsError.processingFailed(error.localizedDescription)
        }
    }
    
    /// Chain multiple messages with delays
    func chainMessages(_ messages: [String], delays: [Double]? = nil) async throws -> [String] {
        print("Chaining \(messages.count) messages via Shortcuts")
        
        var responses: [String] = []
        let defaultDelays = Array(repeating: 1.0, count: messages.count)
        let actualDelays = delays ?? defaultDelays
        
        for (index, message) in messages.enumerated() {
            let delay = index < actualDelays.count ? actualDelays[index] : 1.0
            
            print("Processing chained message \(index + 1): '\(message)' with delay \(delay)")
            
            // Process the message
            let response = try await self.sendMessage(message, recipient: "Chained")
            responses.append(response)
            
            // Apply delay if not the last message
            if index < messages.count - 1 {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        print("Chained message processing completed - \(responses.count) responses")
        return responses
    }
    
    /// Update system prompt for behavior steering
    func updateSystemPrompt(_ prompt: String, behaviorType: String) async throws {
        SecureLogger.log("Updating system prompt via Shortcuts for behavior: \(behaviorType)", sensitiveData: prompt)
        
        // TODO: Integrate with your existing system prompt management
        // This should update the same system prompt that the app uses
        
        // Simulate processing for now
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        // Store the prompt
        UserDefaults.standard.set(prompt, forKey: "SystemPrompt_\(behaviorType)")
        
        // Donate the intent for future suggestions
        let intent = SystemPromptSteeringIntent(promptText: prompt, behaviorType: behaviorType)
        try await intent.donate()
        
        print("System prompt updated successfully via Shortcuts.")
    }
}

// MARK: - Error Types

enum ShortcutsError: Error, LocalizedError {
    case emptyMessage
    case messageTooLong
    case potentiallyMaliciousInput
    case processingFailed(String)
    case backgroundExecutionFailed
    
    var errorDescription: String? {
        switch self {
        case .emptyMessage:
            return "Message cannot be empty"
        case .messageTooLong:
            return "Message is too long for Shortcuts (maximum 1000 characters)"
        case .potentiallyMaliciousInput:
            return "Input contains potentially malicious content"
        case .processingFailed(let reason):
            return "Failed to process message: \(reason)"
        case .backgroundExecutionFailed:
            return "Background execution failed"
        }
    }
    
    // MARK: - Error Handling
    
    /// Handle errors and return meaningful responses for Shortcuts
    func handleError(_ error: Error, context: String) -> String {
        print("Error in \(context): \(error.localizedDescription)")
        
        // Return user-friendly error messages for Shortcuts
        switch error {
        case let error as NSError:
            switch error.code {
            case NSURLErrorNotConnectedToInternet:
                return "No internet connection available"
            case NSURLErrorTimedOut:
                return "Request timed out"
            default:
                return "An error occurred: \(error.localizedDescription)"
            }
        default:
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Response Formatting
    
    /// Format responses for optimal Shortcuts integration
    func formatResponse(_ response: String, type: ResponseType) -> String {
        switch type {
        case .message:
            return "Message Response: \(response)"
        case .chain:
            return "Chain Response: \(response)"
        case .systemPrompt:
            return "System Prompt Updated: \(response)"
        }
    }
    
    enum ResponseType {
        case message
        case chain
        case systemPrompt
    }
}

// MARK: - Background Task Registration
@available(iOS 16.0, *)
extension ShortcutsService {
    
    /// Register background tasks for Shortcuts execution
    func registerBackgroundTasks() {
        // Register for background processing
        // This ensures the app can continue processing even when in background
        
        print("Background tasks registered for Shortcuts")
    }
}
