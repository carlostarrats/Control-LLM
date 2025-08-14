import Foundation
import AVFoundation
import UIKit

class FeedbackService {
    static let shared = FeedbackService()
    
    private init() {}
    
    // MARK: - Sound Effects
    
    enum SoundEffect: SystemSoundID {
        case messageSent = 1055
        case keyPress = 1104
        case beginRecord = 1113
        case endRecord = 1114
        case tabSwitch = 1256
    }
    
    func playSound(_ effect: SoundEffect) {
        AudioServicesPlaySystemSound(effect.rawValue)
    }
    
    // MARK: - Haptic Feedback
    
    func playHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
