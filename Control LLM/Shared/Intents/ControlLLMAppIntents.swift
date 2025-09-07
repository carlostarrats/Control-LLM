import Foundation
import AppIntents
import os.log

// MARK: - Shortcuts Security Helper
@available(iOS 16.0, *)
struct ShortcutsSecurityHelper {
    /// Sanitizes data specifically for Shortcuts context
    /// - Parameter input: Input string to sanitize
    /// - Returns: Sanitized string safe for Shortcuts
    static func sanitizeForShortcuts(_ input: String) -> String {
        var sanitized = input
        
        // Remove any potential Shortcuts injection patterns
        let shortcutsPatterns = [
            "shortcuts://", "shortcuts.app://", "x-shortcuts://",
            "intent://", "appintent://", "siri://",
            "workflow://", "automation://"
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
        
        // Limit length for Shortcuts safety
        if sanitized.count > 1000 {
            sanitized = String(sanitized.prefix(1000)) + "..."
        }
        
        return sanitized
    }
}

// MARK: - Control LLM App Intents for Shortcuts Integration

// MARK: - Send Message Intent
@available(iOS 16.0, *)
struct SendMessageIntent: AppIntent {
    static var title: LocalizedStringResource = "Send Message"
    static var description: LocalizedStringResource = "Send a message to the LLM and get a response"
    
    @Parameter(title: "Message", description: "The message to send")
    var messageText: String
    
    @Parameter(title: "Recipient", description: "Optional recipient identifier", default: "Default")
    var recipient: String
    
    init() {}
    
    init(messageText: String, recipient: String = "Default") {
        self.messageText = messageText
        self.recipient = recipient
    }
    
    func perform() async throws -> some IntentResult {
        let logger = Logger(subsystem: "ControlLLM", category: "SendMessageIntent")
        logger.info("Executing SendMessage intent for recipient: '\(recipient)'")
        
        do {
            // Security: Enhanced input validation for Shortcuts
            let sanitizedMessage = try InputValidator.validateAndSanitizeInput(messageText)
            
            // Additional sanitization for Shortcuts context
            let shortcutsSanitizedMessage = ShortcutsSecurityHelper.sanitizeForShortcuts(sanitizedMessage)
            
            // Process the message through the Shortcuts service
            let response = try await ShortcutsService.shared.sendMessage(shortcutsSanitizedMessage, recipient: recipient)
            
            // Sanitize response before returning to Shortcuts
            let sanitizedResponse = ShortcutsSecurityHelper.sanitizeForShortcuts(response)
            
            logger.info("SendMessage intent completed successfully")
            return .result(value: sanitizedResponse)
            
        } catch let error as ValidationError {
            logger.error("SendMessage intent failed validation: \(error.localizedDescription)")
            return .result(value: "❌ Input validation failed: \(error.localizedDescription)")
        } catch {
            logger.error("SendMessage intent failed: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Chain Messages Intent
@available(iOS 16.0, *)
struct ChainMessagesIntent: AppIntent {
    static var title: LocalizedStringResource = "Chain Messages"
    static var description: LocalizedStringResource = "Send multiple messages with delays between them"
    
    @Parameter(title: "Messages", description: "Array of messages to send")
    var messages: [String]
    
    @Parameter(title: "Delays", description: "Array of delays in seconds between messages", default: [1.0])
    var delays: [Double]
    
    init() {}
    
    init(messages: [String], delays: [Double] = [1.0]) {
        self.messages = messages
        self.delays = delays
    }
    
    func perform() async throws -> some IntentResult {
        let logger = Logger(subsystem: "ControlLLM", category: "ChainMessagesIntent")
        logger.info("Executing ChainMessages intent with \(messages.count) messages")
        
        do {
            // Security: Validate all messages before processing
            var sanitizedMessages: [String] = []
            for message in messages {
                let sanitizedMessage = try InputValidator.validateAndSanitizeInput(message)
                sanitizedMessages.append(sanitizedMessage)
            }
            
            // Process the chained messages through the Shortcuts service
            let responses = try await ShortcutsService.shared.chainMessages(sanitizedMessages, delays: delays)
            
            logger.info("ChainMessages intent completed successfully")
            return .result(value: responses.joined(separator: "\n"))
            
        } catch let error as ValidationError {
            logger.error("ChainMessages intent failed validation: \(error.localizedDescription)")
            return .result(value: "❌ Input validation failed: \(error.localizedDescription)")
        } catch {
            logger.error("ChainMessages intent failed: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - System Prompt Steering Intent
@available(iOS 16.0, *)
struct SystemPromptSteeringIntent: AppIntent {
    static var title: LocalizedStringResource = "System Prompt Steering"
    static var description: LocalizedStringResource = "Modify app behavior via system prompt"
    
    @Parameter(title: "Prompt", description: "The system prompt to apply")
    var promptText: String
    
    @Parameter(title: "Behavior Type", description: "Type of behavior to modify", default: "general")
    var behaviorType: String
    
    init() {}
    
    init(promptText: String, behaviorType: String = "general") {
        self.promptText = promptText
        self.behaviorType = behaviorType
    }
    
    func perform() async throws -> some IntentResult {
        let logger = Logger(subsystem: "ControlLLM", category: "SystemPromptSteeringIntent")
        logger.info("Executing SystemPromptSteering intent for behavior: '\(behaviorType)'")
        
        do {
            // Security: Validate system prompt input
            let sanitizedPrompt = try InputValidator.validateAndSanitizeInput(promptText)
            
            // Update the system prompt through the Shortcuts service
            try await ShortcutsService.shared.updateSystemPrompt(sanitizedPrompt, behaviorType: behaviorType)
            
            logger.info("SystemPromptSteering intent completed successfully")
            return .result(value: "System prompt updated successfully")
            
        } catch let error as ValidationError {
            logger.error("SystemPromptSteering intent failed validation: \(error.localizedDescription)")
            return .result(value: "❌ Input validation failed: \(error.localizedDescription)")
        } catch {
            logger.error("SystemPromptSteering intent failed: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - App Shortcuts Provider
@available(iOS 16.0, *)
struct ControlLLMAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SendMessageIntent(),
            phrases: [
                "Send message in \(.applicationName)",
                "Ask \(.applicationName)",
                "Message \(.applicationName)"
            ],
            shortTitle: "Send Message",
            systemImageName: "message"
        )
        
        AppShortcut(
            intent: ChainMessagesIntent(),
            phrases: [
                "Chain messages in \(.applicationName)",
                "Send multiple messages to \(.applicationName)",
                "Batch messages in \(.applicationName)"
            ],
            shortTitle: "Chain Messages",
            systemImageName: "link"
        )
        
        AppShortcut(
            intent: SystemPromptSteeringIntent(),
            phrases: [
                "Update system prompt in \(.applicationName)",
                "Modify behavior in \(.applicationName)",
                "Steer \(.applicationName)"
            ],
            shortTitle: "System Prompt",
            systemImageName: "gear"
        )
    }
}

// MARK: - Intent Donation Helper
@available(iOS 16.0, *)
extension ControlLLMAppShortcuts {
    
    /// Donate a SendMessage intent when user sends a message
    static func donateSendMessage(message: String, recipient: String? = nil) {
        let intent = SendMessageIntent(messageText: message, recipient: recipient ?? "Default")
        // App Intents automatically handle donation when intents are used
        // No manual donation needed
    }
    
    /// Donate a ChainMessages intent when user chains messages
    static func donateChainMessages(messages: [String], delays: [Double]? = nil) {
        let intent = ChainMessagesIntent(messages: messages, delays: delays ?? [1.0])
        // App Intents automatically handle donation when intents are used
        // No manual donation needed
    }
    
    /// Donate a SystemPromptSteering intent when user modifies system behavior
    static func donateSystemPromptSteering(prompt: String, behaviorType: String) {
        let intent = SystemPromptSteeringIntent(promptText: prompt, behaviorType: behaviorType)
        // App Intents automatically handle donation when intents are used
        // No manual donation needed
    }
}
