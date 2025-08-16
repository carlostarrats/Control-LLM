import SwiftUI

struct SwiftUIRippleEffect: View {
    let isActive: Bool
    @State private var rippleScale: CGFloat = 0.0
    @State private var rippleOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Main expanding ripple
            Circle()
                .stroke(Color.white, lineWidth: 3)
                .scaleEffect(rippleScale)
                .opacity(rippleOpacity)
                .animation(.easeOut(duration: 0.8), value: rippleScale)
                .animation(.easeOut(duration: 0.8), value: rippleOpacity)
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                // Trigger ripple animation
                rippleScale = 0.0
                rippleOpacity = 0.8
                
                withAnimation(.easeOut(duration: 0.8)) {
                    rippleScale = 2.0
                    rippleOpacity = 0.0
                }
            }
        }
    }
}

// Distortion-based ripple effect that affects the underlying animation
struct DistortionRippleEffect: View {
    let isActive: Bool
    @State private var rippleTime: Double = 0.0
    @State private var rippleScale: CGFloat = 0.0
    @State private var rippleOpacity: Double = 0.0
    @State private var distortionAmount: CGFloat = 0.0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            ZStack {
                // Main distortion wave - greyscale with reasonable transparent center
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.clear,                    // 0% - completely invisible center
                                Color.clear,                    // 15% - still invisible
                                Color.white.opacity(0.05),      // 25% - very subtle white
                                Color.white.opacity(0.15),      // 40% - light white
                                Color.white.opacity(0.25),      // 60% - medium white
                                Color.white.opacity(0.15),      // 80% - light white
                                Color.clear                     // 100% - transparent edge
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .scaleEffect(rippleScale)
                    .opacity(rippleOpacity * 0.75)  // Reduced to 75% opacity
                    .blendMode(.multiply)
                    .blur(radius: 3)
                
                // Secondary distortion layer - layered greyscale with transparent center (like main layer)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.clear,                    // 0% - completely invisible center
                                Color.clear,                    // 20% - still invisible
                                Color.white.opacity(0.25),      // 35% - subtle white
                                Color.white.opacity(0.15),      // 50% - light white
                                Color.white.opacity(0.08),      // 70% - very subtle white
                                Color.clear                     // 100% - transparent edge
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .scaleEffect(rippleScale * 0.65)  // Slightly smaller than main
                    .opacity(rippleOpacity * 0.25)    // Reduced to 25% for very subtle effect
                    .blendMode(.multiply)             // Using multiply for better contrast
                    .blur(radius: 2.0)               // Slightly more blur
                    .offset(
                        x: sin(rippleTime * 1.8) * distortionAmount * 6,  // Different timing
                        y: cos(rippleTime * 2.4) * distortionAmount * 6    // Different timing
                    )
            }
            .onChange(of: timeline.date) { _, newDate in
                rippleTime = newDate.timeIntervalSince1970
            }
        }
        .onChange(of: isActive) { _, _ in
            // Trigger ripple animation on EVERY state change (activate AND deactivate)
            rippleScale = 0.0
            rippleOpacity = 0.0
            distortionAmount = 0.0
            
            withAnimation(.timingCurve(0.3, 0.7, 0.7, 0.3, duration: 0.89)) { // 5% slower, less extreme variation
                rippleScale = 8.0 // Much larger to reach screen edges
                rippleOpacity = 1.0
                distortionAmount = 1.0
            }
            
            // Fade out with continued distortion - 5% slower timing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.54) { // 5% slower than current
                withAnimation(.easeOut(duration: 0.36)) { // 5% slower than current
                    rippleOpacity = 0.0
                    distortionAmount = 0.0
                }
            }
        }
    }
}
