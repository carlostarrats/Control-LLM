import Foundation
import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var appSettings = AppSettings()
    @Published var uiCustomization = UICustomization()
    @Published var developerInfo = DeveloperInfo()
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        // Load app settings
        appSettings = AppSettings(
            // Voice commands removed
            // Auto transcribe removed
            enableNotifications: true,
            language: NSLocalizedString("English", comment: "")
        )
        
        // Load UI customization
        uiCustomization = UICustomization(
            primaryColor: .blue,
            secondaryColor: .gray,
            useDarkMode: false,
            fontSize: .medium,
            enableHapticFeedback: true,
            enableAnimations: true
        )
        
        // Load developer info
        developerInfo = DeveloperInfo(
            appVersion: "1.0",
            buildNumber: "1",
            lastUpdated: Date(),
            apiEndpoint: "https://api.example.com",
            debugMode: false,
            logLevel: "Info"
        )
    }
    
    func saveSettings() {
        // TODO: Implement settings persistence
    }
    
    func resetToDefaults() {
        loadSettings()
    }
    
    func exportSettings() {
        // TODO: Implement settings export
    }
}

struct AppSettings {
    // Voice commands removed
    // Auto transcribe removed
    var enableNotifications: Bool = true
    var language: String = NSLocalizedString("English", comment: "")
}

struct UICustomization {
    var primaryColor: Color = .blue
    var secondaryColor: Color = .gray
    var useDarkMode: Bool = false
    var fontSize: FontSize = .medium
    var enableHapticFeedback: Bool = true
    var enableAnimations: Bool = true
}

struct DeveloperInfo {
    var appVersion: String = "1.1"
    var buildNumber: String = "1"
    var lastUpdated: Date = Date()
    var apiEndpoint: String = "https://api.example.com"
    var debugMode: Bool = false
    var logLevel: String = "Info"
}

enum FontSize: String, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var localizedName: String {
        switch self {
        case .small:
            return NSLocalizedString("Small", comment: "")
        case .medium:
            return NSLocalizedString("Medium", comment: "")
        case .large:
            return NSLocalizedString("Large", comment: "")
        }
    }
    
    var size: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        }
    }
} 