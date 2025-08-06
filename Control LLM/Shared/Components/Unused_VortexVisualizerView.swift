import SwiftUI

struct VortexVisualizerView: View {
    @Binding var isSpeaking: Bool
    
    @State private var scale = 1.0
    @State private var time = 0.0
    @State private var individualPhases: [Double] = Array(0..<2400).map { Double($0) * 0.8 + Double.random(in: 0...2.0) }
    
    var body: some View {
        ZStack {
            // 3D sphere with dots
            Sphere3DView(
                time: time,
                individualPhases: individualPhases,
                isSpeaking: isSpeaking
            )
            .scaleEffect(scale)
        }
        .onAppear {
            startAnimation()
        }
        .onChange(of: isSpeaking) { oldValue, newValue in
            startAnimation()
        }
    }
    
    private func startAnimation() {
        let duration = isSpeaking ? 8.0 : 12.0
        
        withAnimation(.linear(duration: duration).repeatForever(autoreverses: true)) {
            time = 1.0
        }
        
        withAnimation(.easeInOut(duration: 0.5)) {
            scale = isSpeaking ? 1.1 : 1.0
        }
    }
}

struct Sphere3DView: View {
    let time: Double
    let individualPhases: [Double]
    let isSpeaking: Bool
    
    // Sphere parameters
    private let radius: Double = 83.0
    private let dotCount = 2400
    
    var body: some View {
        ZStack {
            ForEach(0..<dotCount, id: \.self) { index in
                SphereDot(
                    index: index,
                    time: time,
                    individualPhase: individualPhases[index],
                    isSpeaking: isSpeaking
                )
            }
        }
    }
}

struct SphereDot: View {
    let index: Int
    let time: Double
    let individualPhase: Double
    let isSpeaking: Bool
    
    private let radius: Double = 83.0
    
    private func getSpherePosition() -> (x: Double, y: Double, z: Double) {
        // Use golden ratio for better distribution
        let phi = acos(1.0 - 2.0 * (Double(index) + 0.5) / 2400.0)
        let theta = 2.0 * .pi * Double(index) * 0.618033988749895 // Golden ratio
        
        // Base position on sphere
        var x = radius * sin(phi) * cos(theta)
        var y = radius * sin(phi) * sin(theta)
        var z = radius * cos(phi)
        
        // Apply density gradient (more dots at poles, fewer at equator)
        let densityFactor = pow(abs(cos(phi)), 0.3)
        x *= densityFactor
        y *= densityFactor
        z *= densityFactor
        
        // Each dot moves in a unique organic pattern
        let dotTime = time + individualPhase // Each dot has its own time offset
        
        // Different motion styles based on dot index
        let motionStyle = index % 4
        let speed = 1.0 + Double(index % 3) * 0.3 // Different speeds
        let amplitude = 0.8 + Double(index % 5) * 0.4 // Different amplitudes
        
        switch motionStyle {
        case 0: // Circular motion
            x += sin(dotTime * .pi * speed) * amplitude * cos(theta)
            y += sin(dotTime * .pi * speed) * amplitude * sin(theta)
            z += cos(dotTime * .pi * 0.7) * 0.3
        case 1: // Figure-8 motion
            x += sin(dotTime * .pi * speed) * amplitude * cos(theta * 2)
            y += sin(dotTime * .pi * speed) * amplitude * sin(theta * 2)
            z += cos(dotTime * .pi * 0.8) * 0.4
        case 2: // Spiral motion
            x += sin(dotTime * .pi * speed) * amplitude * cos(theta + dotTime * .pi)
            y += sin(dotTime * .pi * speed) * amplitude * sin(theta + dotTime * .pi)
            z += sin(dotTime * .pi * 0.6) * 0.5
        case 3: // Wave motion
            x += sin(dotTime * .pi * speed) * amplitude * cos(theta * 3)
            y += sin(dotTime * .pi * speed) * amplitude * sin(theta * 3)
            z += cos(dotTime * .pi * 0.9) * 0.3
        default:
            break
        }
        
        return (x, y, z)
    }
    
    private func getDotSize() -> CGFloat {
        let baseSize = 0.8 + Double(index % 3) * 0.4
        return CGFloat(baseSize)
    }
    
    private func getDotOpacity() -> Double {
        let baseOpacity = 0.6 + Double(index % 4) * 0.1
        return baseOpacity
    }
    
    var body: some View {
        let position = getSpherePosition()
        
        Circle()
            .fill(Color.white)
            .frame(width: getDotSize(), height: getDotSize())
            .position(
                x: 200 + position.x,
                y: 200 + position.y
            )
            .opacity(getDotOpacity())
            .blur(radius: 0.3)
            .shadow(color: .white.opacity(0.3), radius: 1, x: 0, y: 0)
    }
}

#Preview {
    VortexVisualizerView(isSpeaking: .constant(false))
        .frame(width: 300, height: 300)
        .background(Color.black)
} 