//
//  Unused_HSBColorSliders.swift
//  Control LLM
//
//  Created as an unused component for future reference
//  This contains the HSB (Hue, Saturation, Brightness) color control sliders
//

import SwiftUI

struct HSBColorSliders: View {
    @Binding var hueShift: Double
    @Binding var saturationLevel: Double
    @Binding var brightnessLevel: Double
    var textOpacity: Double = 1.0
    
    var body: some View {
        VStack(spacing: 12) {
            // Hue Slider
            VStack(spacing: 4) {
                HStack {
                    Text("Hue")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#B3B3B3"))
                        .opacity(textOpacity)
                    
                    Spacer()
                    
                    Text(String(format: "%.2f", hueShift))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#B3B3B3"))
                        .opacity(textOpacity)
                }
                
                Slider(value: $hueShift, in: 0...1) { editing in
                    // Optional: Add haptic feedback when editing
                }
                .frame(width: 100)
                .opacity(textOpacity)
            }
            
            // Saturation Slider
            VStack(spacing: 4) {
                HStack {
                    Text("Sat")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#B3B3B3"))
                        .opacity(textOpacity)
                    
                    Spacer()
                    
                    Text(String(format: "%.2f", saturationLevel))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#B3B3B3"))
                        .opacity(textOpacity)
                }
                
                Slider(value: $saturationLevel, in: 0...1) { editing in
                    // Optional: Add haptic feedback when editing
                }
                .frame(width: 100)
                .opacity(textOpacity)
            }
            
            // Brightness Slider
            VStack(spacing: 4) {
                HStack {
                    Text("Bright")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#B3B3B3"))
                        .opacity(textOpacity)
                    
                    Spacer()
                    
                    Text(String(format: "%.2f", brightnessLevel))
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#B3B3B3"))
                        .opacity(textOpacity)
                }
                
                Slider(value: $brightnessLevel, in: 0...1) { editing in
                    // Optional: Add haptic feedback when editing
                }
                .frame(width: 100)
                .opacity(textOpacity)
            }
        }
    }
}

struct HSBColorSliders_Previews: PreviewProvider {
    static var previews: some View {
        HSBColorSliders(
            hueShift: .constant(0.0),
            saturationLevel: .constant(1.0),
            brightnessLevel: .constant(1.0)
        )
        .padding()
        .background(Color.black)
    }
} 