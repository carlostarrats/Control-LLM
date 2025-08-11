import SwiftUI

enum VisualizerType: Int, CaseIterable {
    case liquid = 0
    case particle = 1
    case flowing = 2
    
    var displayName: String {
        switch self {
        case .liquid:
            return "Liquid"
        case .particle:
            return "Particle"
        case .flowing:
            return "Flowing"
        }
    }
    
    var icon: String {
        switch self {
        case .liquid:
            return "drop.fill"
        case .particle:
            return "sparkles"
        case .flowing:
            return "waveform.path.ecg"
        }
    }
}

struct VisualizerTabView: View {
    @Binding var isSpeaking: Bool
    @State private var selectedTab: VisualizerType = .liquid
    var hueShift: Double = 0.0
    var saturationLevel: Double = 1.0
    var brightnessLevel: Double = 1.0
    var onTap: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Visualizer content - full screen, no constraints
            ZStack {
                // Original liquid visualizer
                if selectedTab == .liquid {
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
                }
                
                // New particle visualizer
                if selectedTab == .particle {
                    ParticleVisualizerView(
                        isSpeaking: $isSpeaking,
                        onTap: onTap
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.8)),
                        removal: .opacity.combined(with: .scale(scale: 1.2))
                    ))
                }
                
                // New flowing liquid visualizer
                if selectedTab == .flowing {
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
            
            // Tab selector floating on top
            VStack {
                HStack(spacing: 0) {
                    ForEach(VisualizerType.allCases, id: \.self) { tab in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = tab
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 12, weight: .medium))
                                Text(tab.displayName)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(selectedTab == tab ? Color.white : Color(hex: "#666666"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(selectedTab == tab ? Color(hex: "#333333") : Color.clear)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(hex: "#1A1A1A"))
                .cornerRadius(8)
                
                Spacer()
            }
            .allowsHitTesting(true)
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
