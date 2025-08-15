import SwiftUI
import Combine

struct ParticleVisualizerView: View {
    @Binding var isSpeaking: Bool
    var onTap: (() -> Void)?
    
    // Particle system parameters
    private let particleCount = 2000
    private let baseSpherRadius: CGFloat = 150
    private let particleSize: CGFloat = 3.0
    
    // Remove local activation state - use global isSpeaking like liquid visualizer
    private var effectiveSpeakingState: Bool { isSpeaking }
    private var sphereRadius: CGFloat = 150 // Keep constant size
     
    // Activation plane parameters
    @State private var activationPlaneX: CGFloat = -300 // Start off-screen
    @State private var activationPlaneSpeed: CGFloat = 100 // pixels/sec
    @State private var lastUpdateTime: Date?
    
    // Liquid motion parameters
    @State private var motionPhase: [Double]
    @State private var motionTimer: Timer.TimerPublisher?
    @State private var motionCancellable: Cancellable?
    private let motionPeriod: TimeInterval = 2.0 // Back closer to original speed
    
    // OPTIMIZATION: Cache the wave time to avoid repeated Date() calls
    @State private var cachedWaveTime: Double = 0
    @State private var waveTimeUpdateTimer: Timer?
    
    // Smooth sine wave amplitude interpolation
    @State private var sineWaveAmplitude: Double = 0.0 // 0.0 = no movement, 1.0 = full movement
    
    init(isSpeaking: Binding<Bool>, onTap: (() -> Void)? = nil) {
        self._isSpeaking = isSpeaking
        self.onTap = onTap
        
        // Initialize motion phase with random offsets for each particle
        let initialPhases = (0..<2000).map { _ in Double.random(in: 0...(2 * .pi)) }
        self._motionPhase = .init(initialValue: initialPhases)
    }
    
    var body: some View {
        ZStack {
            TimelineView(.animation) { timeline in
                ZStack {
                    // Generate particles on sphere surface using spherical coordinates
                    ForEach(0..<particleCount, id: \.self) { index in
                        SphereParticle(
                            index: index,
                            totalParticles: particleCount,
                            sphereRadius: sphereRadius,
                            particleSize: particleSize,
                            motionPhase: motionPhase[index % motionPhase.count],
                            isActivated: effectiveSpeakingState,
                            activationPlaneX: activationPlaneX,
                            cachedWaveTime: cachedWaveTime, // Pass cached time
                            sineWaveAmplitude: sineWaveAmplitude // Pass amplitude for smooth transitions
                        )
                    }
                }
                .onChange(of: timeline.date) { _, newDate in
                    updateActivationPlane(currentTime: newDate)
                }
                .onChange(of: effectiveSpeakingState) { _, newState in
                    // Smoothly interpolate sine wave amplitude
                    withAnimation(.easeInOut(duration: 0.6)) {
                        sineWaveAmplitude = newState ? 1.0 : 0.0
                    }
                    
                    if !newState {
                        // When deactivating, smoothly reset the plane
                        withAnimation(.easeInOut(duration: 0.6)) {
                            activationPlaneX = -300
                        }
                        lastUpdateTime = nil
                    }
                }
            }
            
            // Transparent background layer to capture all taps - placed on top
            Rectangle()
                .fill(Color.clear)
                .frame(width: 400, height: 400)
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap?()
                }
            
            // Ripple effect overlay when activated
            DistortionRippleEffect(isActive: effectiveSpeakingState)
                .allowsHitTesting(false)
        }
        .frame(width: 400, height: 400) // FIXED: Same size as other visualizers for consistent tap area
        .coordinateSpace(name: "visualizer")
        .onAppear {
            // Ensure the plane is reset when the view first appears
            activationPlaneX = -300
            lastUpdateTime = nil
            startMotionTimer()
            startWaveTimer() // Always start wave timer
            
            // Initialize sine wave amplitude based on current state
            sineWaveAmplitude = effectiveSpeakingState ? 1.0 : 0.0
        }
        .onDisappear {
            stopMotionTimer()
            stopWaveTimer()
        }
        .animation(.easeInOut(duration: 0.6), value: effectiveSpeakingState)
    }
    
    // OPTIMIZATION: Update wave time at fixed intervals instead of every frame
    private func startWaveTimer() {
        stopWaveTimer()
        waveTimeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            cachedWaveTime = Date().timeIntervalSinceReferenceDate
        }
    }
    
    private func stopWaveTimer() {
        waveTimeUpdateTimer?.invalidate()
        waveTimeUpdateTimer = nil
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
    
    private func updateActivationPlane(currentTime: Date) {
        guard effectiveSpeakingState else {
            // Reset plane when not speaking
            activationPlaneX = -300
            return
        }
        
        let deltaTime = currentTime.timeIntervalSince(lastUpdateTime ?? Date())
        lastUpdateTime = currentTime
        
        // Move activation plane from left to right
        activationPlaneX += activationPlaneSpeed * CGFloat(deltaTime)
        
        // Reset plane when it starts leaving the sphere (before it completely exits)
        // This creates continuous waves with overlap
        if activationPlaneX > 100 { // Reset earlier for smooth continuous waves
            activationPlaneX = -300 // Start from further left for seamless transition
        }
    }
    
    private func updateMotion() {
        // No motion phase updates - particles stay in fixed positions
        // Only the sine wave vibration will provide movement
    }
}

struct SphereParticle: View {
    let index: Int
    let totalParticles: Int
    let sphereRadius: CGFloat
    let particleSize: CGFloat
    let motionPhase: Double
    let isActivated: Bool
    let activationPlaneX: CGFloat
    let cachedWaveTime: Double // OPTIMIZATION: Receive cached time instead of calling Date()
    let sineWaveAmplitude: Double // Smooth amplitude interpolation for transitions
    
    // Store random offsets as state to avoid recomputation
    @State private var randomPhiOffset: Double
    @State private var randomThetaOffset: Double
    @State private var depthVariance: Double
    
    init(index: Int, totalParticles: Int, sphereRadius: CGFloat, particleSize: CGFloat, motionPhase: Double, isActivated: Bool, activationPlaneX: CGFloat, cachedWaveTime: Double, sineWaveAmplitude: Double) {
        self.index = index
        self.totalParticles = totalParticles
        self.sphereRadius = sphereRadius
        self.particleSize = particleSize
        self.motionPhase = motionPhase
        self.isActivated = isActivated
        self.activationPlaneX = activationPlaneX
        self.cachedWaveTime = cachedWaveTime
        self.sineWaveAmplitude = sineWaveAmplitude
        
        // Initialize random offsets once
        self._randomPhiOffset = State(initialValue: Double.random(in: -0.05...0.05))
        self._randomThetaOffset = State(initialValue: Double.random(in: -0.05...0.05))
        self._depthVariance = State(initialValue: Double.random(in: -0.15...0.15))
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
        
        // Position on sphere surface with depth variance for texture
        let effectiveRadius = sphereRadius * (1.0 + CGFloat(depthVariance))
        let x = effectiveRadius * CGFloat(sin(randomPhi) * cos(randomTheta))
        let y = effectiveRadius * CGFloat(sin(randomPhi) * sin(randomTheta))
        let z = effectiveRadius * CGFloat(cos(randomPhi))
        
        return (x: x, y: y, z: z)
    }
    
    // OPTIMIZATION: Simplified activation calculation with cached time
    private var activationEffect: (waveOffset: CGFloat, isActivated: Bool) {
        // Always calculate sine wave motion with different intensities for each state
        let deactivatedAmplitude: CGFloat = 1.6   // Deactivated state amplitude
        let activatedAmplitude: CGFloat = 4.0     // Activated state amplitude
        
        // Use consistent base frequency to prevent position snapping
        let baseFrequency: Double = 10.0  // Keep frequency constant to prevent snapping
        
        // Interpolate only the amplitude, keep frequency consistent
        let currentAmplitude = deactivatedAmplitude + (activatedAmplitude - deactivatedAmplitude) * CGFloat(sineWaveAmplitude)
        
        // Each particle has its own independent wave phase based on its index
        // This creates chaotic, independent vibration instead of synchronized movement
        let wavePhase = cachedWaveTime * baseFrequency + Double(index) * 0.5
        let waveOffset = currentAmplitude * CGFloat(sin(wavePhase))
        
        return (waveOffset: waveOffset, isActivated: isActivated)
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
                .fill(activationEffect.isActivated ? Color(red: 0.8, green: 0.8, blue: 0.8) : particleColor)
                .frame(width: depthAdjustedSize, height: depthAdjustedSize)
                .position(
                    x: 200 + position.x,  // FIXED: Center in 400x400 frame (was 150 for 300x300)
                    y: 200 + position.y + activationEffect.waveOffset  // FIXED: Center in 400x400 frame (was 150 for 300x300)
                )
                .opacity(depthOpacity) // Opacity based on Z-depth for 3D effect
                .allowsHitTesting(false) // FIXED: Make particles non-interactive so background can capture taps
        }
    }
    
    // Color based on activation state
    private var particleColor: Color {
        if isActivated {
            return Color(red: 0.933, green: 0.933, blue: 0.933) // #eeeeee
        } else {
            return Color(red: 0.6, green: 0.6, blue: 0.6) // #999999
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
            .clipShape(Circle())
    }
}
