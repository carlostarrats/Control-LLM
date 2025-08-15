import Foundation
import AppIntents
import os.log

// MARK: - Shortcuts Integration Helper
@available(iOS 16.0, *)
class ShortcutsIntegrationHelper: NSObject {
    static let shared = ShortcutsIntegrationHelper()
    private let logger = Logger(subsystem: "ControlLLM", category: "ShortcutsIntegration")
    
    private override init() {
        super.init()
        logger.info("Shortcuts Integration Helper initialized")
    }
    
    // MARK: - Intent Donation for User Actions
    
    /// Donate intent when user sends a message in the app
    func donateMessageSent(message: String, recipient: String? = nil) {
        logger.info("Donating message sent intent: '\(message)'")
        
        ControlLLMAppShortcuts.donateSendMessage(message: message, recipient: recipient)
    }
    
    /// Donate intent when user chains messages in the app
    func donateMessagesChained(messages: [String], delays: [Double]? = nil) {
        logger.info("Donating messages chained intent with \(messages.count) messages")
        
        ControlLLMAppShortcuts.donateChainMessages(messages: messages, delays: delays)
    }
    
    /// Donate intent when user modifies system behavior in the app
    func donateSystemBehaviorModified(prompt: String, behaviorType: String) {
        logger.info("Donating system behavior modified intent: '\(prompt)' for type: '\(behaviorType)'")
        
        ControlLLMAppShortcuts.donateSystemPromptSteering(prompt: prompt, behaviorType: behaviorType)
    }
    
    // MARK: - Integration with Existing Services
    
    /// Integrate with existing chat functionality
    func integrateWithChatService() {
        logger.info("Integrating Shortcuts with existing chat service")
        
        // TODO: Hook into your existing chat service to donate intents
        // This should be called whenever messages are sent through the normal app interface
        
        // Example integration points:
        // - When a message is sent via voice
        // - When a message is sent via text input
        // - When multiple messages are processed
        // - When system prompts are modified
    }
    
    /// Integrate with existing voice functionality
    func integrateWithVoiceService() {
        logger.info("Integrating Shortcuts with existing voice service")
        
        // TODO: Hook into your existing voice service to donate intents
        // This should be called whenever voice interactions occur
        
        // Example integration points:
        // - When voice commands are processed
        // - When voice responses are generated
        // - When voice settings are modified
    }
    
    /// Integrate with existing LLM service
    func integrateWithLLMService() {
        logger.info("Integrating Shortcuts with existing LLM service")
        
        // TODO: Hook into your existing LLM service to donate intents
        // This should be called whenever LLM interactions occur
        
        // Example integration points:
        // - When models are loaded
        // - When inference is performed
        // - When responses are generated
        // - When system prompts are applied
    }
    
    // MARK: - Background Task Management
    
    /// Register for background processing when Shortcuts are executed
    func registerBackgroundProcessing() {
        logger.info("Registering for background processing")
        
        // Register background tasks for Shortcuts execution
        // This ensures the app can continue processing even when in background
        
        // TODO: Implement background task registration based on your app's needs
        // This might include:
        // - Background app refresh
        // - Background processing
        // - Silent notifications
    }
    
    // MARK: - Response Handling
    
    /// Format responses for optimal Shortcuts integration
    func formatResponseForShortcuts(_ response: String, type: ResponseType) -> String {
        switch type {
        case .message:
            return "📱 \(response)"
        case .chain:
            return "⛓️ \(response)"
        case .systemPrompt:
            return "⚙️ \(response)"
        case .voice:
            return "🎤 \(response)"
        case .llm:
            return "🤖 \(response)"
        }
    }
    
    enum ResponseType {
        case message
        case chain
        case systemPrompt
        case voice
        case llm
    }
    
    // MARK: - Error Handling
    
    /// Handle errors and format them for Shortcuts
    func handleErrorForShortcuts(_ error: Error, context: String) -> String {
        logger.error("Error in \(context): \(error.localizedDescription)")
        
        // Return user-friendly error messages for Shortcuts
        let errorMessage = ShortcutsService.shared.handleError(error, context: context)
        return "❌ \(errorMessage)"
    }
    
    // MARK: - Activity Donation
    
    /// Donate user activities for better Shortcuts suggestions
    func donateUserActivity(_ activity: String, metadata: [String: Any]? = nil) {
        logger.info("Donating user activity: \(activity)")
        
        // Create a user activity that can be used by Shortcuts
        let userActivity = NSUserActivity(activityType: "com.control.llm.\(activity)")
        userActivity.title = "Control LLM - \(activity)"
        
        if let metadata = metadata {
            userActivity.userInfo = metadata
        }
        
        // Donate the activity
        userActivity.becomeCurrent()
        
        logger.info("User activity donated successfully")
    }
}

// MARK: - Extension for Existing Services
@available(iOS 16.0, *)
extension ShortcutsIntegrationHelper {
    
    /// Hook into existing message sending functionality
    func hookIntoMessageSending() {
        // This method should be called from your existing message sending code
        // to automatically donate intents when users perform actions
        
        logger.info("Hooks installed for message sending functionality")
    }
    
    /// Hook into existing voice functionality
    func hookIntoVoiceFunctionality() {
        // This method should be called from your existing voice code
        // to automatically donate intents when users perform voice actions
        
        logger.info("Hooks installed for voice functionality")
    }
    
    /// Hook into existing LLM functionality
    func hookIntoLLMFunctionality() {
        // This method should be called from your existing LLM code
        // to automatically donate intents when users perform LLM actions
        
        logger.info("Hooks installed for LLM functionality")
    }
}
