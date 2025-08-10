import SwiftUI
import Combine

struct ParticleVisualizerView: View {
    @Binding var isSpeaking: Bool
    var onTap: (() -> Void)?
    
    // Particle system parameters
    private let particleCount = 2000
    private let sphereRadius: CGFloat = 150
    private let particleSize: CGFloat = 3.0
    
    // Liquid motion parameters
    @State private var motionPhase: [Double]
    @State private var motionTimer: Timer.TimerPublisher?
    @State private var motionCancellable: Cancellable?
    private let motionPeriod: TimeInterval = 8.0 // Restore original timing for smooth, biological motion
    
    init(isSpeaking: Binding<Bool>, onTap: (() -> Void)? = nil) {
        self._isSpeaking = isSpeaking
        self.onTap = onTap
        
        // Initialize motion phase with random offsets for each particle
        let initialPhases = (0..<2000).map { _ in Double.random(in: 0...(2 * .pi)) }
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
        .frame(width: 300, height: 300)
        .onTapGesture {
            onTap?()
        }
        .onAppear {
            startMotionTimer()
        }
        .onDisappear {
            stopMotionTimer()
        }
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
        // Use golden ratio for better distribution (this was working)
        let goldenRatio = 1.618033988749895
        
        // Generate spherical coordinates with motion phase
        let phi = acos(1 - 2.0 * Double(index) / Double(totalParticles))
        let theta = 2.0 * .pi * Double(index) * goldenRatio + motionPhase
        
        // Add minimal randomness to break up patterns but keep clean edges
        let randomPhi = phi + randomPhiOffset
        let randomTheta = theta + randomThetaOffset
        
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
        
        // Use a deterministic random based on index to avoid flickering
        let seed = Double(index) + motionPhase
        let randomValue = sin(seed * 123.456) * 0.5 + 0.5 // Deterministic but varied
        
        return randomValue < probability
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