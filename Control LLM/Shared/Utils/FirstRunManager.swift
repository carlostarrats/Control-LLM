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
    
    private init() {}
    
    /// Returns true if this is the first run of the app
    var isFirstRun: Bool {
        print("🔍 [\(Date())] FirstRunManager.isFirstRun called")
        let result = !UserDefaults.standard.bool(forKey: hasCompletedFirstRunKey)
        print("🔍 [\(Date())] FirstRunManager.isFirstRun result: \(result)")
        return result
    }
    
    /// Marks the first run as completed
    func markFirstRunComplete() {
        UserDefaults.standard.set(true, forKey: hasCompletedFirstRunKey)
        print("🚀 First run setup completed - future launches will be instant")
    }
    
    /// Resets first run status (for testing purposes)
    func resetFirstRunStatus() {
        UserDefaults.standard.removeObject(forKey: hasCompletedFirstRunKey)
        print("🔄 First run status reset - next launch will show setup screen")
    }
}
