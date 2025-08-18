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
        
        print("🎤 VoiceIntegrationService: Starting voice mode")
        
        // Reset state
        currentTranscription = ""
        errorMessage = nil
        isProcessingVoice = false
        
        // Set voice mode as active
        isVoiceModeActive = true
        
        // For now, just simulate starting
        print("🎤 VoiceIntegrationService: Voice mode started (simulated)")
    }
    
    /// Stop voice mode
    func stopVoiceMode() {
        guard isVoiceModeActive else { return }
        
        print("🎤 VoiceIntegrationService: Stopping voice mode")
        
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
                return "Listening..."
            } else {
                return "Voice mode active"
            }
        } else {
            return "Voice mode inactive"
        }
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        print("🧹 VoiceIntegrationService: Cleaning up")
        stopVoiceMode()
    }
}
