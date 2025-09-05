import SwiftUI

struct VisualizerTabView: View {
    // Voice functionality removed
    var hueShift: Double = 0.0
    var saturationLevel: Double = 1.0
    var brightnessLevel: Double = 1.0

    
    // Use the shared VisualizerStateManager instead of local state
    @StateObject private var visualizerState = VisualizerStateManager.shared
    
    var body: some View {
        ZStack {
            // FIX: Use a single switch statement instead of multiple if statements
            // This prevents the render loop caused by multiple conditional evaluations
            switch visualizerState.selectedVisualizerType {
            case .liquid:
                        CentralVisualizerView(
            hueShift: hueShift,
            saturationLevel: saturationLevel,
            brightnessLevel: brightnessLevel
        )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                    removal: .opacity.combined(with: .scale(scale: 1.2))
                ))
                
            case .particle:
                        ParticleVisualizerView()
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                    removal: .opacity.combined(with: .scale(scale: 1.2))
                ))
                
            case .flowing:
                        FlowingLiquidView()
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
                        Text(NSLocalizedString("Visualizer Styles Preview", comment: ""))
            .foregroundColor(.white)
            .font(.title2)
            .padding()
        
        // Liquid Blob
        VStack {
                            Text(NSLocalizedString("Liquid Blob", comment: ""))
                .foregroundColor(.white)
                .font(.headline)
            VisualizerTabView()
                .frame(width: 200, height: 200)
                .background(Color.black)
                .clipShape(Circle())
        }
    }
    .background(Color.black)
}
