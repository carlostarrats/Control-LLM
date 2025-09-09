import Foundation
import SwiftUI

@MainActor
class VoiceIntegrationService: ObservableObject {
    static let shared = VoiceIntegrationService()
    
    // MARK: - Published Properties
    @Published var isVoiceModeActive = false
    @Published var currentTranscription = ""
    @Published var isProcessingVoice = false
    @Published var errorMessage: String?
    
    // MARK: - Callbacks
    var onVoiceInputComplete: ((String) -> Void)?
    var onVoiceResponseComplete: (() -> Void)?
    
    private init() {
        // Basic initialization
    }
    
    // MARK: - Public Methods
    
    /// Toggle voice mode for the current model
    func toggleVoiceMode() {
        if isVoiceModeActive {
            stopVoiceMode()
        } else {
            startVoiceMode()
        }
    }
    
    /// Start voice mode
    func startVoiceMode() {
        guard !isVoiceModeActive else { return }
        
        
        // Reset state
        currentTranscription = ""
        errorMessage = nil
        isProcessingVoice = false
        
        // Set voice mode as active
        isVoiceModeActive = true
        
        // For now, just simulate starting
    }
    
    /// Stop voice mode
    func stopVoiceMode() {
        guard isVoiceModeActive else { return }
        
        
        // Reset state
        isVoiceModeActive = false
        isProcessingVoice = false
        currentTranscription = ""
        errorMessage = nil
    }
    
    // MARK: - Status Methods
    
    /// Check if any voice service is currently active
    var isAnyServiceActive: Bool {
        return isVoiceModeActive && isProcessingVoice
    }
    
    /// Get current status description
    var statusDescription: String {
        if isVoiceModeActive {
            if isProcessingVoice {
                return NSLocalizedString("Listening...", comment: "")
            } else {
                return NSLocalizedString("Voice mode active", comment: "")
            }
        } else {
            return NSLocalizedString("Voice mode inactive", comment: "")
        }
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        stopVoiceMode()
    }
}
