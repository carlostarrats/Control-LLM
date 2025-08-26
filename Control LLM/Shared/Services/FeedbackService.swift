import Foundation
import AVFoundation
import UIKit

class FeedbackService {
    static let shared = FeedbackService()
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    // MARK: - Sound Effects
    
    enum SoundEffect: SystemSoundID {
        case messageSent = 1306 // Changed from 1055 to a haptic-free sound
        case keyPress = 1104
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
