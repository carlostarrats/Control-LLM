import Foundation
import SwiftUI

// MARK: - Language Manager
@MainActor
class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var currentLanguage: String = "en"
    
    private let userDefaults = UserDefaults.standard
    private let languageKey = "selectedLanguage"
    
    private init() {
        loadLanguage()
    }
    
    // MARK: - Public Methods
    
    func setLanguage(_ language: String) {
        currentLanguage = language
        saveLanguage()
        updateAppLanguage()
    }
    
    func getAvailableLanguages() -> [(code: String, name: String)] {
        return [
            ("en", NSLocalizedString("English", comment: "")),
            ("es", NSLocalizedString("Spanish", comment: "")),
            ("fr", NSLocalizedString("French", comment: ""))
        ]
    }
    
    func getCurrentLanguageName() -> String {
        switch currentLanguage {
        case "en": return NSLocalizedString("English", comment: "")
        case "es": return NSLocalizedString("Spanish", comment: "")
        case "fr": return NSLocalizedString("French", comment: "")
        default: return NSLocalizedString("English", comment: "")
        }
    }
    
    // MARK: - Private Methods
    
    private func loadLanguage() {
        if let savedLanguage = userDefaults.string(forKey: languageKey) {
            currentLanguage = savedLanguage
        } else {
            // Default to system language if available, otherwise English
            let systemLanguage = Locale.current.languageCode ?? "en"
            if ["en", "es", "fr"].contains(systemLanguage) {
                currentLanguage = systemLanguage
            } else {
                currentLanguage = "en"
            }
        }
        updateAppLanguage()
    }
    
    private func saveLanguage() {
        userDefaults.set(currentLanguage, forKey: languageKey)
    }
    
    private func updateAppLanguage() {
        // For now, we'll use a simpler approach that works with the system
        // The actual language switching will be handled by the system
        // We just need to trigger UI updates
        
        // Post notification to update UI
        NotificationCenter.default.post(name: .languageChanged, object: nil)
        
        // Force UI update by triggering a state change
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}

// MARK: - Bundle Extension for Language Switching
extension Bundle {
    private static var bundle: Bundle = .main
    
    static func setLanguage(_ language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            print("Bundle: Could not find bundle for language: \(language)")
            return
        }
        
        Bundle.bundle = bundle
    }
    
    static func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        return Bundle.bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

// MARK: - Custom Localized String Function
func LocalizedString(_ key: String, comment: String = "") -> String {
    return Bundle.localizedString(forKey: key, value: comment, table: nil)
}

// MARK: - Notification Names
extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}
