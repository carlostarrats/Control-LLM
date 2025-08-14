import Foundation
import SwiftUI

// MARK: - Visualizer Type Enum
enum VisualizerType: Int, CaseIterable {
    case liquid = 0
    case particle = 1
    case flowing = 2
    
    var displayName: String {
        switch self {
        case .liquid: return "Hydrogen"
        case .particle: return "Carbon"
        case .flowing: return "Mercury"
        }
    }
    
    var icon: String {
        switch self {
        case .liquid: return "drop.fill"
        case .particle: return "sparkles"
        case .flowing: return "waveform.path.ecg"
        }
    }
}

// MARK: - Shared Visualizer State Manager
class VisualizerStateManager: ObservableObject {
    static let shared = VisualizerStateManager()
    
    @Published var selectedVisualizerType: VisualizerType = .liquid
    
    private init() {}
}
