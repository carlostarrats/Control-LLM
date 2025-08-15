import SwiftUI

// MARK: - Dynamic Color Extensions
extension Color {
    // Dynamic colors that can be customized through appearance settings
    static var dynamicRed: Color {
        ColorManager.shared.redColor
    }
    
    static var dynamicOrange: Color {
        ColorManager.shared.orangeColor
    }
    
    static var dynamicGreen: Color {
        ColorManager.shared.greenColor
    }
    
    static var dynamicPurple: Color {
        ColorManager.shared.purpleColor
    }
}

// MARK: - Color Replacement Helper
struct DynamicColorReplacer {
    // Helper to replace hardcoded colors with dynamic ones
    static func replaceColors() {
        // This will trigger a UI refresh when colors change
        ColorManager.shared.refreshColors()
    }
}
