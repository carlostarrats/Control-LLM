import SwiftUI

struct VisualizerTabView: View {
    // Voice functionality removed
    var hueShift: Double = 0.0
    var saturationLevel: Double = 1.0
    var brightnessLevel: Double = 1.0

    
    // Use the shared VisualizerStateManager instead of local state
    @StateObject private var visualizerState = VisualizerStateManager.shared
    
    // Add clipboard processing functionality
    @State private var showingClipboardAlert = false
    @State private var clipboardAlertMessage = ""
    
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
                .onTapGesture {
                    handleVisualizerTap()
                }
                
            case .particle:
                        ParticleVisualizerView()
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                    removal: .opacity.combined(with: .scale(scale: 1.2))
                ))
                .onTapGesture {
                    handleVisualizerTap()
                }
                
            case .flowing:
                        FlowingLiquidView()
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                    removal: .opacity.combined(with: .scale(scale: 1.2))
                ))
                .onTapGesture {
                    handleVisualizerTap()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Clipboard Processing", isPresented: $showingClipboardAlert) {
            Button("OK") { }
        } message: {
            Text(clipboardAlertMessage)
        }
    }
    
    // MARK: - Clipboard Processing
    
    private func handleVisualizerTap() {
        // Check clipboard content
        guard let clipboardString = UIPasteboard.general.string else {
            // Clipboard is empty or doesn't contain text
            return
        }
        
        let trimmedText = clipboardString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            // Clipboard contains only whitespace
            return
        }
        
        // PHASE 3: Use centralized constants for consistent limits
        // Rough estimate: 1 token ≈ 4 characters
        let estimatedTokens = trimmedText.count / 4
        if estimatedTokens > Constants.safeTokenLimit {
            clipboardAlertMessage = "Clipboard content is too long. Please copy a shorter text (under \(Constants.safeTokenLimit) tokens)."
            showingClipboardAlert = true
            return
        }
        
        // Process clipboard text
        processClipboardText(trimmedText)
    }
    
    private func processClipboardText(_ text: String) {
        // Post notification to trigger navigation and message processing
        NotificationCenter.default.post(
            name: .processClipboardText,
            object: text
        )
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
