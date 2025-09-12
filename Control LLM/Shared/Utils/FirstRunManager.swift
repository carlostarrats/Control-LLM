//
//  FirstRunManager.swift
//  Control LLM
//
//  Created by Carlos Tarrats on 9/8/25.
//

import Foundation

/// Manages first run detection and completion tracking
class FirstRunManager {
    static let shared = FirstRunManager()
    
    private let hasCompletedFirstRunKey = "hasCompletedFirstRun"
    private let lastInstalledVersionKey = "lastInstalledVersion"
    
    private init() {}
    
    /// Returns true if this is the first run of the app OR if the app version has changed
    var isFirstRun: Bool {
        // Check if this is a true first run (no completion flag)
        let hasCompletedFirstRun = UserDefaults.standard.bool(forKey: hasCompletedFirstRunKey)
        if !hasCompletedFirstRun {
            return true
        }
        
        // Check if version has changed (indicating an app update)
        let currentVersion = getCurrentAppVersion()
        let lastInstalledVersion = UserDefaults.standard.string(forKey: lastInstalledVersionKey)
        
        if lastInstalledVersion != currentVersion {
            NSLog("FirstRunManager: Version changed from \(lastInstalledVersion ?? "nil") to \(currentVersion) - forcing setup")
            return true
        }
        
        return false
    }
    
    /// Marks the first run as completed and stores current version
    func markFirstRunComplete() {
        UserDefaults.standard.set(true, forKey: hasCompletedFirstRunKey)
        let currentVersion = getCurrentAppVersion()
        UserDefaults.standard.set(currentVersion, forKey: lastInstalledVersionKey)
        NSLog("FirstRunManager: Marked setup complete for version \(currentVersion)")
    }
    
    /// Resets first run status (for testing purposes)
    func resetFirstRunStatus() {
        UserDefaults.standard.removeObject(forKey: hasCompletedFirstRunKey)
        UserDefaults.standard.removeObject(forKey: lastInstalledVersionKey)
    }
    
    /// Gets the current app version from Info.plist
    private func getCurrentAppVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            return "1.0.0"
        }
        return "\(version).\(build)"
    }
}
