import SwiftUI
import Liquid

struct CentralVisualizerView: View {
    @Binding var isSpeaking: Bool
    @State private var isAnimating = false
    @State private var animationPhase: Double = 0

    
    var body: some View {
        ZStack {
            // Deep background wave layer - creates depth with Liquid
            Liquid()
                .frame(width: 400, height: 400)
                .foregroundColor(Color(hex: "#5D0C14"))
                .opacity(0.4)
                .blur(radius: 30)
                .offset(x: isAnimating ? sin(animationPhase * 0.5) * 8 : 0, 
                        y: isAnimating ? cos(animationPhase * 0.5) * 6 : 0)
            
            // Mid-depth wave layer - adds dimension with Liquid
            Liquid(samples: 5)
                .frame(width: 360, height: 360)
                .foregroundColor(Color(hex: "#D20001"))
                .opacity(0.3)
                .blur(radius: 20)
                .offset(x: isAnimating ? cos(animationPhase * 0.6) * 6 : 0, 
                        y: isAnimating ? sin(animationPhase * 0.6) * 4 : 0)
            
            // Asymmetrical outer energy field - multiple non-centered elements
                    ZStack {
                        // Primary energy field - distorted and offset
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "#FF00D0").opacity(0.9),
                                        Color(hex: "#D20001").opacity(0.7),
                                        Color(hex: "#8B0000").opacity(0.5),
                                        Color.clear
                                    ],
                                    center: UnitPoint(x: 0.4, y: 0.3), // Off-center
                                    startRadius: 60,
                                    endRadius: 180
                                )
                            )
                            .frame(width: 320, height: 280)
                            .blur(radius: 12)
                            .offset(x: isAnimating ? 15 + sin(animationPhase * 0.4) * 12 : 15, 
                                    y: isAnimating ? -8 + cos(animationPhase * 0.4) * 8 : -8)
                            .scaleEffect(isAnimating ? 1.0 + sin(animationPhase * 0.8) * 0.08 : 1.0, anchor: .center)
                
                                        // Secondary energy field - different shape and position
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "#FF00D0").opacity(0.8),
                                        Color(hex: "#D20001").opacity(0.6),
                                        Color(hex: "#8B0000").opacity(0.4),
                                        Color.clear
                                    ],
                                    center: UnitPoint(x: 0.6, y: 0.7), // Opposite corner
                                    startRadius: 50,
                                    endRadius: 160
                                )
                            )
                            .frame(width: 280, height: 320)
                            .blur(radius: 18)
                            .offset(x: isAnimating ? -12 + cos(animationPhase * 0.5) * 10 : -12, 
                                    y: isAnimating ? 10 + sin(animationPhase * 0.5) * 6 : 10)
                            .scaleEffect(isAnimating ? 1.0 + cos(animationPhase * 0.9) * 0.1 : 1.0, anchor: .center)
                
                                        // Tertiary energy field - smaller, more intense
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "#FF00D0").opacity(0.7),
                                        Color(hex: "#D20001").opacity(0.5),
                                        Color.clear
                                    ],
                                    center: UnitPoint(x: 0.2, y: 0.8), // Bottom left
                                    startRadius: 30,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 240, height: 260)
                            .blur(radius: 22)
                            .offset(x: isAnimating ? 8 + sin(animationPhase * 0.6) * 8 : 8, 
                                    y: isAnimating ? 15 + cos(animationPhase * 0.6) * 5 : 15)
                            .scaleEffect(isAnimating ? 1.0 + sin(animationPhase * 1.0) * 0.12 : 1.0, anchor: .center)
            }
            .blendMode(.screen)
            
            // Additional depth wave - creates more dimension
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#FF00D0").opacity(0.2),
                            Color(hex: "#D20001").opacity(0.1),
                            Color.clear
                        ],
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
                                    colors: [
                                        Color(hex: "#FF00D0").opacity(0.6),
                                        Color(hex: "#D20001").opacity(0.4),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 200, height: 80)
                            .blur(radius: 8)
                            .offset(x: isAnimating ? -20 + sin(animationPhase * 0.8) * 8 : -20, 
                                    y: isAnimating ? -30 + cos(animationPhase * 0.8) * 5 : -30)
                            .scaleEffect(isAnimating ? 1.0 + sin(animationPhase * 1.2) * 0.15 : 1.0, anchor: .center)
                
                                        // Energy tendril 2 - different orientation
                        Ellipse()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FF00D0").opacity(0.5),
                                        Color(hex: "#D20001").opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .topTrailing,
                                    endPoint: .bottomLeading
                                )
                            )
                            .frame(width: 160, height: 100)
                            .blur(radius: 10)
                            .offset(x: isAnimating ? 25 + cos(animationPhase * 0.9) * 6 : 25, 
                                    y: isAnimating ? 20 + sin(animationPhase * 0.9) * 4 : 20)
                            .scaleEffect(isAnimating ? 1.0 + cos(animationPhase * 1.3) * 0.18 : 1.0, anchor: .center)
                
                                        // Energy tendril 3 - vertical orientation
                        Ellipse()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FF00D0").opacity(0.4),
                                        Color(hex: "#D20001").opacity(0.2),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 60, height: 180)
                            .blur(radius: 12)
                            .offset(x: isAnimating ? -15 + sin(animationPhase * 1.0) * 4 : -15, 
                                    y: isAnimating ? 40 + cos(animationPhase * 1.0) * 3 : 40)
                            .scaleEffect(isAnimating ? 1.0 + sin(animationPhase * 1.4) * 0.2 : 1.0, anchor: .center)
            }
            .blendMode(.overlay)
            
            // Foreground depth wave - closest layer
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "#FF00D0").opacity(0.15),
                            Color(hex: "#D20001").opacity(0.1),
                            Color.clear
                        ],
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
                                    colors: [
                                        Color(hex: "#FF00D0"),
                                        Color(hex: "#D20001"),
                                        Color(hex: "#8B0000")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 8
                            )
                            .frame(width: 220, height: 200)
                            .blur(radius: 4)
                            .offset(x: isAnimating ? 5 + sin(animationPhase * 0.9) * 5 : 5, 
                                    y: isAnimating ? -3 + cos(animationPhase * 0.9) * 3 : -3)
                            .rotationEffect(.degrees(isAnimating ? sin(animationPhase * 0.4) * 5 : 0))
                
                                        // Secondary ring - different distortion
                        Ellipse()
                            .stroke(Color(hex: "#FF00D0").opacity(0.6), lineWidth: 6)
                            .frame(width: 200, height: 220)
                            .blur(radius: 6)
                            .offset(x: isAnimating ? -3 + cos(animationPhase * 1.1) * 4 : -3, 
                                    y: isAnimating ? 4 + sin(animationPhase * 1.1) * 3 : 4)
                            .rotationEffect(.degrees(isAnimating ? cos(animationPhase * 0.6) * -10 : 0))
                
                                        // Tertiary ring - more distortion
                        Ellipse()
                            .stroke(Color(hex: "#D20001").opacity(0.5), lineWidth: 4)
                            .frame(width: 240, height: 180)
                            .blur(radius: 8)
                            .offset(x: isAnimating ? 2 + sin(animationPhase * 1.2) * 3 : 2, 
                                    y: isAnimating ? 6 + cos(animationPhase * 1.2) * 2 : 6)
                            .rotationEffect(.degrees(isAnimating ? sin(animationPhase * 0.8) * 8 : 0))
            }
            
                                // Core energy dot - irregular and pulsing
                    ZStack {
                        // Primary core with irregular shape
                        Ellipse()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "#5D0C14").opacity(0.9),
                                        Color(hex: "#5D0C14").opacity(0.7),
                                        Color(hex: "#5D0C14").opacity(0.3),
                                        Color.clear
                                    ],
                                    center: UnitPoint(x: 0.4, y: 0.3), // Off-center
                                    startRadius: 0,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 140, height: 120)
                            .blur(radius: 25)
                            .offset(x: isAnimating ? 3 + sin(animationPhase * 0.4) * 10 : 3, 
                                    y: isAnimating ? -2 + cos(animationPhase * 0.6) * 8 : -2)
                            .scaleEffect(isAnimating ? 1.0 + sin(animationPhase * 0.5) * 0.008 : 1.0, anchor: .center)
                
                                        // Secondary core layer - different shape
                        Ellipse()
                            .fill(Color(hex: "#5D0C14").opacity(0.8))
                            .frame(width: 120, height: 140)
                            .blur(radius: 35)
                            .offset(x: isAnimating ? -2 + cos(animationPhase * 0.7) * 12 : -2, 
                                    y: isAnimating ? 3 + sin(animationPhase * 0.6) * 10 : 3)
                            .scaleEffect(isAnimating ? 1.0 + cos(animationPhase * 0.6) * 0.01 : 1.0, anchor: .center)
                
                                        // Tertiary core layer - more irregular
                        Ellipse()
                            .fill(Color(hex: "#5D0C14").opacity(0.6))
                            .frame(width: 130, height: 110)
                            .blur(radius: 45)
                            .offset(x: isAnimating ? 1 + sin(animationPhase * 0.8) * 14 : 1, 
                                    y: isAnimating ? 1 + cos(animationPhase * 0.7) * 12 : 1)
                            .scaleEffect(isAnimating ? 1.0 + sin(animationPhase * 0.7) * 0.012 : 1.0, anchor: .center)
            }
            .overlay(
                // Energy core texture - irregular pattern
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.04),
                                Color.clear
                            ],
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
        .scaleEffect(isAnimating ? 1.0 + sin(animationPhase * 0.4) * 0.008 : 1.0, anchor: .center)

        .shadow(color: isAnimating ? Color(hex: "#FF00D0").opacity(0.6) : Color.clear, 
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
        }
        .onChange(of: isSpeaking) { newValue in
            if newValue {
                startSpeechAnimation()
            } else {
                stopSpeechAnimation()
            }
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
}

#Preview {
    VStack {
        Text("Central Visualizer Preview")
            .foregroundColor(.white)
            .padding()
        
        CentralVisualizerView(isSpeaking: .constant(false))
            .frame(width: 300, height: 300)
            .background(Color.black)
            .clipShape(Circle())
        
        Text("Animation Demo")
            .foregroundColor(.white)
            .padding()
        
        CentralVisualizerView(isSpeaking: .constant(true))
            .frame(width: 200, height: 200)
            .background(Color.black)
            .clipShape(Circle())
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

