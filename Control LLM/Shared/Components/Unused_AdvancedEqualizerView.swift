//
//  Unused_AdvancedEqualizerView.swift
//  Control LLM
//
//  UNUSED COMPONENT - Available for future use
//  This equalizer was removed from the main screen but kept for reference.
//  Features: 8-band equalizer with realistic speech simulation, test mode, smooth animations
//  Usage: Import and use AdvancedEqualizerView(isSpeaking: $isSpeaking) in any view
//

import SwiftUI
import AVFoundation

struct AdvancedEqualizerView: View {
    @Binding var isSpeaking: Bool
    @State private var audioLevels: [Double] = Array(repeating: -60.0, count: 8)
    @State private var animationTimer: Timer?
    @State private var isTestMode: Bool = false
    
    // Frequency bands (Mel scale approximation) - expanded to 8 bands
    private let frequencies = [
        0, 351, 878, 1678, 2883, 5353, 9103, 16078
    ]
    
    // Mel scale frequency labels for bottom axis
    private let melLabels = ["0Hz", "1kHz", "5kHz", "20kHz"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Test Mode Button
            HStack {
                Spacer()
                Button(action: {
                    isTestMode.toggle()
                    if isTestMode {
                        startTestAnimation()
                    } else {
                        stopTestAnimation()
                    }
                }) {
                    Text(isTestMode ? "Stop Test" : "Test Equalizer")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#00FFFF"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isTestMode ? Color(hex: "#00FFFF").opacity(0.2) : Color.clear)
                        .border(Color(hex: "#00FFFF"), width: 1)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            
            // Main Equalizer
            VStack(spacing: 2) {
                // dB Scale Labels (top) - removed negative values and ellipsis
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { index in
                        Text(String(format: "%.0f", max(0, audioLevels[index] + 60)))
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .opacity(1.0)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 10) // 10px spacing below dB labels (40% reduction)
                
                // Equalizer Bars
                HStack(spacing: 8) {
                    ForEach(0..<8, id: \.self) { index in
                        VStack(spacing: 4) { // Added spacing between text and line
                            // Text in bracket at the top - responsive to audio levels
                            Text("[\(String(format: "%.0f", audioLevels[index]))]")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(height: 4) // Minimal height for ultra-tight spacing
                                .animation(.easeInOut(duration: 0.3), value: audioLevels[index])
                            
                            // Simple vertical line
                            Rectangle()
                                .fill(.white)
                                .frame(width: 2, height: max(2, getBarHeight(for: audioLevels[index])))
                                .animation(.easeInOut(duration: 0.3), value: audioLevels[index])
                        }
                    }
                }
                .frame(height: 120)
                
                // Mel Scale Frequency Axis
                HStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { index in
                        Text(melLabels[index])
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 10) // 10px spacing above frequency labels (40% reduction)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .frame(width: 320)
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    // MARK: - Helper Functions
    
    private func getBarHeight(for level: Double) -> CGFloat {
        // Convert dB level to bar height
        // -60 dB = 2px, 0 dB = 96px (reduced by 40% for ultra-compact bars)
        let normalizedLevel = max(0, (level + 60) / 60)
        return CGFloat(normalizedLevel * 94 + 2)
    }
    
    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { _ in
            updateAudioLevels()
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func startTestAnimation() {
        // Start test mode with realistic speech simulation
        isTestMode = true
    }
    
    private func stopTestAnimation() {
        // Stop test mode
        isTestMode = false
        audioLevels = Array(repeating: -60.0, count: 8)
    }
    
    private func updateAudioLevels() {
        guard isSpeaking || isTestMode else {
            // Reset to idle state
            for i in 0..<8 {
                audioLevels[i] = max(-60.0, audioLevels[i] - 2.0)
            }
            return
        }
        
        // Simulate realistic audio levels based on speech characteristics
        let time = Date().timeIntervalSince1970
        let baseIntensity = isTestMode ? 0.7 : 0.5
        
        for i in 0..<8 {
            let frequency = Double(frequencies[i])
            let speechResponse = calculateSpeechResponse(frequency: frequency, time: time, intensity: baseIntensity)
            let noise = Double.random(in: -0.5...0.5) // Reduced noise for smoother animation
            let newLevel = max(-60.0, min(0.0, speechResponse + noise))
            
            // Smooth transition to new level
            let smoothingFactor = 0.3
            audioLevels[i] = audioLevels[i] * (1.0 - smoothingFactor) + newLevel * smoothingFactor
        }
    }
    
    private func calculateSpeechResponse(frequency: Double, time: Double, intensity: Double) -> Double {
        // Simulate speech frequency response
        // Human speech: 85-255 Hz (vowels), 2kHz-8kHz (consonants)
        
        let speechPeaks = [150.0, 300.0, 600.0, 1200.0, 2400.0, 4800.0]
        var response = -60.0
        
        for peak in speechPeaks {
            let distance = abs(frequency - peak)
            let peakResponse = intensity * 40.0 * exp(-distance / (peak * 0.3))
            response = max(response, -60.0 + peakResponse)
        }
        
        // Add some variation based on time
        let variation = sin(time * 2.0 + frequency * 0.001) * 5.0
        response += variation
        
        return response
    }
}

#Preview {
    VStack {
        Text("Advanced Equalizer Preview")
            .foregroundColor(.white)
            .padding()
        
        AdvancedEqualizerView(isSpeaking: .constant(true))
            .background(Color.black)
    }
    .background(Color.black)
} 