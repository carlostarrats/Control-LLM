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
    @State private var isInitialized = false
    @State private var animationPhase: Double = 0.0
    @State private var physicsRampUp: Double = 0.0 // New: gradual physics ramp-up
    
    // Static particle positions for consistent behavior
    private static var cachedParticles: [Particle] = []
    private static var hasCachedParticles = false
    
    private func initializeParticles() {
        // Use cached particles if available, otherwise create new ones
        if Self.hasCachedParticles {
            particles = Self.cachedParticles
        } else {
            particles = (0..<particleCount).map { index in
                // Use simple circular distribution for clean ring shape
                let angle = Double(index) * 2.0 * .pi / Double(particleCount)
                
                // Start particles much closer to their natural ring position
                let radiusVariation = Double.random(in: 0.95...1.05) // Reduced from 0.8...1.2 for tighter initial formation
                let currentRadius = sphereRadius * radiusVariation
                
                // Basic circular coordinates with minimal randomness for initial formation
                let baseX = currentRadius * cos(angle)
                let baseY = currentRadius * sin(angle)
                
                // Much smaller random offset to prevent perfect circle but keep particles close to natural position
                let randomOffset = 8.0 // Reduced from 20.0 for tighter initial formation
                let finalX = baseX + Double.random(in: -randomOffset...randomOffset)
                let finalY = baseY + Double.random(in: -randomOffset...randomOffset)
                let finalZ = Double.random(in: -5...5) // Reduced from -10...10 for less depth variation initially
                
                // Start with much slower velocities to prevent dramatic movement
                let speed = Double.random(in: 0.2...0.4) // Reduced from 0.4...0.8 for gentler initial motion
                let velocityAngle = Double.random(in: 0...(2 * .pi))
                
                return Particle(
                    id: index,
                    x: finalX,
                    y: finalY,
                    z: finalZ,
                    vx: speed * cos(velocityAngle),
                    vy: speed * sin(velocityAngle),
                    vz: Double.random(in: -0.08...0.08) // Reduced from -0.15...0.15 for gentler Z movement
                )
            }
            
            // Cache the particles for future use
            Self.cachedParticles = particles
            Self.hasCachedParticles = true
        }
    }
    
    var body: some View {
        ZStack {
            // Show particles immediately - no more delay
            ForEach(particles.indices, id: \.self) { index in
                ParticleView(particle: $particles[index])
            }
        }
        .offset(x: -5, y: 0) // Move WOPR animation 5 points to the left
        .onAppear {
            // Initialize particles and start animation immediately
            initializeParticles()
            startAnimation()
            
            // Smooth fade-in animation for particles
            withAnimation(.easeIn(duration: 0.3)) {
                animationPhase = 1.0
            }
            
            // Gradually ramp up physics over 1 second to eliminate snap
            withAnimation(.easeInOut(duration: 1.0)) {
                physicsRampUp = 1.0
            }
        }
        .onDisappear {
            stopAnimation()
            // Reset physics ramp for next appearance
            physicsRampUp = 0.0
        }
    }
    
    private func startAnimation() {
        // Ensure we don't create multiple timers
        stopAnimation()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { _ in
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
            
            // Bounce off sphere boundary - gradually increase force
            let distance = sqrt(particles[i].x * particles[i].x + particles[i].y * particles[i].y + particles[i].z * particles[i].z)
            if distance > sphereRadius {
                let scale = sphereRadius / distance
                particles[i].x *= scale
                particles[i].y *= scale
                particles[i].z *= scale
                
                // Reverse velocity component that's pointing outward - apply ramp-up
                let nx = particles[i].x / distance
                let ny = particles[i].y / distance
                let nz = particles[i].z / distance
                
                let dot = particles[i].vx * nx + particles[i].vy * ny + particles[i].vz * nz
                let bounceForce = 2.0 * physicsRampUp // Gradually increase bounce force
                particles[i].vx -= bounceForce * dot * nx
                particles[i].vy -= bounceForce * dot * ny
                particles[i].vz -= bounceForce * dot * nz
            }
            
            // Keep particles away from center - gradually increase force
            let centerDistance = sqrt(particles[i].x * particles[i].x + particles[i].y * particles[i].y)
            if centerDistance < 80 {
                let pushForce = 0.1 * physicsRampUp // Gradually increase push force
                let pushX = particles[i].x / centerDistance * pushForce
                let pushY = particles[i].y / centerDistance * pushForce
                particles[i].vx += pushX
                particles[i].vy += pushY
            }
        }
        
        // Update cached particles for consistency
        Self.cachedParticles = particles
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
        Text(NSLocalizedString("Static Particle Visualizer", comment: ""))
            .foregroundColor(.white)
            .font(.title2)
            .padding()
        
        ParticleVisualizerView()
            .frame(width: 300, height: 300)
            .clipShape(Circle())
    }
}
