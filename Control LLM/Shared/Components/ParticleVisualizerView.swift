import SwiftUI

struct ParticleVisualizerView: View {
    @Binding var isSpeaking: Bool
    var onTap: (() -> Void)?
    
    // Particle system parameters
    private let particleCount = 2000
    private let sphereRadius: CGFloat = 150
    private let particleSize: CGFloat = 3.0
    
    var body: some View {
        ZStack {
            // Generate particles on sphere surface using spherical coordinates
            ForEach(0..<particleCount, id: \.self) { index in
                SphereParticle(
                    index: index,
                    totalParticles: particleCount,
                    sphereRadius: sphereRadius,
                    particleSize: particleSize
                )
            }
        }
        .frame(width: 300, height: 300)
        .onTapGesture {
            onTap?()
        }
    }
}

struct SphereParticle: View {
    let index: Int
    let totalParticles: Int
    let sphereRadius: CGFloat
    let particleSize: CGFloat
    
    // Generate proper 3D sphere surface points
    private var position: (x: CGFloat, y: CGFloat, z: CGFloat) {
        // Use golden ratio for better distribution (this was working)
        let goldenRatio = 1.618033988749895
        
        // Generate spherical coordinates
        let phi = acos(1 - 2.0 * Double(index) / Double(totalParticles))
        let theta = 2.0 * .pi * Double(index) * goldenRatio
        
        // Add minimal randomness to break up patterns but keep clean edges
        let randomPhi = phi + Double.random(in: -0.05...0.05)  // Much smaller randomness
        let randomTheta = theta + Double.random(in: -0.05...0.05)  // Much smaller randomness
        
        // Position on sphere surface (all at same radius)
        let x = sphereRadius * CGFloat(sin(randomPhi) * cos(randomTheta))
        let y = sphereRadius * CGFloat(sin(randomPhi) * sin(randomTheta))
        let z = sphereRadius * CGFloat(cos(randomPhi))
        
        return (x: x, y: y, z: z)
    }
    
    // Apply edge density bias to 3D points
    private var shouldShowParticle: Bool {
        let distanceFromViewCenter = sqrt(position.x * position.x + position.y * position.y)
        let edgeBias = distanceFromViewCenter / sphereRadius
        let probability = pow(edgeBias, 1.5) // Edge density bias
        
        return Double.random(in: 0...1) < probability
    }
    
    // Add Z-depth variation for 3D effect
    private var depthAdjustedSize: CGFloat {
        let depthFactor = (position.z + sphereRadius) / (2 * sphereRadius) // 0 to 1
        return particleSize * (0.5 + 0.5 * depthFactor) // Smaller when further back
    }
    
    private var depthOpacity: Double {
        let depthFactor = (position.z + sphereRadius) / (2 * sphereRadius) // 0 to 1
        return 0.4 + 0.6 * depthFactor // Dimmer when further back
    }
    
    var body: some View {
        if shouldShowParticle {
            Circle()
                .fill(Color.white)
                .frame(width: depthAdjustedSize, height: depthAdjustedSize)
                .position(
                    x: 150 + position.x,
                    y: 150 + position.y
                )
                .opacity(depthOpacity) // Depth-based opacity
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Static Particle Visualizer")
            .foregroundColor(.white)
            .font(.title2)
            .padding()
        
        ParticleVisualizerView(isSpeaking: .constant(false))
            .frame(width: 300, height: 300)
            .background(Color.black)
            .clipShape(Circle())
    }
    .background(Color.black)
}