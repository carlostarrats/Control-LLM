import SwiftUI

// MARK: - Color Management System
class AppearanceManager: ObservableObject {
    @Published var visualizerHue: Double = 0.0 // 0-360 degrees
    @Published var visualizerSaturation: Double = 1.0 // 0-1
    @Published var visualizerBrightness: Double = 1.0 // 0-1
    
    @Published var whiteTextHue: Double = 0.0 // For #EEEEEE
    @Published var grayTextHue: Double = 0.0 // For #BBBBBB
    @Published var redTextHue: Double = 0.0 // For #FF6B6B
    @Published var orangeTextHue: Double = 30.0 // For #F8C762
    @Published var greenTextHue: Double = 160.0 // For #3EBBA5
    @Published var blueTextHue: Double = 220.0 // For #94A8E1
    
    // Default colors (extracted from current app)
    static var defaultVisualizerColor: Color {
        // Using the exact color provided by the user
        return Color(hex: "#E4DAE5")
    }
    static let defaultWhiteText = Color(hex: "#EEEEEE")
    static let defaultGrayText = Color(hex: "#BBBBBB")
    static let defaultRedText = Color(hex: "#FF6B6B")
    static let defaultOrangeText = Color(hex: "#F8C762")
    static let defaultGreenText = Color(hex: "#3EBBA5")
    static let defaultBlueText = Color(hex: "#94A8E1")
    
    init() {
        // Initialize with the actual default HSB values for #E4DAE5
        visualizerHue = 300.0 // Purple hue (this is the actual default)
        visualizerSaturation = 0.06 // Low saturation for muted color
        visualizerBrightness = 0.90 // High brightness
        
        // Initialize text colors
        whiteTextHue = Self.defaultWhiteText.hsb.hue * 360
        grayTextHue = Self.defaultGrayText.hsb.hue * 360
        redTextHue = Self.defaultRedText.hsb.hue * 360
        orangeTextHue = Self.defaultOrangeText.hsb.hue * 360
        greenTextHue = Self.defaultGreenText.hsb.hue * 360
        blueTextHue = Self.defaultBlueText.hsb.hue * 360
    }
    
    func restoreDefaults() {
        // Restore to the actual default HSB values for #E4DAE5
        visualizerHue = 300.0 // Purple hue (this is the actual default)
        visualizerSaturation = 0.06 // Low saturation for muted color
        visualizerBrightness = 0.90 // High brightness
        
        whiteTextHue = Self.defaultWhiteText.hsb.hue * 360
        grayTextHue = Self.defaultGrayText.hsb.hue * 360
        redTextHue = Self.defaultRedText.hsb.hue * 360
        orangeTextHue = Self.defaultOrangeText.hsb.hue * 360
        greenTextHue = Self.defaultGreenText.hsb.hue * 360
        blueTextHue = Self.defaultBlueText.hsb.hue * 360
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
    
    var currentWhiteTextColor: Color {
        // Use the default white color when hue is at default, otherwise use the adjusted hue
        if abs(whiteTextHue - (Self.defaultWhiteText.hsb.hue * 360)) < 1 {
            return Self.defaultWhiteText
        } else {
            return Color(hue: whiteTextHue / 360, saturation: 0.3, brightness: 0.8)
        }
    }
    
    var currentGrayTextColor: Color {
        // Use the default gray color when hue is at default, otherwise use the adjusted hue
        if abs(grayTextHue - (Self.defaultGrayText.hsb.hue * 360)) < 1 {
            return Self.defaultGrayText
        } else {
            return Color(hue: grayTextHue / 360, saturation: 0.4, brightness: 0.6)
        }
    }
    
    var currentRedTextColor: Color {
        Color(hue: redTextHue / 360, saturation: 0.6, brightness: 0.7)
    }
    
    var currentOrangeTextColor: Color {
        Color(hue: orangeTextHue / 360, saturation: 0.6, brightness: 0.7)
    }
    
    var currentGreenTextColor: Color {
        Color(hue: greenTextHue / 360, saturation: 0.5, brightness: 0.7)
    }
    
    var currentBlueTextColor: Color {
        Color(hue: blueTextHue / 360, saturation: 0.4, brightness: 0.7)
    }
}

// MARK: - Simple Color Picker
struct SimpleColorPicker: View {
    @Binding var hue: Double
    @Binding var saturation: Double
    @Binding var brightness: Double
    
    var body: some View {
        VStack(spacing: 16) {
            // Hue slider
            VStack(alignment: .leading, spacing: 8) {
                Text("Hue")
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#BBBBBB"))
                
                CustomSlider(value: $hue, range: 0...360, accentColor: Color(hue: hue / 360, saturation: 1, brightness: 1))
            }
            
            // Saturation slider
            VStack(alignment: .leading, spacing: 8) {
                Text("Saturation")
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#BBBBBB"))
                
                CustomSlider(value: $saturation, range: 0...1, accentColor: Color(hue: hue / 360, saturation: saturation, brightness: brightness))
            }
            
            // Brightness slider
            VStack(alignment: .leading, spacing: 8) {
                Text("Brightness")
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#BBBBBB"))
                
                CustomSlider(value: $brightness, range: 0...1, accentColor: Color(hue: hue / 360, saturation: saturation, brightness: brightness))
            }
            
            // Color preview
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hue: hue / 360, saturation: saturation, brightness: brightness))
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(hex: "#333333"), lineWidth: 1)
                )
        }
        .padding()
        .background(Color(hex: "#2A2A2A"))
        .cornerRadius(4)
    }
}

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
                    .foregroundColor(Color(hex: "#BBBBBB"))
                
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

// MARK: - Visualizer Test Sheet
struct VisualizerTestSheet: View {
    @Environment(\.dismiss) private var dismiss
    let color: Color
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Grab bar and close button
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color(hex: "#666666"))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                
                HStack {
                    Text("Control Color Preview")
                        .font(.custom("IBMPlexMono", size: 18))
                        .foregroundColor(Color(hex: "#EEEEEE"))
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
                }
                .padding(.horizontal, 20)
                
                if isLoading {
                    // Loading state
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(Color(hex: "#BBBBBB"))
                        
                        Text("Loading Control Unit...")
                            .font(.custom("IBMPlexMono", size: 16))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                    }
                } else {
                    // Visualizer content
                    VStack(spacing: 20) {
                        Spacer()
                            .frame(height: 30)
                        
                        // Simple visualizer representation
                        ZStack {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "#2A2A2A"))
                                .frame(width: 200, height: 150)
                            
                            // Liquid effect simulation
                            ZStack {
                                Circle()
                                    .fill(color.opacity(0.3))
                                    .frame(width: 60, height: 60)
                                    .offset(x: -20, y: -10)
                                
                                Circle()
                                    .fill(color.opacity(0.6))
                                    .frame(width: 45, height: 45)
                                    .offset(x: 15, y: 10)
                                
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        
                        Text("This shows how the control unit will look with the selected color")
                            .font(.custom("IBMPlexMono", size: 14))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 40)
        }
        .onAppear {
            // Simulate loading time
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isLoading = false
            }
        }
    }
}

// MARK: - Main Appearance View
struct AppearanceView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var appearanceManager = AppearanceManager()
    @State private var hasChanges = false
    @State private var showingVisualizerTest = false
    @StateObject private var visualizerState = VisualizerStateManager.shared
    
    // Computed property for descriptive text based on selected visualizer
    private var descriptiveText: String {
        switch visualizerState.selectedVisualizerType {
        case .liquid:
            return "Too intelligent for its own good, and far too intelligent for yours."
        case .particle:
            return "Learned not to play the game...but it's always ready to change the rules."
        case .flowing:
            return "Forged in the void, it operates with the cold indifference of the universe itself."
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
                    
                    // 30px spacing between sections
                    Spacer()
                        .frame(height: 30)
                    
                    // Control Unit Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Control Unit Color")
                            .font(.custom("IBMPlexMono", size: 18))
                            .foregroundColor(Color(hex: "#EEEEEE"))
                        
                        VStack(spacing: 16) {
                            // Color picker
                            SimpleColorPicker(
                                hue: $appearanceManager.visualizerHue,
                                saturation: $appearanceManager.visualizerSaturation,
                                brightness: $appearanceManager.visualizerBrightness
                            )
                            .onChange(of: appearanceManager.visualizerHue) { _, _ in hasChanges = true }
                            .onChange(of: appearanceManager.visualizerSaturation) { _, _ in hasChanges = true }
                            .onChange(of: appearanceManager.visualizerBrightness) { _, _ in hasChanges = true }
                            
                            // Test Visualizer Button
                            Button(action: {
                                showingVisualizerTest = true
                            }) {
                                HStack {
                                    Image(systemName: "testtube.2")
                                        .font(.system(size: 16))
                                    
                                    Text("Test Control Unit Color")
                                        .font(.custom("IBMPlexMono", size: 16))
                                }
                                .foregroundColor(hasChanges ? Color(hex: "#94A8E1") : Color(hex: "#888888"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(hex: "#2A2A2A"))
                                .cornerRadius(4)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(!hasChanges)
                            .animation(.easeInOut(duration: 0.3), value: hasChanges)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // 30px spacing between sections
                    Spacer()
                        .frame(height: 30)
                    
                    // Text Elements Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Text Elements Color")
                            .font(.custom("IBMPlexMono", size: 18))
                            .foregroundColor(Color(hex: "#EEEEEE"))
                        
                        VStack(spacing: 16) {
                            HueSlider(
                                title: "Primary Text",
                                hue: $appearanceManager.whiteTextHue,
                                currentColor: appearanceManager.currentWhiteTextColor
                            )
                            .onChange(of: appearanceManager.whiteTextHue) { _, _ in hasChanges = true }
                            
                            HueSlider(
                                title: "Secondary Text",
                                hue: $appearanceManager.grayTextHue,
                                currentColor: appearanceManager.currentGrayTextColor
                            )
                            .onChange(of: appearanceManager.grayTextHue) { _, _ in hasChanges = true }
                            
                            HueSlider(
                                title: "Text Color 1",
                                hue: $appearanceManager.redTextHue,
                                currentColor: appearanceManager.currentRedTextColor
                            )
                            .onChange(of: appearanceManager.redTextHue) { _, _ in hasChanges = true }
                            
                            HueSlider(
                                title: "Text Color 2",
                                hue: $appearanceManager.orangeTextHue,
                                currentColor: appearanceManager.currentOrangeTextColor
                            )
                            .onChange(of: appearanceManager.orangeTextHue) { _, _ in hasChanges = true }
                            
                            HueSlider(
                                title: "Text Color 3",
                                hue: $appearanceManager.greenTextHue,
                                currentColor: appearanceManager.currentGreenTextColor
                            )
                            .onChange(of: appearanceManager.greenTextHue) { _, _ in hasChanges = true }
                            
                            HueSlider(
                                title: "Text Color 4",
                                hue: $appearanceManager.blueTextHue,
                                currentColor: appearanceManager.currentBlueTextColor
                            )
                            .onChange(of: appearanceManager.blueTextHue) { _, _ in hasChanges = true }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    // Button Stack
                    VStack(spacing: 12) {
                        // Restore Defaults Button
                        Button(action: {
                            appearanceManager.restoreDefaults()
                            hasChanges = true
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
                            // TODO: Apply changes to the app
                            hasChanges = false
                            dismiss()
                        }) {
                            Text("Apply Changes")
                                .font(.custom("IBMPlexMono", size: 16))
                                .foregroundColor(hasChanges ? Color(hex: "#3EBBA5") : Color(hex: "#888888"))
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
        .sheet(isPresented: $showingVisualizerTest) {
            VisualizerTestSheet(color: appearanceManager.currentVisualizerColor)
                .presentationDetents([.medium])
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
} 