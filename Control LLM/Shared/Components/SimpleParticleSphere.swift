import SwiftUI

struct SimpleParticleSphere: View {
    @Binding var isSpeaking: Bool
    @State private var animationTime: Double = 0
    
    // Simple particle sphere using SwiftUI circles
    private let particleCount = 900
    private let sphereRadius: CGFloat = 156 // 30% larger than previous (120 * 1.3)
    
    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { i in
                Circle()
                    .fill(particleColor(for: i))
                    .frame(width: 2, height: 2)
                    .position(particlePosition(for: i))
            }
        }
        .frame(width: 300, height: 300)
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                animationTime = 1.0
            }
        }
    }
    
    private func particlePosition(for index: Int) -> CGPoint {
        // Create a specific radial distribution based on user feedback
        // 10% of particles in the center, 40% at the edges, with a gradient in between.
        let normalizedIndex = Double(index) / Double(particleCount)
        let radiusFraction: CGFloat
        
        if normalizedIndex < 0.1 { // 10% of particles in the inner 20% of the radius
            let bandIndex = normalizedIndex / 0.1
            radiusFraction = 0.2 * bandIndex
        } else if normalizedIndex < 0.6 { // 50% of particles in the middle
            let bandIndex = (normalizedIndex - 0.1) / 0.5
            radiusFraction = 0.2 + 0.6 * bandIndex // From 20% to 80%
        } else { // 40% of particles in the outer 20%
            let bandIndex = (normalizedIndex - 0.6) / 0.4
            radiusFraction = 0.8 + 0.2 * bandIndex // From 80% to 100%
        }
        
        let adjustedRadius = sphereRadius * radiusFraction
        
        // Golden ratio distribution on sphere surface
        let phi = acos(1.0 - 2.0 * (Double(index) + 0.5) / Double(particleCount))
        let theta = 2.0 * .pi * Double(index) * 0.618033988749895 // Golden ratio
        
        // Convert spherical coordinates to 3D cartesian
        let x3d = adjustedRadius * sin(phi) * cos(theta)
        let y3d = adjustedRadius * sin(phi) * sin(theta)
        let z3d = adjustedRadius * cos(phi)
        
        // Simple perspective projection (z affects size/opacity)
        let perspective: CGFloat = 1.0 + z3d / (sphereRadius * 2)
        
        // Project 3D to 2D screen coordinates
        let screenX = (x3d * perspective) + 150
        let screenY = (y3d * perspective) + 150
        
        return CGPoint(x: screenX, y: screenY)
    }
    
    private func particleColor(for index: Int) -> Color {
        // Create a specific radial distribution based on user feedback
        let normalizedIndex = Double(index) / Double(particleCount)
        let radiusFraction: CGFloat
        
        if normalizedIndex < 0.1 { // 10% of particles in the inner 20% of the radius
            let bandIndex = normalizedIndex / 0.1
            radiusFraction = 0.2 * bandIndex
        } else if normalizedIndex < 0.6 { // 50% of particles in the middle
            let bandIndex = (normalizedIndex - 0.1) / 0.5
            radiusFraction = 0.2 + 0.6 * bandIndex
        } else { // 40% of particles in the outer 20%
            let bandIndex = (normalizedIndex - 0.6) / 0.4
            radiusFraction = 0.8 + 0.2 * bandIndex
        }
        
        let adjustedRadius = sphereRadius * radiusFraction
        
        // Golden ratio distribution on sphere surface
        let phi = acos(1.0 - 2.0 * (Double(index) + 0.5) / Double(particleCount))
        
        // Only calculate Z coordinate for lighting
        let z3d = adjustedRadius * cos(phi)
        
        // Calculate lighting based on Z-depth (viewer is looking along positive Z axis)
        // Particles closer to viewer (positive Z) are brighter, further away (negative Z) are darker
        let lightingFactor = (z3d + adjustedRadius) / (2 * adjustedRadius) // Normalize to 0-1
        let minBrightness: CGFloat = 0.2 // Don't let particles get completely dark
        let brightness = minBrightness + (1.0 - minBrightness) * lightingFactor
        
        // Apply lighting to base color #eeeeee
        let baseColor = Color(hex: "#eeeeee")
        return adjustColorBrightness(baseColor, brightness: brightness)
    }
    
    private func adjustColorBrightness(_ color: Color, brightness: CGFloat) -> Color {
        let uiColor = UIColor(color)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var currentBrightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &currentBrightness, alpha: &alpha)
        
        return Color(hue: hue, saturation: saturation, brightness: brightness, opacity: alpha)
    }
}

#Preview {
    SimpleParticleSphere(isSpeaking: .constant(false))
        .background(Color.black)
}
