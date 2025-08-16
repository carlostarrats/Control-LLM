import SwiftUI

struct VisualizerTabView: View {
    @Binding var isSpeaking: Bool
    var hueShift: Double = 0.0
    var saturationLevel: Double = 1.0
    var brightnessLevel: Double = 1.0
    var onTap: (() -> Void)?
    
    // Use the shared VisualizerStateManager instead of local state
    @StateObject private var visualizerState = VisualizerStateManager.shared
    
    var body: some View {
        ZStack {
            // FIX: Use a single switch statement instead of multiple if statements
            // This prevents the render loop caused by multiple conditional evaluations
            switch visualizerState.selectedVisualizerType {
            case .mycroft:
                CentralVisualizerView(
                    isSpeaking: $isSpeaking,
                    hueShift: hueShift,
                    saturationLevel: saturationLevel,
                    brightnessLevel: brightnessLevel,
                    onTap: onTap
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                    removal: .opacity.combined(with: .scale(scale: 1.2))
                ))
                
            case .wopr:
                ParticleVisualizerView(
                    isSpeaking: $isSpeaking,
                    onTap: onTap
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                    removal: .opacity.combined(with: .scale(scale: 1.2))
                ))
                
            case .tars:
                FlowingLiquidView(
                    isSpeaking: $isSpeaking,
                    onTap: onTap
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                    removal: .opacity.combined(with: .scale(scale: 1.2))
                ))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Visualizer Tab View Preview")
            .foregroundColor(.white)
            .font(.title2)
            .padding()
        
        VisualizerTabView(isSpeaking: .constant(false))
            .frame(width: 300, height: 320)
    }
    .background(Color.black)
}
