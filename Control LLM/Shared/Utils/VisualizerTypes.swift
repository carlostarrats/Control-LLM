import Foundation
import SwiftUI

// MARK: - Visualizer Type Enum
enum VisualizerType: Int, CaseIterable {
    case mycroft = 0
    case wopr = 1
    case tars = 2
    
    var displayName: String {
        switch self {
        case .mycroft: return "MYCROFT"
        case .wopr: return "WOPR"
        case .tars: return "TARS"
        }
    }
    
    var icon: String {
        switch self {
        case .mycroft: return "cpu.fill"
        case .wopr: return "cylinder.split.1x2"
        case .tars: return "atom"
        }
    }
}

// MARK: - Shared Visualizer State Manager
class VisualizerStateManager: ObservableObject {
    static let shared = VisualizerStateManager()
    
    @Published var selectedVisualizerType: VisualizerType = .mycroft
    
    private init() {}
}
