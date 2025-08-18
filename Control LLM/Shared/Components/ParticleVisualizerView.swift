import SwiftUI
import Combine

struct ParticleVisualizerView: View {
    
    // Particle system parameters
    private let particleCount = 400 // Reduced from 2000 for better performance
    private let particleSize: CGFloat = 4.0 // Slightly larger to compensate for fewer particles
    
    private var sphereRadius: CGFloat = 150 // Keep constant size
     
    // Liquid motion parameters
    @State private var motionPhase: [Double]
    @State private var motionCancellable: Cancellable?
    private let motionPeriod: TimeInterval = 8.0 // Restore original timing for smooth, biological motion
    

    
    init() {
        
        // Initialize motion phase with random offsets for each particle
        let initialPhases = (0..<400).map { _ in Double.random(in: 0...(2 * .pi)) }
        self._motionPhase = .init(initialValue: initialPhases)
    }
    
    var body: some View {
        ZStack {
            // Generate particles on sphere surface using spherical coordinates
            ForEach(0..<particleCount, id: \.self) { index in
                                        SphereParticle(
                            index: index,
                            totalParticles: particleCount,
                            sphereRadius: sphereRadius,
                            particleSize: particleSize,
                            motionPhase: motionPhase[index % motionPhase.count]
                        )
            }
            

        }
        .frame(width: 400, height: 400) // Fixed size to match other visualizers
        .coordinateSpace(name: "visualizer")
        .onAppear {
            startMotionTimer()
        }
        .onDisappear {
            stopMotionTimer()
        }
        // Voice animation removed
    }
    

    
    private func startMotionTimer() {
        guard motionCancellable == nil else { return }
        
        // Start animation immediately
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            updateMotion()
        }
        
        // Continue animation periodically
        motionCancellable = Timer.publish(every: motionPeriod, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                updateMotion()
            }
    }
    
    private func stopMotionTimer() {
        motionCancellable?.cancel()
        motionCancellable = nil
    }
    

    
    private func updateMotion() {
        // Gradually increment phases for smooth, continuous motion without twisting
        let newPhases = motionPhase.enumerated().map { index, currentPhase in
            // Add a larger increment that varies per particle for organic movement
            // Increased by 20% and sized to complete full cycle in one timer interval
            let baseIncrement = (2 * .pi) / 8.0 // Full circle divided by timer interval
            let increment = baseIncrement * (0.8 + Double(index % 7) * 0.05) // 20% faster with variation
            var newPhase = currentPhase + increment
            
            // Keep phase within 0 to 2π range
            if newPhase > 2 * .pi {
                newPhase -= 2 * .pi
            }
            
            return newPhase
        }
        
        withAnimation(.easeInOut(duration: 12.0)) { // Longer than timer interval for overlapping animations
            motionPhase = newPhases
        }
    }
}

struct SphereParticle: View {
    let index: Int
    let totalParticles: Int
    let sphereRadius: CGFloat
    let particleSize: CGFloat
    let motionPhase: Double
    
    // Store random offsets as state to avoid recomputation
    @State private var randomPhiOffset: Double
    @State private var randomThetaOffset: Double
    
    init(index: Int, totalParticles: Int, sphereRadius: CGFloat, particleSize: CGFloat, motionPhase: Double) {
        self.index = index
        self.totalParticles = totalParticles
        self.sphereRadius = sphereRadius
        self.particleSize = particleSize
        self.motionPhase = motionPhase
        
        // Initialize random offsets once
        self._randomPhiOffset = State(initialValue: Double.random(in: -0.05...0.05))
        self._randomThetaOffset = State(initialValue: Double.random(in: -0.05...0.05))
    }
    
    // Generate proper 3D sphere surface points with motion
    private var position: (x: CGFloat, y: CGFloat, z: CGFloat) {
        // Use golden ratio for better distribution
        let goldenRatio = 1.618033988749895
        
        // Generate spherical coordinates with motion phase
        let phi = acos(1 - 2.0 * Double(index) / Double(totalParticles))
        let theta = 2.0 * .pi * Double(index) * goldenRatio + motionPhase
        
        // Add minimal randomness to break up patterns but keep clean edges
        let randomPhi = phi + randomPhiOffset
        let randomTheta = theta + randomThetaOffset
        
        // Position on sphere surface
        let x = sphereRadius * CGFloat(sin(randomPhi) * cos(randomTheta))
        let y = sphereRadius * CGFloat(sin(randomPhi) * sin(randomTheta))
        let z = sphereRadius * CGFloat(cos(randomPhi))
        
        return (x: x, y: y, z: z)
    }
    
    // Simplified activation effect - no wave motion
    private var waveOffset: CGFloat {
        return 0.0
    }
    
    // Apply edge density bias to 3D points
    private var shouldShowParticle: Bool {
        let distanceFromViewCenter = sqrt(position.x * position.x + position.y * position.y)
        let edgeBias = distanceFromViewCenter / sphereRadius
        
        // Modified edge bias: allow more center particles while maintaining edge density
        // Add a base probability so center particles (distance ≈ 0) can still appear
        let baseProbability = 0.3 // 30% chance for center particles
        let edgeProbability = pow(edgeBias, 1.2) // Slightly reduced edge bias
        let probability = baseProbability + edgeProbability * 0.7 // Combine base + edge
        
        // Use a deterministic random based on index to avoid flickering
        let seed = Double(index) + motionPhase
        let randomValue = sin(seed * 123.456) * 0.5 + 0.5 // Deterministic but varied
        
        return randomValue < probability
    }
    

    
    var body: some View {
        if shouldShowParticle {
            Circle()
                .fill(Color(red: 0.533, green: 0.533, blue: 0.533)) // Simple gray color
                .frame(width: particleSize, height: particleSize)
                .position(
                    x: 200 + position.x,
                    y: 200 + position.y + waveOffset
                )
                .opacity(0.8) // Simple opacity
                .allowsHitTesting(false)
        }
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
