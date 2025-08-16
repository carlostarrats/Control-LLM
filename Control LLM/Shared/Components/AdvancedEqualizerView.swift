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
    @State private var audioLevels: [Double] = Array(repeating: -60.0, count: 7)
    @State private var animationTimer: Timer?
    @State private var isTestMode: Bool = false
    
    // Frequency bands (Mel scale approximation) - reduced to 7 bands
    private let frequencies = [
        0, 351, 878, 1678, 2883, 5353, 9103
    ]
    

    
    var body: some View {
        VStack(spacing: 0) {
            // Main Equalizer
            VStack(spacing: 2) {
                // dB Scale Labels (top) - removed negative values and ellipsis
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { index in
                        Text(String(format: "%.0f", max(0, audioLevels[index] + 60)))
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: 30, alignment: .center)
                            .opacity(1.0)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 10) // 10px spacing below dB labels (40% reduction)
                
                // Equalizer Bars
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { index in
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
            }
            .padding(.vertical, 4)
            
            // Frequency labels - positioned directly under equalizer bars
            HStack(spacing: 6) {
                ForEach(0..<7, id: \.self) { index in
                    Group {
                        if index == 0 {
                            Text(NSLocalizedString("0 Hz", comment: ""))
                                .font(.custom("IBMPlexMono", size: 8))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                        } else if index == 2 {
                            Text(NSLocalizedString("1000 Hz", comment: ""))
                                .font(.custom("IBMPlexMono", size: 8))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                        } else if index == 4 {
                            Text(NSLocalizedString("5000 Hz", comment: ""))
                                .font(.custom("IBMPlexMono", size: 8))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                        } else if index == 6 {
                            Text(NSLocalizedString("20000 Hz", comment: ""))
                                .font(.custom("IBMPlexMono", size: 8))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                        } else {
                            Text("")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
            

            

            

        }
        .frame(maxWidth: .infinity)
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
        // -60 dB = 2px, 0 dB = 250px (increased from 180px to use even more vertical space)
        let normalizedLevel = max(0, (level + 60) / 60)
        return CGFloat(normalizedLevel * 248 + 2)
    }
    
    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in // Reduced from 0.033 to 0.016 for faster updates
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
        audioLevels = Array(repeating: -60.0, count: 7)
    }
    
    private func updateAudioLevels() {
        guard isSpeaking || isTestMode else {
                    // Reset to idle state
        for i in 0..<7 {
            audioLevels[i] = max(-60.0, audioLevels[i] - 2.0)
        }
            return
        }
        
        // Simulate realistic audio levels based on speech characteristics
        let time = Date().timeIntervalSince1970
        let baseIntensity = isTestMode ? 0.7 : 0.5
        
        for i in 0..<7 {
            let frequency = Double(frequencies[i])
            let speechResponse = calculateSpeechResponse(frequency: frequency, time: time, intensity: baseIntensity)
            let noise = Double.random(in: -0.5...0.5) // Reduced noise for smoother animation
            let newLevel = max(-60.0, min(0.0, speechResponse + noise))
            
            // Smooth transition to new level
            let smoothingFactor = 0.5 // Increased from 0.3 to 0.5 for more responsive animation
            audioLevels[i] = audioLevels[i] * (1.0 - smoothingFactor) + newLevel * smoothingFactor
        }
    }
    
    private func calculateSpeechResponse(frequency: Double, time: Double, intensity: Double) -> Double {
        // Simulate speech frequency response
        // Human speech: 85-255 Hz (vowels), 2000 Hz-8000 Hz (consonants)
        
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