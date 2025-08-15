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
    
    // Default colors (extracted from current app)
    static var defaultVisualizerColor: Color {
        // Using the exact color provided by the user
        return Color(hex: "#E4DAE5")
    }
    static let defaultRedColor = Color(hex: "#FF6B6B")
    static let defaultOrangeColor = Color(hex: "#F8C762")
    static let defaultGreenColor = Color(hex: "#3EBBA5")
    static let defaultPurpleColor = Color(hex: "#94A8E1")
    
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
        Color(hue: redColorHue / 360, saturation: 0.6, brightness: 0.7)
    }
    
    var currentOrangeColor: Color {
        Color(hue: orangeColorHue / 360, saturation: 0.6, brightness: 0.7)
    }
    
    var currentGreenColor: Color {
        Color(hue: greenColorHue / 360, saturation: 0.5, brightness: 0.7)
    }
    
    var currentPurpleColor: Color {
        Color(hue: purpleColorHue / 360, saturation: 0.4, brightness: 0.7)
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

    private init() {
        // Initialize with defaults
        self.redColor = AppearanceManager.defaultRedColor
        self.orangeColor = AppearanceManager.defaultOrangeColor
        self.greenColor = AppearanceManager.defaultGreenColor
        self.purpleColor = AppearanceManager.defaultPurpleColor
    }

    // Apply current editor values
    func refreshColors() {
        self.redColor = appearanceManager.currentRedColor
        self.orangeColor = appearanceManager.currentOrangeColor
        self.greenColor = appearanceManager.currentGreenColor
        self.purpleColor = appearanceManager.currentPurpleColor
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
                    .frame(width: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width, height: 2)
                
                // Vertical line grabber - fixed center position
                Rectangle()
                    .fill(Color(hex: "#EEEEEE"))
                    .frame(width: isPressed ? 4 : 2, height: isPressed ? 24 : 20)
                    .position(x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * geometry.size.width, y: 15)
                    .animation(.easeInOut(duration: 0.2), value: isPressed)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        isPressed = true
                        let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(gesture.location.x / geometry.size.width)
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
            return "Too intelligent for its own good, and far too intelligent for yours."
        case .particle:
            return "Learned not to play the game...but it's always ready to change the rules."
        case .flowing:
            return "Forged in the void, it ventures to the unknown."
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()
            
            // Content
            ScrollView {
                VStack(spacing: 8) {
                    // Control Unit Selection Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Control Unit Selection")
                            .font(.custom("IBMPlexMono", size: 18))
                            .foregroundColor(Color(hex: "#EEEEEE"))
                        
                        // Visualizer tabs - same styling as other design system elements
                        HStack(spacing: 0) {
                            ForEach(VisualizerType.allCases, id: \.self) { tab in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        visualizerState.selectedVisualizerType = tab
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: tab.icon)
                                            .font(.system(size: 14, weight: .medium))
                                        Text(tab.displayName)
                                            .font(.system(size: 14, weight: .medium))
                                    }
                                    .foregroundColor(visualizerState.selectedVisualizerType == tab ? Color.white : Color(hex: "#666666"))
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
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .multilineTextAlignment(.center)
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
                        Text("Main UI Colors")
                            .font(.custom("IBMPlexMono", size: 18))
                            .foregroundColor(Color(hex: "#EEEEEE"))
                        
                        Text("These colors affect text and other UI elements.")
                            .font(.custom("IBMPlexMono", size: 14))
                            .foregroundColor(Color(hex: "#BBBBBB"))
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
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    // Button Stack
                    VStack(spacing: 12) {
                        // Restore Defaults Button
                        Button(action: {
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
                        }) {
                            Text("Restore Defaults")
                                .font(.custom("IBMPlexMono", size: 16))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#2A2A2A"))
                                .cornerRadius(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Apply Changes Button
                        Button(action: {
                            // Apply changes by refreshing the ColorManager
                            colorManager.refreshColors()
                            hasVisualizerChanges = false
                            hasMainColorsChanges = false
                            hasChanges = false
                            dismiss()
                        }) {
                            Text("Apply Changes")
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
            .safeAreaInset(edge: .top) {
                // Header
                VStack(spacing: 0) {
                    // Grab bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(hex: "#666666"))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "paintbrush.pointed")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                            
                            Text("Appearance")
                                .font(.custom("IBMPlexMono", size: 20))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, 20)
                }
                .background(Color(hex: "#1D1D1D"))
            }
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