import SwiftUI
import Liquid

struct CentralVisualizerView: View {
    @Binding var isSpeaking: Bool
    @State private var isAnimating = false
    @State private var animationPhase: Double = 0
    @State private var continuousAnimationTimer: Timer?
    var hueShift: Double = 0.0 // 0.0 = original, 1.0 = full spectrum rotation
    var saturationLevel: Double = 1.0 // 1.0 = full saturation, 0.0 = black and white
    var brightnessLevel: Double = 1.0 // 1.0 = full brightness, 0.0 = black

    // MARK: - Voice Integration
    @StateObject private var voiceIntegration = VoiceIntegrationService.shared
    
    // MARK: - Listening States
    @State private var isListening = false
    @State private var isProcessing = false
    

    
    // Helper function to apply hue shift, saturation, and brightness to a color
    private func applyHueShift(to color: Color) -> Color {
        // Early return for no transformation
        if hueShift == 0.0 && saturationLevel == 1.0 && brightnessLevel == 1.0 {
            return color
        }
        
        // Apply hue rotation, saturation, and brightness using HSB color space
        let uiColor = UIColor(color)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // Rotate hue by the shift amount (0.0 to 1.0 maps to 0° to 360°)
        let newHue = (hue + hueShift).truncatingRemainder(dividingBy: 1.0)
        
        // Apply saturation level (1.0 = full saturation, 0.0 = black and white)
        let newSaturation = saturation * saturationLevel
        
        // Apply brightness level (1.0 = full brightness, 0.0 = black)
        let newBrightness = brightness * brightnessLevel
        
        return Color(hue: newHue, saturation: newSaturation, brightness: newBrightness, opacity: alpha)
    }
    
    private func applyHueShift(to colors: [Color]) -> [Color] {
        // Early return for no transformation
        if hueShift == 0.0 && saturationLevel == 1.0 && brightnessLevel == 1.0 {
            return colors
        }
        
        return colors.map { applyHueShift(to: $0) }
    }

    var body: some View {
        ZStack {
            // Tap gesture for listening control
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    handleVisualizerTap()
                }
            
            // Deep background wave layer - creates depth with Liquid
            Liquid(samples:50, period: 3.0)
                .frame(width: 400, height: 400)
                .foregroundColor(applyHueShift(to: Color(hex: "#5D0C14")))
                .opacity(0.6)
                .blur(radius: 30)
                .offset(x: isAnimating ? sin(animationPhase * 0.5) * 8 : 0,
                        y: isAnimating ? cos(animationPhase * 0.5) * 6 : 0)
            
            // Mid-depth wave layer - adds dimension with Liquid
            Liquid(samples: 20)
                .frame(width: 360, height: 360)
                .foregroundColor(applyHueShift(to: Color(hex: "#D20001")))
                .opacity(0.3)
                .blur(radius: 20)
                .offset(x: isAnimating ? cos(animationPhase * 0.6) * 6 : 0,
                        y: isAnimating ? sin(animationPhase * 0.6) * 4 : 0)
            
            // Organic irregular ring 1 - Pink outer ring
            Ellipse()
                .fill(applyHueShift(to: Color(hex: "#FF00D0")))
                .frame(width: 280 + sin(animationPhase * 1.2) * 32,
                       height: 280 + cos(animationPhase * 1.8) * 24)
                .scaleEffect(1.0 + sin(animationPhase * 0.8) * 0.08)
                .offset(x: sin(animationPhase * 1.0) * 6,
                        y: cos(animationPhase * 1.0) * 5)
                .blur(radius: 12)
                .opacity(0.8)
            
            // Organic irregular ring 2 - Red inner ring with ripple distortion
            Ellipse()
                .fill(applyHueShift(to: Color(hex: "#D20001")))
                .frame(width: 240 + cos(animationPhase * 1.5) * 28,
                       height: 240 + sin(animationPhase * 2.1) * 20)
                .scaleEffect(1.0 + cos(animationPhase * 1.2) * 0.064)
                .offset(x: cos(animationPhase * 1.3) * 5,
                        y: sin(animationPhase * 1.3) * 3)
                .blur(radius: 10)
                .opacity(0.7)
            
            // Center organic motion - Dark ring with organic distortion
            Ellipse()
                .fill(applyHueShift(to: Color(hex: "#2D0000")))
                .frame(width: 80 + sin(animationPhase * 1.8) * 15,
                       height: 80 + cos(animationPhase * 2.2) * 12)
            
            // Ripple effect overlay when activated
            DistortionRippleEffect(isActive: isSpeaking)
                .allowsHitTesting(false)
                .scaleEffect(1.0 + sin(animationPhase * 2.5) * 0.3)
                .offset(x: sin(animationPhase * 2.0) * 8, y: cos(animationPhase * 2.0) * 6)
                .opacity(0.9)
                .blur(radius: 3)
            
            // Center organic motion - Gradient core with organic distortion
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: applyHueShift(to: [
                            Color(hex: "#FF00D0"),
                            Color(hex: "#8B0000"),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 50
                    )
                )
                .frame(width: 60 + cos(animationPhase * 2.1) * 10,
                       height: 60 + sin(animationPhase * 1.9) * 8)
                .scaleEffect(1.0 + sin(animationPhase * 2.5) * 0.4)
                .offset(x: cos(animationPhase * 2.3) * 5, y: sin(animationPhase * 2.3) * 4)
                .opacity(0.7)
                .blur(radius: 6)
            

            
            // Additional organic motion - Middle ring with distortion
            Ellipse()
                .fill(applyHueShift(to: Color(hex: "#FF00D0")))
                .frame(width: 160 + sin(animationPhase * 2.0) * 20,
                       height: 160 + cos(animationPhase * 1.6) * 16)
                .scaleEffect(1.0 + sin(animationPhase * 1.8) * 0.12)
                .offset(x: sin(animationPhase * 1.3) * 8, y: cos(animationPhase * 1.3) * 6)
                .blur(radius: 8)
                .opacity(0.6)
            
            // Asymmetrical outer energy field - multiple non-centered elements
            ZStack {
                // Primary energy field - distorted and offset
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: applyHueShift(to: [
                                Color(hex: "#FF00D0").opacity(0.9),
                                Color(hex: "#D20001").opacity(0.7),
                                Color(hex: "#8B0000").opacity(0.5),
                                Color.clear
                            ]),
                            center: UnitPoint(x: 0.4, y: 0.3), // Off-center
                            startRadius: 60,
                            endRadius: 180
                        )
                    )
                    .frame(width: 320, height: 280)
                    .blur(radius: 12)
                    .offset(x: isAnimating ? 8 + sin(animationPhase * 0.4) * 8 : 0,
                            y: isAnimating ? -4 + cos(animationPhase * 0.4) * 4 : 0)
                    .scaleEffect(isAnimating ? 1.0 + sin(animationPhase * 0.8) * 0.08 : 1.0, anchor: .center)
                
                // Secondary energy field - different shape and position
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: applyHueShift(to: [
                                Color(hex: "#FF00D0").opacity(0.8),
                                Color(hex: "#D20001").opacity(0.6),
                                Color(hex: "#8B0000").opacity(0.4),
                                Color.clear
                            ]),
                            center: UnitPoint(x: 0.6, y: 0.7), // Opposite corner
                            startRadius: 50,
                            endRadius: 160
                        )
                    )
                    .frame(width: 280, height: 320)
                    .blur(radius: 18)
                    .offset(x: isAnimating ? -4 + cos(animationPhase * 0.5) * 4 : 0,
                            y: isAnimating ? 4 + sin(animationPhase * 0.5) * 3 : 0)
                    .scaleEffect(isAnimating ? 1.0 + cos(animationPhase * 0.9) * 0.1 : 1.0, anchor: .center)
                
                // Tertiary energy field - smaller, more intense
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: applyHueShift(to: [
                                Color(hex: "#FF00D0").opacity(0.7),
                                Color(hex: "#D20001").opacity(0.5),
                                Color.clear
                            ]),
                            center: UnitPoint(x: 0.2, y: 0.8), // Bottom left
                            startRadius: 30,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 260)
                    .blur(radius: 22)
                    .offset(x: isAnimating ? 4 + sin(animationPhase * 0.6) * 4 : 0,
                            y: isAnimating ? 8 + cos(animationPhase * 0.6) * 3 : 0)
                    .scaleEffect(isAnimating ? 1.0 + sin(animationPhase * 1.0) * 0.12 : 1.0, anchor: .center)
            }
            .blendMode(.screen)
            
            // Additional depth wave - creates more dimension
            Circle()
                .fill(
                    RadialGradient(
                        colors: applyHueShift(to: [
                            Color(hex: "#FF00D0").opacity(0.2),
                            Color(hex: "#D20001").opacity(0.1),
                            Color.clear
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.6),
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .blur(radius: 15)
                .offset(x: isAnimating ? sin(animationPhase * 0.7) * 5 : 0,
                        y: isAnimating ? cos(animationPhase * 0.7) * 3 : 0)
                .scaleEffect(isAnimating ? 1.0 + sin(animationPhase * 0.6) * 0.0035 : 1.0, anchor: .center)
            
            // Irregular energy tendrils - non-circular shapes
            ZStack {
                // Energy tendril 1 - rotated oval
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: applyHueShift(to: [
                                Color(hex: "#FF00D0").opacity(0.6),
                                Color(hex: "#D20001").opacity(0.4),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 80)
                    .blur(radius: 8)
                    .offset(x: isAnimating ? -2 + sin(animationPhase * 0.8) * 2 : 0,
                            y: isAnimating ? -4 + cos(animationPhase * 0.8) * 2 : 0)
                    .scaleEffect(isAnimating ? 1.0 + sin(animationPhase * 1.2) * 0.15 : 1.0, anchor: .center)
                
                // Energy tendril 2 - different orientation
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: applyHueShift(to: [
                                Color(hex: "#FF00D0").opacity(0.5),
                                Color(hex: "#D20001").opacity(0.3),
                                Color.clear
                            ]),
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        )
                    )
                    .frame(width: 160, height: 100)
                    .blur(radius: 10)
                    .offset(x: isAnimating ? 12 + cos(animationPhase * 0.9) * 4 : 0,
                            y: isAnimating ? 10 + sin(animationPhase * 0.9) * 3 : 0)
                    .scaleEffect(isAnimating ? 1.0 + cos(animationPhase * 1.3) * 0.18 : 1.0, anchor: .center)
                
                // Energy tendril 3 - vertical orientation
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: applyHueShift(to: [
                                Color(hex: "#FF00D0").opacity(0.4),
                                Color(hex: "#D20001").opacity(0.2),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 60, height: 180)
                    .blur(radius: 12)
                    .offset(x: isAnimating ? -6 + sin(animationPhase * 1.0) * 3 : 0,
                            y: isAnimating ? 15 + cos(animationPhase * 1.0) * 2 : 0)
                    .scaleEffect(isAnimating ? 1.0 + sin(animationPhase * 1.4) * 0.2 : 1.0, anchor: .center)
            }
            .blendMode(.overlay)
            
            // Foreground depth wave - closest layer
            Circle()
                .fill(
                    RadialGradient(
                        colors: applyHueShift(to: [
                            Color(hex: "#FF00D0").opacity(0.15),
                            Color(hex: "#D20001").opacity(0.1),
                            Color.clear
                        ]),
                        center: UnitPoint(x: 0.7, y: 0.3),
                        startRadius: 0,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .blur(radius: 12)
                .offset(x: isAnimating ? cos(animationPhase * 0.8) * 3 : 0,
                        y: isAnimating ? sin(animationPhase * 0.8) * 2 : 0)
                .scaleEffect(isAnimating ? 1.0 + cos(animationPhase * 0.7) * 0.0045 : 1.0, anchor: .center)
            
            // Inner energy ring - distorted and irregular
            ZStack {
                // Primary ring with distortion
                Ellipse()
                    .stroke(
                        LinearGradient(
                            colors: applyHueShift(to: [
                                Color(hex: "#FF00D0"),
                                Color(hex: "#D20001"),
                                Color(hex: "#8B0000")
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 8
                    )
                    .frame(width: 220 + sin(animationPhase * 1.1) * 12, height: 200 + cos(animationPhase * 1.6) * 10)
                    .blur(radius: 4)
                    .offset(x: 5 + sin(animationPhase * 0.9) * 4,
                            y: -3 + cos(animationPhase * 0.9) * 2)
                    .rotationEffect(.degrees(sin(animationPhase * 0.4) * 4))
                
                // Secondary ring - different distortion
                Ellipse()
                    .stroke(applyHueShift(to: Color(hex: "#FF00D0").opacity(0.6)), lineWidth: 6)
                    .frame(width: 200 + cos(animationPhase * 1.3) * 11, height: 220 + sin(animationPhase * 1.9) * 8)
                    .blur(radius: 6)
                    .offset(x: -3 + cos(animationPhase * 1.1) * 3,
                            y: 4 + sin(animationPhase * 1.1) * 2)
                    .rotationEffect(.degrees(cos(animationPhase * 0.6) * -8))
                
                // Tertiary ring - more distortion
                Ellipse()
                    .stroke(applyHueShift(to: Color(hex: "#D20001").opacity(0.5)), lineWidth: 4)
                    .frame(width: 240 + sin(animationPhase * 1.5) * 14, height: 180 + cos(animationPhase * 2.1) * 6)
                    .blur(radius: 8)
                    .offset(x: 2 + sin(animationPhase * 1.2) * 2,
                            y: 6 + cos(animationPhase * 1.2) * 2)
                    .rotationEffect(.degrees(sin(animationPhase * 0.8) * 6))
            }
            
            // Core energy dot - irregular and pulsing
            ZStack {
                // Primary core with irregular shape
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: applyHueShift(to: [
                                Color(hex: "#5D0C14").opacity(0.9),
                                Color(hex: "#5D0C14").opacity(0.7),
                                Color(hex: "#5D0C14").opacity(0.3),
                                Color.clear
                            ]),
                            center: UnitPoint(x: 0.4, y: 0.3), // Off-center
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140 + sin(animationPhase * 1.2) * 16,
                           height: 120 + cos(animationPhase * 1.8) * 12)
                    .blur(radius: 25)
                    .offset(x: 3 + sin(animationPhase * 0.4) * 8,
                            y: -2 + cos(animationPhase * 0.6) * 6)
                    .scaleEffect(1.0 + sin(animationPhase * 0.5) * 0.12, anchor: .center)
                
                // Secondary core layer - different shape
                Ellipse()
                    .fill(applyHueShift(to: Color(hex: "#5D0C14").opacity(0.8)))
                    .frame(width: 120 + cos(animationPhase * 1.5) * 14, height: 140 + sin(animationPhase * 2.0) * 10)
                    .blur(radius: 35)
                    .offset(x: -2 + cos(animationPhase * 0.7) * 10,
                            y: 3 + sin(animationPhase * 0.6) * 8)
                    .scaleEffect(1.0 + cos(animationPhase * 0.6) * 0.096, anchor: .center)
                
                // Tertiary core layer - more irregular
                Ellipse()
                    .fill(applyHueShift(to: Color(hex: "#5D0C14").opacity(0.6)))
                    .frame(width: 130 + sin(animationPhase * 1.8) * 13, height: 110 + cos(animationPhase * 2.2) * 8)
                    .blur(radius: 45)
                    .offset(x: 1 + sin(animationPhase * 0.8) * 11,
                            y: 1 + cos(animationPhase * 0.7) * 10)
                    .scaleEffect(1.0 + sin(animationPhase * 0.7) * 0.08, anchor: .center)
            }
            .overlay(
                // Energy core texture - irregular pattern
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: applyHueShift(to: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.04),
                                Color.clear
                            ]),
                            center: UnitPoint(x: 0.3, y: 0.4), // Off-center
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 120)
                    .blendMode(.overlay)
                    .opacity(0.4)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(x: isAnimating ? sin(animationPhase * 0.6) * 2 : 0,
                y: isAnimating ? cos(animationPhase * 0.6) * 1 : 0)
        .scaleEffect(isAnimating ? 1.0 + sin(animationPhase * 0.4) * 0.004 : 1.0, anchor: .center)
        .contentShape(Rectangle()) // Make the entire frame tappable

        .shadow(color: isAnimating ? applyHueShift(to: Color(hex: "#FF00D0").opacity(0.6)) : Color.clear,
                radius: isAnimating ? 20 + sin(animationPhase * 0.3) * 10 : 0)
        .animation(
            isAnimating ?
                .easeInOut(duration: 0.8).repeatForever(autoreverses: true) :
                .easeOut(duration: 0.5),
            value: isAnimating
        )
        .animation(.easeInOut(duration: 0.4), value: animationPhase)
        .onAppear {
            // Start the speech animation cycle smoothly
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    animationPhase = 1.0
                }
            }
            
            // Start continuous animation timer
            startContinuousAnimation()
        }
        .onDisappear {
            stopContinuousAnimation()
        }
        .onChange(of: isSpeaking) { _, newValue in
            if newValue {
                startSpeechAnimation()
            } else {
                stopSpeechAnimation()
            }
        }
        .onChange(of: isListening) { _, newValue in
            if newValue {
                startListeningAnimation()
            } else {
                stopListeningAnimation()
            }
        }
        .onAppear {
            setupVoiceCallbacks()
            setupNotificationObservers()
        }
        .onDisappear {
            cleanupVoiceCallbacks()
            cleanupNotificationObservers()
        }

    }
    
    // Function to start speech animation
    func startSpeechAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isAnimating = true
        }
    }
    
    // Function to stop speech animation
    func stopSpeechAnimation() {
        withAnimation(.easeOut(duration: 0.4)) {
            isAnimating = false
        }
    }
    
    // Function to start listening animation (active state)
    func startListeningAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isAnimating = true
        }
    }
    
    // Function to stop listening animation (deactive state)
    func stopListeningAnimation() {
        withAnimation(.easeOut(duration: 0.4)) {
            isAnimating = false
        }
    }
    
    // Function to start continuous animation timer
    func startContinuousAnimation() {
        continuousAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            animationPhase += 0.04  // Reduced from 0.05 to 0.04 (20% slower)
        }
    }
    
    // Function to stop continuous animation timer
    func stopContinuousAnimation() {
        continuousAnimationTimer?.invalidate()
        continuousAnimationTimer = nil
    }
    
    // MARK: - Listening Control
    
    private func handleVisualizerTap() {
        if !isListening && !isProcessing && !isSpeaking {
            // Start listening
            startListening()
        } else if isListening && !isProcessing {
            // Stop listening and start processing
            stopListening()
        }
    }
    
    private func startListening() {
        print("🎤 CentralVisualizerView: Starting listening")
        isListening = true
        isProcessing = false
        
        // Start active animation
        startSpeechAnimation()
        
        // Light haptic feedback
        FeedbackService.shared.playHaptic(.light)
        
        // Start voice mode
        voiceIntegration.startVoiceMode()
    }
    
    private func stopListening() {
        print("🔇 CentralVisualizerView: Stopping listening")
        isListening = false
        isProcessing = true
        
        // Stop active animation
        stopSpeechAnimation()
        
        // Light haptic feedback + stop recording sound
        FeedbackService.shared.playHaptic(.light)
        FeedbackService.shared.playSound(.endRecord)
        
        // Stop voice mode
        voiceIntegration.stopVoiceMode()
        
        // Set up callback for when processing is complete
        voiceIntegration.onVoiceInputComplete = { transcribedText in
            DispatchQueue.main.async {
                self.handleVoiceInputComplete(transcribedText)
            }
        }
    }
    
    private func handleVoiceInputComplete(_ transcribedText: String) {
        print("📝 CentralVisualizerView: Voice input complete, starting LLM response")
        isProcessing = false
        
        // The LLM will now process and respond
        // We'll wait for the response to start speaking
    }
    
    private func handleVoiceResponseComplete() {
        print("🔊 CentralVisualizerView: Voice response complete")
        isSpeaking = false
        isListening = false
        isProcessing = false
        
        // Return to deactive state
        stopSpeechAnimation()
    }
    
    // MARK: - Setup and Cleanup
    
    private func setupVoiceCallbacks() {
        voiceIntegration.onVoiceInputComplete = { transcribedText in
            DispatchQueue.main.async {
                self.handleVoiceInputComplete(transcribedText)
            }
        }
        
        voiceIntegration.onVoiceResponseComplete = {
            DispatchQueue.main.async {
                self.handleVoiceResponseComplete()
            }
        }
    }
    
    private func cleanupVoiceCallbacks() {
        voiceIntegration.onVoiceInputComplete = nil
        voiceIntegration.onVoiceResponseComplete = nil
    }
    
    private func setupNotificationObservers() {
        // Listen for when LLM starts speaking
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("voiceResponseToken"),
            object: nil,
            queue: .main
        ) { _ in
            // LLM is responding, set speaking state
            self.isSpeaking = true
        }
        
        // Listen for when LLM finishes speaking
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("voiceResponseComplete"),
            object: nil,
            queue: .main
        ) { _ in
            // LLM response complete, return to deactive state
            self.handleVoiceResponseComplete()
        }
    }
    
    private func cleanupNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Visualizer Styles Preview")
            .foregroundColor(.white)
            .font(.title2)
            .padding()
        
        // Liquid Blob
        VStack {
            Text("Liquid Blob")
                .foregroundColor(.white)
                .font(.headline)
            CentralVisualizerView(isSpeaking: .constant(false))
                .frame(width: 200, height: 200)
                .background(Color.black)
                .clipShape(Circle())
        }
    }
    .background(Color.black)
}

#Preview("Animation Cycle Demo") {
    AnimationCycleDemo()
}

struct AnimationCycleDemo: View {
    @State private var isSpeaking = false
    
    var body: some View {
        VStack {
            Text("Animation Cycle Demo")
                .foregroundColor(.white)
                .font(.title2)
                .padding()
            
            CentralVisualizerView(isSpeaking: $isSpeaking)
                .frame(width: 250, height: 250)
                .background(Color.black)
                .clipShape(Circle())
            
            Text(isSpeaking ? "Speaking..." : "Idle")
                .foregroundColor(.white)
                .padding()
            
            Button("Toggle Animation") {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isSpeaking.toggle()
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
        }
        .background(Color.black)
        .onAppear {
            // Auto-cycle the animation every 4 seconds
            Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    isSpeaking.toggle()
                }
            }
        }
    }
}
