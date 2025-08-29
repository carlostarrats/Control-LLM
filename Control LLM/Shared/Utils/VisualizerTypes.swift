import Foundation
import SwiftUI

// MARK: - Visualizer Type Enum
enum VisualizerType: Int, CaseIterable {
    case liquid = 0
    case particle = 1
    case flowing = 2
    
    var displayName: String {
        switch self {
        case .liquid: return NSLocalizedString("MYCROFT", comment: "")
        case .particle: return NSLocalizedString("WOPR", comment: "")
        case .flowing: return NSLocalizedString("TARS", comment: "")
        }
    }
    
    var icon: String {
        switch self {
        case .liquid: return "cpu.fill"
        case .particle: return "cylinder.split.1x2"
        case .flowing: return "atom"
        }
    }
}

// MARK: - Shared Visualizer State Manager
class VisualizerStateManager: ObservableObject {
    static let shared = VisualizerStateManager()
    
    @Published var selectedVisualizerType: VisualizerType = .liquid {
        didSet {
            saveSelectedVisualizerType()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let selectedVisualizerKey = "selectedVisualizerType"
    
    private init() {
        loadSelectedVisualizerType()
    }
    
    private func loadSelectedVisualizerType() {
        let savedRawValue = userDefaults.integer(forKey: selectedVisualizerKey)
        if let visualizerType = VisualizerType(rawValue: savedRawValue) {
            selectedVisualizerType = visualizerType
        }
        // If no saved value or invalid value, it will use the default .liquid
    }
    
    private func saveSelectedVisualizerType() {
        userDefaults.set(selectedVisualizerType.rawValue, forKey: selectedVisualizerKey)
    }
}
