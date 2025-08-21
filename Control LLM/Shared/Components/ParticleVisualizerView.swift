import SwiftUI
import Combine

struct ParticleVisualizerView: View {
    // Simple, guaranteed-to-work particle system
    private let particleCount = 700
    private let particleSize: CGFloat = 4.0
    private let sphereRadius: CGFloat = 150.0
    private let motionPeriod: TimeInterval = 8.0
    
    @State private var particles: [Particle] = []
    @State private var timer: Timer?
    
    private func initializeParticles() {
        particles = (0..<particleCount).map { index in
            // Use simple circular distribution for clean ring shape
            let angle = Double(index) * 2.0 * .pi / Double(particleCount)
            let radiusVariation = Double.random(in: 0.8...1.2) // Small radius variation
            let currentRadius = sphereRadius * radiusVariation
            
            // Basic circular coordinates with some randomness
            let baseX = currentRadius * cos(angle)
            let baseY = currentRadius * sin(angle)
            
            // Add random offset to break up perfect circle but keep it natural
            let randomOffset = 20.0
            let finalX = baseX + Double.random(in: -randomOffset...randomOffset)
            let finalY = baseY + Double.random(in: -randomOffset...randomOffset)
            let finalZ = Double.random(in: -10...10) // Small z variation for depth
            
            // Give particles immediate velocity to prevent static appearance
            let speed = Double.random(in: 0.8...1.2)
            let velocityAngle = Double.random(in: 0...(2 * .pi))
            
            return Particle(
                id: index,
                x: finalX,
                y: finalY,
                z: finalZ,
                vx: speed * cos(velocityAngle),
                vy: speed * sin(velocityAngle),
                vz: Double.random(in: -0.3...0.3)
            )
        }
    }
    
    var body: some View {
        ZStack {
            // Simple particle rendering
            ForEach(particles.indices, id: \.self) { index in
                ParticleView(particle: $particles[index])
            }
        }
        .onAppear {
            initializeParticles()
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    

    
    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateParticles()
        }
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateParticles() {
        for i in particles.indices {
            // Update position
            particles[i].x += particles[i].vx
            particles[i].y += particles[i].vy
            particles[i].z += particles[i].vz
            
            // Bounce off sphere boundary
            let distance = sqrt(particles[i].x * particles[i].x + particles[i].y * particles[i].y + particles[i].z * particles[i].z)
            if distance > sphereRadius {
                let scale = sphereRadius / distance
                particles[i].x *= scale
                particles[i].y *= scale
                particles[i].z *= scale
                
                // Reverse velocity component that's pointing outward
                let nx = particles[i].x / distance
                let ny = particles[i].y / distance
                let nz = particles[i].z / distance
                
                let dot = particles[i].vx * nx + particles[i].vy * ny + particles[i].vz * nz
                particles[i].vx -= 2 * dot * nx
                particles[i].vy -= 2 * dot * ny
                particles[i].vz -= 2 * dot * nz
            }
            
            // Keep particles away from center
            let centerDistance = sqrt(particles[i].x * particles[i].x + particles[i].y * particles[i].y)
            if centerDistance < 80 {
                let pushForce = 0.1
                let pushX = particles[i].x / centerDistance * pushForce
                let pushY = particles[i].y / centerDistance * pushForce
                particles[i].vx += pushX
                particles[i].vy += pushY
            }
        }
    }
}

// Simple particle data structure
struct Particle {
    let id: Int
    var x: Double
    var y: Double
    var z: Double
    var vx: Double
    var vy: Double
    var vz: Double
}

// Simple particle view
struct ParticleView: View {
    @Binding var particle: Particle
    
    var body: some View {
        Circle()
            .fill(Color(red: 0.533, green: 0.533, blue: 0.533))
            .frame(width: 4, height: 4)
            .position(
                x: 200 + particle.x,
                y: 400 + particle.y
            )
            .opacity(0.8)
            .shadow(color: Color(red: 0.533, green: 0.533, blue: 0.533).opacity(0.6), radius: 3, x: 0, y: 0)
            .allowsHitTesting(false)
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Static Particle Visualizer")
            .foregroundColor(.white)
            .font(.title2)
            .padding()
        
        ParticleVisualizerView()
            .frame(width: 300, height: 300)
            .clipShape(Circle())
    }
}
