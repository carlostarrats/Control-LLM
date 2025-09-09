//
//  FirstRunSetupView.swift
//  Control LLM
//
//  Created by Carlos Tarrats on 9/8/25.
//

import SwiftUI

/// Exact copy of the designed first run setup screen - each slice stacked vertically
struct FirstRunSetupView: View {
    @StateObject private var setupManager = FirstRunSetupManager()
    @State private var showMainApp = false
    @State private var availableStorage: String = "Calculating..."
    @State private var isReadyBlinking = true
    @State private var blinkTimer: Timer?
    
    var body: some View {
        ZStack {
            // Red background (your signature color)
            ColorManager.shared.redColor
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Slice 1: Top section - CONTROL V1.0 left, 80GB AVAILABLE right
                HStack {
                    Text("CONTROL V1.0")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                    
                    Spacer()
                    
                    Text("\(availableStorage) AVAILABLE")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Slice 2: PROCESSING...
                Text("PROCESSING...")
                    .font(.custom("IBMPlexMono-Bold", size: 12))
                    .foregroundColor(Color(hex: "141414"))
                    .opacity(isReadyBlinking ? 1.0 : 0.3)
                    .animation(.easeInOut(duration: 0.8), value: isReadyBlinking)
                    .onAppear {
                        startBlinking()
                    }
                    .onDisappear {
                        stopBlinking()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                Spacer().frame(height: 20)
                
                // Slice 3: 01 > MODEL with >>>>>>
                HStack {
                    Text("01 > MODEL")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                    
                    Spacer()
                    
                    Text(">>>>>>")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Slice 4: 02 > STATUS, 03 > LATENCY, 04 > TEMP
                VStack(alignment: .leading, spacing: 4) {
                    Text("02 > STATUS")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                    
                    Text("03 > LATENCY")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                    
                    Text("04 > TEMP")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Slice 5: 05 > MEMORY <...> ORGANIZING FILE >>>>>
                HStack {
                    Text("05 > MEMORY")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                    
                    Spacer()
                    
                    Text("<...> ORGANIZING FILE")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                    
                    Spacer()
                    
                    Text(">>>>>>")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Slice 6: GEMMA 3 (40pt indentation + 30pt shift)
                Text("GEMMA 3")
                    .font(.custom("IBMPlexMono-Bold", size: 12))
                    .foregroundColor(Color(hex: "141414"))
                    .padding(.leading, 90) // 40pt + 20pt margin + 30pt shift
                    .padding(.trailing, 20)
                    .padding(.top, 8)
                
                // Slice 7: LLAMA 3.2 (80pt indentation - 40pt from GEMMA + 30pt shift)
                Text("LLAMA 3.2")
                    .font(.custom("IBMPlexMono-Bold", size: 12))
                    .foregroundColor(Color(hex: "141414"))
                    .padding(.leading, 130) // 80pt + 20pt margin + 30pt shift
                    .padding(.trailing, 20)
                    .padding(.top, 8)
                
                // Slice 8: SMOLLM2 (120pt indentation - 40pt from LLAMA + 30pt shift)
                Text("SMOLLM2")
                    .font(.custom("IBMPlexMono-Bold", size: 12))
                    .foregroundColor(Color(hex: "141414"))
                    .padding(.leading, 170) // 120pt + 20pt margin + 30pt shift
                    .padding(.trailing, 20)
                    .padding(.top, 8)
                
                // Slice 9: // HUGGING FACE QWEN 3
                HStack {
                    Text("// HUGGING FACE")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                    
                    Text("QWEN 3")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                        .padding(.leading, 70) // Exactly 40pt from // HUGGING FACE + 30pt shift
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Slice 10: OPEN SOURCE
                HStack {
                    Spacer()
                    Text("OPEN SOURCE")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                Spacer().frame(height: 20)
                
                // Slice 11: < CONTROL Setup v1.0 >
                HStack(alignment: .center, spacing: 0) {
                    Text("<")
                        .font(.custom("IBMPlexMono-Bold", size: 28))
                        .foregroundColor(Color(hex: "141414"))
                    
                    Text(" CONTROL ")
                        .font(.custom("IBMPlexMono-Bold", size: 16)) // Smaller than before
                        .foregroundColor(Color(hex: "141414"))
                        .kerning(6) // More letter spacing
                        .baselineOffset(-2) // Move down to center-align with "Setup"
                    
                            Text("Setup")
                                .font(.custom("IBMPlexMono-Bold", size: 28))
                                .foregroundColor(Color(hex: "141414"))
                            
                            Text(" v1.0 ")
                                .font(.custom("IBMPlexMono-Bold", size: 28))
                                .foregroundColor(Color(hex: "141414"))
                    
                    Text(">")
                        .font(.custom("IBMPlexMono-Bold", size: 28))
                        .foregroundColor(Color(hex: "141414"))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Slice 12: 06 07 08 09 (with 30pt spacing between each)
                HStack(spacing: 30) {
                    Text("06")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                    Text("07")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                    Text("08")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                    Text("09")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                Spacer().frame(height: 20)
                
                // Slice 13: INITIALIZATION PROGRESS with progress bar
                VStack(alignment: .leading, spacing: 8) {
                    Text("INITIALIZATION PROGRESS:")
                        .font(.custom("IBMPlexMono-Bold", size: 12))
                        .foregroundColor(Color(hex: "141414"))
                    
                    HStack {
                        // Much longer progress bar
                        HStack(spacing: 0) {
                            ForEach(0..<50, id: \.self) { index in
                                if index < Int(setupManager.progress * 50) {
                                    Text("█")
                                        .font(.custom("IBMPlexMono-Bold", size: 12))
                                        .foregroundColor(Color(hex: "141414"))
                                } else {
                                    Text("░")
                                        .font(.custom("IBMPlexMono-Bold", size: 12))
                                        .foregroundColor(Color(hex: "141414"))
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Text("\(Int(setupManager.progress * 100))%")
                            .font(.custom("IBMPlexMono-Bold", size: 12))
                            .foregroundColor(Color(hex: "141414"))
                            .padding(.leading, 10) // 10pt spacing from the bar
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                Spacer().frame(height: 60) // Increased from 40pt to 60pt (20pt more spacing)
                
                // Slice 14: SETUP & INITIALIZATION with status messages
                VStack(alignment: .leading, spacing: 8) {
                    Text("SETUP & INITIALIZATION")
                        .font(.custom("IBMPlexMono-Bold", size: 16)) // Same size as CONTROL
                        .foregroundColor(Color(hex: "141414"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(setupManager.statusMessages, id: \.self) { message in
                            Text(message)
                                .font(.custom("IBMPlexMono-Bold", size: 12)) // Same as 01 > MODEL
                                .foregroundColor(Color(hex: "141414"))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .onAppear {
            calculateAvailableStorage()
            Task {
                await setupManager.performFirstRunSetup()
            }
        }
        .onChange(of: setupManager.isComplete) { _, isComplete in
            if isComplete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showMainApp = true
                }
            }
        }
        .fullScreenCover(isPresented: $showMainApp) {
            BackgroundSecurityView {
                MainView()
                    .environmentObject(ColorManager.shared)
                    .onAppear {
                        ColorManager.shared.refreshColors()
                        debugPrint("MainView appeared!", category: .ui)
                    }
            }
        }
    }
    
    private func calculateAvailableStorage() {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let freeSize = systemAttributes[.systemFreeSize] as? NSNumber {
                let freeBytes = freeSize.int64Value
                let freeGB = Double(freeBytes) / (1024 * 1024 * 1024)
                
                if freeGB >= 1000 {
                    availableStorage = String(format: "%.0fGB", freeGB)
                } else if freeGB >= 1 {
                    availableStorage = String(format: "%.0fGB", freeGB)
                } else {
                    let freeMB = freeGB * 1024
                    availableStorage = String(format: "%.0fMB", freeMB)
                }
            } else {
                availableStorage = "Unknown"
            }
        } catch {
            availableStorage = "Unknown"
        }
    }
    
    private func startBlinking() {
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.8)) {
                isReadyBlinking.toggle()
            }
        }
    }
    
    private func stopBlinking() {
        blinkTimer?.invalidate()
        blinkTimer = nil
    }
    
}

#Preview {
    FirstRunSetupView()
}