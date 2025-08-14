import Foundation
import AppIntents
import os.log

// MARK: - Shortcuts Service
@available(iOS 16.0, *)
class ShortcutsService: NSObject {
    static let shared = ShortcutsService()
    private let logger = Logger(subsystem: "ControlLLM", category: "ShortcutsService")
    
    private override init() {
        super.init()
        logger.info("Shortcuts Service initialized")
    }
    
    // MARK: - Background Execution Support
    
    /// Handle background execution when called from Shortcuts
    func handleBackgroundExecution() async -> Bool {
        logger.info("Handling background execution from Shortcuts")
        
        do {
            // Perform any necessary background setup
            try await performBackgroundSetup()
            
            // Register for background processing if needed
            await registerBackgroundTasks()
            
            logger.info("Background execution setup completed successfully")
            return true
            
        } catch {
            logger.error("Background execution setup failed: \(error.localizedDescription)")
            return false
        }
    }
    
    private func performBackgroundSetup() async throws {
        // Initialize any services needed for background operation
        // This could include setting up the LLM service, loading models, etc.
        
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay for setup
        
        logger.info("Background setup completed")
    }
    
    private func registerBackgroundTasks() async {
        // Register for background processing if needed
        // This ensures the app can continue processing even when in background
        
        logger.info("Background tasks registered")
    }
    
    // MARK: - Integration with Existing Services
    
    /// Send a message through the existing LLM service
    func sendMessage(_ message: String, recipient: String? = nil) async throws -> String {
        logger.info("Sending message via Shortcuts: '\(message)'")
        
        // TODO: Integrate with your existing LLM service
        // This should call the same service that handles in-app messages
        
        // Simulate processing for now
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
        
        let response = "Shortcuts response: \(message)"
        logger.info("Message sent successfully via Shortcuts")
        
        // Donate the intent for future suggestions
        ControlLLMAppShortcuts.donateSendMessage(message: message, recipient: recipient)
        
        return response
    }
    
    /// Chain multiple messages with delays
    func chainMessages(_ messages: [String], delays: [Double]? = nil) async throws -> [String] {
        logger.info("Chaining \(messages.count) messages via Shortcuts")
        
        var responses: [String] = []
        let defaultDelays = Array(repeating: 1.0, count: messages.count)
        let actualDelays = delays ?? defaultDelays
        
        for (index, message) in messages.enumerated() {
            let delay = index < actualDelays.count ? actualDelays[index] : 1.0
            
            logger.info("Processing chained message \(index + 1): '\(message)' with delay \(delay)")
            
            // Process the message
            let response = try await sendMessage(message, recipient: "Chained")
            responses.append(response)
            
            // Apply delay if not the last message
            if index < messages.count - 1 {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        // Donate the intent for future suggestions
        ControlLLMAppShortcuts.donateChainMessages(messages: messages, delays: actualDelays)
        
        logger.info("Chain messages completed successfully via Shortcuts")
        return responses
    }
    
    /// Update system prompt for behavior steering
    func updateSystemPrompt(_ prompt: String, behaviorType: String) async throws {
        logger.info("Updating system prompt via Shortcuts: '\(prompt)' for behavior: '\(behaviorType)'")
        
        // TODO: Integrate with your existing system prompt management
        // This should update the same system prompt that the app uses
        
        // Simulate processing for now
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        // Store the prompt
        UserDefaults.standard.set(prompt, forKey: "SystemPrompt_\(behaviorType)")
        
        // Donate the intent for future suggestions
        ControlLLMAppShortcuts.donateSystemPromptSteering(prompt: prompt, behaviorType: behaviorType)
        
        logger.info("System prompt updated successfully via Shortcuts")
    }
    
    // MARK: - Error Handling
    
    /// Handle errors and return meaningful responses for Shortcuts
    func handleError(_ error: Error, context: String) -> String {
        logger.error("Error in \(context): \(error.localizedDescription)")
        
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
        
        logger.info("Background tasks registered for Shortcuts")
    }
}
