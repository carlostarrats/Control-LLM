import SwiftUI

// MARK: - Color Management System
class AppearanceManager: ObservableObject {
    static let shared = AppearanceManager()
    
    @Published var visualizerHue: Double = 0.0 // 0-360 degrees
    @Published var visualizerSaturation: Double = 1.0 // 0-1
    @Published var visualizerBrightness: Double = 1.0 // 0-1
    
    // Main UI colors that can be customized
    @Published var redColorHue: Double = 0.0 // For #FF6B6B
    @Published var orangeColorHue: Double = 30.0 // For #F8C762
    @Published var greenColorHue: Double = 160.0 // For #3EBBA5
    @Published var purpleColorHue: Double = 220.0 // For #94A8E1
    @Published var whiteTextColorHue: Double = 0.0 // For #EEEEEE (white text)
    @Published var greyTextColorHue: Double = 0.0 // For #BBBBBB (grey text)
    
    // Track the last committed state for restoration
    var lastCommittedRedColorHue: Double = 0.0
    var lastCommittedOrangeColorHue: Double = 30.0
    var lastCommittedGreenColorHue: Double = 160.0
    var lastCommittedPurpleColorHue: Double = 220.0
    var lastCommittedWhiteTextColorHue: Double = 0.0
    var lastCommittedGreyTextColorHue: Double = 0.0
    
    // Default colors (extracted from current app)
    static var defaultVisualizerColor: Color {
        // Using the exact color provided by the user
        return Color(hex: "#E4DAE5")
    }
    static let defaultRedColor = Color(hex: "#FF6B6B")
    static let defaultOrangeColor = Color(hex: "#F8C762")
    static let defaultGreenColor = Color(hex: "#3EBBA5")
    static let defaultPurpleColor = Color(hex: "#94A8E1")
    static let defaultWhiteTextColor = Color(hex: "#EEEEEE")
    static let defaultGreyTextColor = Color(hex: "#BBBBBB")
    
    private init() {
        // Initialize with the actual default HSB values for #E4DAE5
        visualizerHue = 300.0 // Purple hue (this is the actual default)
        visualizerSaturation = 0.06 // Low saturation for muted color
        visualizerBrightness = 0.90 // High brightness
        
        // Initialize main UI colors
        redColorHue = Self.defaultRedColor.hsb.hue * 360
        orangeColorHue = Self.defaultOrangeColor.hsb.hue * 360
        greenColorHue = Self.defaultGreenColor.hsb.hue * 360
        purpleColorHue = Self.defaultPurpleColor.hsb.hue * 360
        whiteTextColorHue = Self.defaultWhiteTextColor.hsb.hue * 360
        greyTextColorHue = Self.defaultGreyTextColor.hsb.hue * 360
        
        // Initialize last committed state to defaults
        lastCommittedRedColorHue = redColorHue
        lastCommittedOrangeColorHue = orangeColorHue
        lastCommittedGreenColorHue = greenColorHue
        lastCommittedPurpleColorHue = purpleColorHue
        lastCommittedWhiteTextColorHue = whiteTextColorHue
        lastCommittedGreyTextColorHue = greyTextColorHue
    }
    
    func restoreDefaults() {
        // Restore to the actual default HSB values for #E4DAE5
        visualizerHue = 300.0 // Purple hue (this is the actual default)
        visualizerSaturation = 0.06 // Low saturation for muted color
        visualizerBrightness = 0.90 // High brightness
        
        redColorHue = Self.defaultRedColor.hsb.hue * 360
        orangeColorHue = Self.defaultOrangeColor.hsb.hue * 360
        greenColorHue = Self.defaultGreenColor.hsb.hue * 360
        purpleColorHue = Self.defaultPurpleColor.hsb.hue * 360
        whiteTextColorHue = Self.defaultWhiteTextColor.hsb.hue * 360
        greyTextColorHue = Self.defaultGreyTextColor.hsb.hue * 360
        
        // Update last committed state to defaults
        lastCommittedRedColorHue = redColorHue
        lastCommittedOrangeColorHue = orangeColorHue
        lastCommittedGreenColorHue = greenColorHue
        lastCommittedPurpleColorHue = purpleColorHue
        lastCommittedWhiteTextColorHue = whiteTextColorHue
        lastCommittedGreyTextColorHue = greyTextColorHue
    }
    
    // Save current state as committed
    func commitCurrentState() {
        lastCommittedRedColorHue = redColorHue
        lastCommittedOrangeColorHue = orangeColorHue
        lastCommittedGreenColorHue = greenColorHue
        lastCommittedPurpleColorHue = purpleColorHue
        lastCommittedWhiteTextColorHue = whiteTextColorHue
        lastCommittedGreyTextColorHue = greyTextColorHue
    }
    
    // Restore to last committed state (not defaults)
    func restoreToLastCommitted() {
        redColorHue = lastCommittedRedColorHue
        orangeColorHue = lastCommittedOrangeColorHue
        greenColorHue = lastCommittedGreenColorHue
        purpleColorHue = lastCommittedPurpleColorHue
        whiteTextColorHue = lastCommittedWhiteTextColorHue
        greyTextColorHue = lastCommittedGreyTextColorHue
    }
    
    var currentVisualizerColor: Color {
        // Use the default visualizer color when all values are at their actual defaults
        if abs(visualizerHue - 300.0) < 1 &&
           abs(visualizerSaturation - 0.06) < 0.01 &&
           abs(visualizerBrightness - 0.90) < 0.01 {
            return Self.defaultVisualizerColor
        } else {
            return Color(hue: visualizerHue / 360, saturation: visualizerSaturation, brightness: visualizerBrightness)
        }
    }
    
    var currentVisualizerInactiveColor: Color {
        // Inactive state is 40% brightness (60% reduction)
        return currentVisualizerColor.opacity(0.4)
    }
    
    // Main UI colors that affect buttons and UI elements
    var currentRedColor: Color {
        Color(hue: redColorHue / 360, saturation: 0.62, brightness: 0.96)
    }
    
    var currentOrangeColor: Color {
        Color(hue: orangeColorHue / 360, saturation: 0.6, brightness: 0.8)
    }
    
    var currentGreenColor: Color {
        Color(hue: greenColorHue / 360, saturation: 0.35, brightness: 0.73)
    }
    
    var currentPurpleColor: Color {
        Color(hue: purpleColorHue / 360, saturation: 0.4, brightness: 0.8)
    }
    
    var currentWhiteTextColor: Color {
        // Create a color scale that includes the current white (#EEEEEE) but also allows for other colors
        // When hue is 0 (default), use the exact white color
        // When hue changes, use a light tinted version that's still readable
        if abs(whiteTextColorHue - 0.0) < 1 {
            return Self.defaultWhiteTextColor
        } else {
            // For other hues, use a light tinted version with low saturation and high brightness
            return Color(hue: whiteTextColorHue / 360, saturation: 0.15, brightness: 0.95)
        }
    }
    
    var currentGreyTextColor: Color {
        // Create a color scale that includes the current grey (#BBBBBB) but also allows for other colors
        // When hue is 0 (default), use the exact grey color
        // When hue changes, use a medium tinted version that's still readable
        if abs(greyTextColorHue - 0.0) < 1 {
            return Self.defaultGreyTextColor
        } else {
            // For other hues, use a medium tinted version with moderate saturation and brightness
            return Color(hue: greyTextColorHue / 360, saturation: 0.25, brightness: 0.75)
        }
    }
}

// MARK: - Color Manager for App-wide Access
class ColorManager: ObservableObject {
    static let shared = ColorManager()
    private let appearanceManager = AppearanceManager.shared

    // Applied colors (change only when user taps Apply)
    @Published private(set) var redColor: Color
    @Published private(set) var orangeColor: Color
    @Published private(set) var greenColor: Color
    @Published private(set) var purpleColor: Color
    @Published private(set) var whiteTextColor: Color
    @Published private(set) var greyTextColor: Color

    private init() {
        // Initialize with defaults
        self.redColor = AppearanceManager.defaultRedColor
        self.orangeColor = AppearanceManager.defaultOrangeColor
        self.greenColor = AppearanceManager.defaultGreenColor
        self.purpleColor = AppearanceManager.defaultPurpleColor
        self.whiteTextColor = AppearanceManager.defaultWhiteTextColor
        self.greyTextColor = AppearanceManager.defaultGreyTextColor
    }

    // Apply current editor values
    func refreshColors() {
        self.redColor = appearanceManager.currentRedColor
        self.orangeColor = appearanceManager.currentOrangeColor
        self.greenColor = appearanceManager.currentGreenColor
        self.purpleColor = appearanceManager.currentPurpleColor
        self.whiteTextColor = appearanceManager.currentWhiteTextColor
        self.greyTextColor = appearanceManager.currentGreyTextColor
    }
}

// (Removed SimpleColorPicker - Control Unit Color editor is no longer used)

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let accentColor: Color
    @State private var isPressed = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .fill(Color(hex: "#444444"))
                    .frame(height: 2)
                
                // Filled track
                Rectangle()
                    .fill(accentColor)
                    .frame(width: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * 350, height: 2)
                
                // Vertical line grabber - fixed center position
                Rectangle()
                    .fill(ColorManager.shared.whiteTextColor)
                    .frame(width: isPressed ? 4 : 2, height: isPressed ? 24 : 20)
                    .position(x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * 350, y: 15)
                    .animation(.easeInOut(duration: 0.2), value: isPressed)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        isPressed = true
                        let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(gesture.location.x / 350)
                        value = max(range.lowerBound, min(range.upperBound, newValue))
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
        }
        .frame(height: 30)
    }
}

// MARK: - Hue Slider
struct HueSlider: View {
    let title: String
    @Binding var hue: Double
    let currentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(currentColor)
                
                Spacer()
                
                // Color preview
                RoundedRectangle(cornerRadius: 4)
                    .fill(currentColor)
                    .frame(width: 20, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(hex: "#333333"), lineWidth: 1)
                    )
            }
            
            // Hue slider
            CustomSlider(value: $hue, range: 0...360, accentColor: currentColor)
        }
    }
}

// (Removed VisualizerTestSheet - preview sheet no longer used)

// MARK: - Main Appearance View
struct AppearanceView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var appearanceManager = AppearanceManager.shared
    @State private var hasChanges = false
    @State private var hasVisualizerChanges = false
    @State private var hasMainColorsChanges = false
    @State private var suppressChangeTracking = false
    // Removed visualizer preview/testing UI
    @StateObject private var visualizerState = VisualizerStateManager.shared
    @StateObject private var colorManager = ColorManager.shared
    
    // Computed property for descriptive text based on selected visualizer
    private var descriptiveText: String {
        switch visualizerState.selectedVisualizerType {
        case .liquid:
            return NSLocalizedString("Too intelligent for its own good, and far too intelligent for yours.", comment: "")
        case .particle:
            return NSLocalizedString("Learned not to play the game...but it's always ready to change the rules.", comment: "")
        case .flowing:
            return NSLocalizedString("Forged in the void, ready to follow you into the unknown.", comment: "")
        }
    }
    
    // Check if the currently applied colors are at their default values
    private var isAtDefaults: Bool {
        let defaultRed = AppearanceManager.defaultRedColor.hsb.hue * 360
        let defaultOrange = AppearanceManager.defaultOrangeColor.hsb.hue * 360
        let defaultGreen = AppearanceManager.defaultGreenColor.hsb.hue * 360
        let defaultPurple = AppearanceManager.defaultPurpleColor.hsb.hue * 360
        let defaultWhite = AppearanceManager.defaultWhiteTextColor.hsb.hue * 360
        let defaultGrey = AppearanceManager.defaultGreyTextColor.hsb.hue * 360
        
        // Check against the last committed state (what's actually applied)
        return abs(appearanceManager.lastCommittedRedColorHue - defaultRed) < 1 &&
               abs(appearanceManager.lastCommittedOrangeColorHue - defaultOrange) < 1 &&
               abs(appearanceManager.lastCommittedGreenColorHue - defaultGreen) < 1 &&
               abs(appearanceManager.lastCommittedPurpleColorHue - defaultPurple) < 1 &&
               abs(appearanceManager.lastCommittedWhiteTextColorHue - defaultWhite) < 1 &&
               abs(appearanceManager.lastCommittedGreyTextColorHue - defaultGrey) < 1
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with grabber
                VStack(spacing: 0) {
                    // Enhanced grab bar with larger invisible touch area
                    RoundedRectangle(cornerRadius: 3)
                        .fill(ColorManager.shared.greenColor)
                        .frame(width: 50, height: 6)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .contentShape(Rectangle())
                        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 80, height: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 40)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // Visual feedback during drag
                                }
                                .onEnded { value in
                                    // More sensitive dismissal - reduce threshold
                                    if value.translation.height > 20 {
                                        // If there are uncommitted changes, restore to last committed state before dismissing
                                        if hasChanges {
                                            suppressChangeTracking = true
                                            appearanceManager.restoreToLastCommitted()
                                            suppressChangeTracking = false
                                        }
                                        dismiss()
                                    }
                                }
                        )
                    
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "eye")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(ColorManager.shared.purpleColor)
                            
                            Text(NSLocalizedString("APPEARANCE", comment: ""))
                                .font(.custom("IBMPlexMono", size: 12))
                                .foregroundColor(ColorManager.shared.purpleColor)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        Button(action: {
                            // If there are uncommitted changes, restore to last committed state before dismissing
                            if hasChanges {
                                suppressChangeTracking = true
                                appearanceManager.restoreToLastCommitted()
                                suppressChangeTracking = false
                            }
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(ColorManager.shared.orangeColor)
                                .frame(width: 20, height: 20)
                                .contentShape(Rectangle())
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, 10)
                }
                .background(Color(hex: "#1D1D1D"))
                
                // Content
                ScrollView {
                    VStack(spacing: 8) {
                        // Control Unit Selection Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text(NSLocalizedString("Control Unit Selection", comment: ""))
                                .font(.custom("IBMPlexMono", size: 18))
                                .foregroundColor(ColorManager.shared.whiteTextColor)
                            
                            // Visualizer tabs - same styling as other design system elements
                            HStack(spacing: 0) {
                                ForEach(VisualizerType.allCases, id: \.self) { tab in
                                    Button(action: {
                                        // Change visual state immediately for instant feedback
                                        visualizerState.selectedVisualizerType = tab
                                        // Play light haptic feedback for immediate response
                                        FeedbackService.shared.playHaptic(.light)
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: tab.icon)
                                                .font(.system(size: 14, weight: .medium))
                                            Text(tab.displayName)
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(visualizerState.selectedVisualizerType == tab ? ColorManager.shared.whiteTextColor : Color(hex: "#666666"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(visualizerState.selectedVisualizerType == tab ? Color(hex: "#333333") : Color.clear)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .background(Color(hex: "#1A1A1A"))
                            .cornerRadius(4)
                            
                            // Descriptive text that changes based on selected tab
                            Text(descriptiveText)
                                .font(.custom("IBMPlexMono", size: 14))
                                .foregroundColor(ColorManager.shared.greyTextColor)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 11)
                        
                        // Extra spacing before Main UI Colors
                        Spacer()
                            .frame(height: 30)

                        // Remove Control Unit Color editor and immediately continue to Main UI Colors
                        
                        // Main UI Colors Section
                        VStack(alignment: .leading, spacing: 0) {
                            Text(NSLocalizedString("Main UI Colors", comment: ""))
                                .font(.custom("IBMPlexMono", size: 18))
                                .foregroundColor(ColorManager.shared.whiteTextColor)
                            
                            Text(NSLocalizedString("These colors affect text and other UI elements, including the primary white text color and secondary grey text color.", comment: ""))
                                .font(.custom("IBMPlexMono", size: 14))
                                .foregroundColor(ColorManager.shared.greyTextColor)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 8)
                                .padding(.bottom, 16)

                            // Forced gap before the first hex label
                            Color.clear
                                .frame(height: 16)

                            VStack(spacing: 16) {
                                HueSlider(
                                    title: appearanceManager.currentRedColor.hexString,
                                    hue: $appearanceManager.redColorHue,
                                    currentColor: appearanceManager.currentRedColor
                                )
                                .onChange(of: appearanceManager.redColorHue) { _, _ in if !suppressChangeTracking { hasMainColorsChanges = true; hasChanges = true } }
                                
                                HueSlider(
                                    title: appearanceManager.currentOrangeColor.hexString,
                                    hue: $appearanceManager.orangeColorHue,
                                    currentColor: appearanceManager.currentOrangeColor
                                )
                                .onChange(of: appearanceManager.orangeColorHue) { _, _ in if !suppressChangeTracking { hasMainColorsChanges = true; hasChanges = true } }
                                
                                HueSlider(
                                    title: appearanceManager.currentGreenColor.hexString,
                                    hue: $appearanceManager.greenColorHue,
                                    currentColor: appearanceManager.currentGreenColor
                                )
                                .onChange(of: appearanceManager.greenColorHue) { _, _ in if !suppressChangeTracking { hasMainColorsChanges = true; hasChanges = true } }
                                
                                HueSlider(
                                    title: appearanceManager.currentPurpleColor.hexString,
                                    hue: $appearanceManager.purpleColorHue,
                                    currentColor: appearanceManager.currentPurpleColor
                                )
                                .onChange(of: appearanceManager.purpleColorHue) { _, _ in if !suppressChangeTracking { hasMainColorsChanges = true; hasChanges = true } }
                                
                                HueSlider(
                                    title: appearanceManager.currentWhiteTextColor.hexString,
                                    hue: $appearanceManager.whiteTextColorHue,
                                    currentColor: appearanceManager.currentWhiteTextColor
                                )
                                .onChange(of: appearanceManager.whiteTextColorHue) { _, _ in if !suppressChangeTracking { hasMainColorsChanges = true; hasChanges = true } }
                                
                                HueSlider(
                                    title: appearanceManager.currentGreyTextColor.hexString,
                                    hue: $appearanceManager.greyTextColorHue,
                                    currentColor: appearanceManager.currentGreyTextColor
                                )
                                .onChange(of: appearanceManager.greyTextColorHue) { _, _ in if !suppressChangeTracking { hasMainColorsChanges = true; hasChanges = true } }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                        
                        // Button Stack
                        VStack(spacing: 12) {
                            // Restore Defaults Button
                            Button(action: {
                                if !isAtDefaults {
                                    FeedbackService.shared.playHaptic(.light)
                                    // Prevent onChange handlers from re-activating Apply during reset
                                    suppressChangeTracking = true
                                    // Reset editor values to defaults
                                    appearanceManager.restoreDefaults()
                                    // Immediately apply defaults app-wide
                                    colorManager.refreshColors()
                                    // Clear change flags since we're now in a clean default state
                                    hasVisualizerChanges = false
                                    hasMainColorsChanges = false
                                    hasChanges = false
                                    // Re-enable change tracking after state settles
                                    DispatchQueue.main.async {
                                        suppressChangeTracking = false
                                    }
                                }
                            }) {
                                Text(NSLocalizedString("Restore Defaults", comment: ""))
                                    .font(.custom("IBMPlexMono", size: 16))
                                    .foregroundColor(isAtDefaults ? Color(hex: "#888888") : ColorManager.shared.greenColor)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(hex: "#2A2A2A"))
                                    .cornerRadius(4)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isAtDefaults)
                            
                            // Apply Changes Button
                            Button(action: {
                                FeedbackService.shared.playHaptic(.light)
                                // Save current state as committed
                                appearanceManager.commitCurrentState()
                                // Apply changes by refreshing the ColorManager
                                colorManager.refreshColors()
                                hasVisualizerChanges = false
                                hasMainColorsChanges = false
                                hasChanges = false
                                dismiss()
                            }) {
                                Text(NSLocalizedString("Apply Changes", comment: ""))
                                    .font(.custom("IBMPlexMono", size: 16))
                                    .foregroundColor(hasChanges ? ColorManager.shared.greenColor : Color(hex: "#888888"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(hex: "#2A2A2A"))
                                    .cornerRadius(4)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(!hasChanges)
                            .animation(.easeInOut(duration: 0.3), value: hasChanges)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
                .background(Color(hex: "#1D1D1D"))
            }
            .background(Color(hex: "#1D1D1D"))
        }
    }
}

// MARK: - Color Extensions
extension Color {
    var hsb: (hue: Double, saturation: Double, brightness: Double) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return (Double(hue), Double(saturation), Double(brightness))
    }

    // Hex string helper (RGB) for live titles
    var hexString: String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let ri = Int(round(r * 255))
        let gi = Int(round(g * 255))
        let bi = Int(round(b * 255))
        return String(format: "#%02X%02X%02X", ri, gi, bi)
    }
} 