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
    
    // Faux loading animation states
    @State private var showStatus = false
    @State private var showTemp = false
    @State private var showMemory = false
    @State private var showOrganizingFile = false
    @State private var showGemma = false
    @State private var showLlama = false
    @State private var showSmollm = false
    @State private var showHuggingFace = false
    @State private var showQwen = false
    @State private var showOpenSource = false
    @State private var showNumber06 = false
    @State private var showNumber07 = false
    @State private var showNumber08 = false
    @State private var showNumber09 = false
    @State private var showNumber10 = false
    @State private var showNumber11 = false
    @State private var showNumber12 = false
    @State private var showNumber13 = false
    @State private var showNumber14 = false
    @State private var showNumber15 = false
    @State private var showNumber16 = false
    @State private var showNumber17 = false
    @State private var showNumber18 = false
    @State private var showNumber19 = false
    @State private var showNumber20 = false
    @State private var showNumber21 = false
    
    // Cache the red color to prevent repeated access
    private let redColor = ColorManager.shared.redColor
    
    init() {
    }
    
    var body: some View {
        ZStack {
            // Red background (your signature color) - cached for performance
            redColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // FIXED HEADER - Always visible at top
                VStack(alignment: .leading, spacing: 0) {
                    // Slice 1: Top section - CONTROL V1.1 left, 80GB AVAILABLE right
                    HStack {
                        Text(NSLocalizedString("CONTROL V1.1", comment: ""))
                            .font(.custom("IBMPlexMono", size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "141414"))
                        
                        Spacer()
                        
                        Text("\(availableStorage) \(NSLocalizedString("AVAILABLE", comment: ""))")
                            .font(.custom("IBMPlexMono", size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "141414"))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Slice 2: PROCESSING...
                        Text(NSLocalizedString("PROCESSING...", comment: ""))
                            .font(.custom("IBMPlexMono", size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "141414"))
                            .opacity(isReadyBlinking ? 1.0 : 0.3)
                            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isReadyBlinking)
                            .onAppear {
                                startBlinking()
                            }
                            .onDisappear {
                                stopBlinking()
                            }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    Spacer().frame(height: 4)
                }
                .background(redColor) // Ensure header has solid background
                
                // SCROLLABLE CONTENT - Everything else scrolls under the header
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Slice 3: 01 > MODEL
                        HStack {
                            Text("01 > \(NSLocalizedString("MODEL", comment: ""))")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // Slice 4: 02 > STATUS
                        HStack {
                            Text("02 > \(NSLocalizedString("STATUS", comment: ""))")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .opacity(showStatus ? 1.0 : 0.0)
                        
                        // Slice 5: 03 > TEMP (was 04 > TEMP)
                        HStack {
                            Text("03 > \(NSLocalizedString("TEMP", comment: ""))")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .opacity(showTemp ? 1.0 : 0.0)
                        
                        // Slice 6: 04 > MEMORY (was 05 > MEMORY)
                        HStack {
                            Text("04 > \(NSLocalizedString("MEMORY", comment: ""))")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                            
                            Spacer()
                                .frame(width: 30)
                            
                            Text("<...> \(NSLocalizedString("ORGANIZING FILE", comment: ""))")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showOrganizingFile ? 1.0 : 0.0)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .opacity(showMemory ? 1.0 : 0.0)
                        
                        // Slice 6: GEMMA 3 (40pt indentation + 30pt shift)
                        Text(NSLocalizedString("GEMMA 3", comment: ""))
                            .font(.custom("IBMPlexMono", size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "141414"))
                            .padding(.leading, 90) // 40pt + 20pt margin + 30pt shift
                            .padding(.trailing, 20)
                            .padding(.top, 4)
                            .opacity(showGemma ? 1.0 : 0.0)
                        
                        // Slice 7: LLAMA 3.2 (80pt indentation - 40pt from GEMMA + 30pt shift)
                        Text(NSLocalizedString("LLAMA 3.2", comment: ""))
                            .font(.custom("IBMPlexMono", size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "141414"))
                            .padding(.leading, 130) // 80pt + 20pt margin + 30pt shift
                            .padding(.trailing, 20)
                            .padding(.top, 4)
                            .opacity(showLlama ? 1.0 : 0.0)
                        
                        // Slice 8: SMOLLM2 (120pt indentation - 40pt from LLAMA + 30pt shift)
                        Text(NSLocalizedString("SMOLLM2", comment: ""))
                            .font(.custom("IBMPlexMono", size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "141414"))
                            .padding(.leading, 170) // 120pt + 20pt margin + 30pt shift
                            .padding(.trailing, 20)
                            .padding(.top, 4)
                            .opacity(showSmollm ? 1.0 : 0.0)
                        
                        // Slice 9: // HUGGING FACE QWEN 3
                        HStack {
                            Text("// \(NSLocalizedString("HUGGING FACE", comment: ""))")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showHuggingFace ? 1.0 : 0.0)
                            
                            Text(NSLocalizedString("QWEN 3", comment: ""))
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .padding(.leading, 70) // Exactly 40pt from // HUGGING FACE + 30pt shift
                                .opacity(showQwen ? 1.0 : 0.0)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        
                        // Slice 10: OPEN SOURCE
                        HStack {
                            Spacer()
                            Text(NSLocalizedString("OPEN SOURCE", comment: ""))
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .opacity(showOpenSource ? 1.0 : 0.0)
                        
                        // Slice 11: < CONTROL Setup v1.1 >
                        HStack(alignment: .center, spacing: 0) {
                            Text("<")
                                .font(.custom("IBMPlexMono", size: 28))
                                .foregroundColor(Color(hex: "141414"))
                            
                            Text(NSLocalizedString("SETUP", comment: ""))
                                .font(.custom("IBMPlexMono", size: 28))
                                .fontWeight(.medium)
                                .foregroundColor(Color(hex: "141414"))
                            
                            Text("/")
                                .font(.custom("IBMPlexMono", size: 28))
                                .foregroundColor(Color(hex: "141414"))
                            
                            Text(">")
                                .font(.custom("IBMPlexMono", size: 28))
                                .foregroundColor(Color(hex: "141414"))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        
                        // Slice 12: 06 07 08 09 (with 30pt spacing between each)
                        HStack(spacing: 30) {
                            Text("06")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber06 ? 1.0 : 0.0)
                            Text("07")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber07 ? 1.0 : 0.0)
                            Text("08")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber08 ? 1.0 : 0.0)
                            Text("09")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber09 ? 1.0 : 0.0)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        Spacer().frame(height: 10)
                        
                        // Slice 13: INITIALIZATION PROGRESS with progress bar
                        VStack(alignment: .leading, spacing: 8) {
                            Text(NSLocalizedString("INITIALIZATION PROGRESS:", comment: ""))
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                            
                            GeometryReader { geometry in
                                HStack {
                                    // Responsive progress bar that uses full width
                                    HStack(spacing: 0) {
                                        let totalBars = Int((geometry.size.width - 40) / 6) // Calculate bars based on available width
                                        ForEach(0..<totalBars, id: \.self) { index in
                                            if index < Int(setupManager.progress * Double(totalBars)) {
                                                Text("█")
                                                    .font(.custom("IBMPlexMono", size: 12))
                                                    .foregroundColor(Color(hex: "141414"))
                                            } else {
                                                Text("░")
                                                    .font(.custom("IBMPlexMono", size: 12))
                                                    .foregroundColor(Color(hex: "141414"))
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(Int(setupManager.progress * 100))%")
                                        .font(.custom("IBMPlexMono", size: 12))
                                        .foregroundColor(Color(hex: "141414"))
                                        .padding(.leading, 10) // 10pt spacing from the bar
                                }
                            }
                            .frame(height: 20) // Fixed height for the progress bar
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        
                        // Additional numbers 10 11 12 13 (10pt under progress bar)
                        Spacer().frame(height: 10)
                        
                        HStack(spacing: 30) {
                            Text("10")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber10 ? 1.0 : 0.0)
                            Text("11")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber11 ? 1.0 : 0.0)
                            Text("12")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber12 ? 1.0 : 0.0)
                            Text("13")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber13 ? 1.0 : 0.0)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // 10pt spacing between all number rows
                        Spacer().frame(height: 10)
                        
                        // Numbers 14, 15, 16, 17 (same spacing as 10-13)
                        HStack(spacing: 30) {
                            Text("14")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber14 ? 1.0 : 0.0)
                            Text("15")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber15 ? 1.0 : 0.0)
                            Text("16")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber16 ? 1.0 : 0.0)
                            Text("17")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber17 ? 1.0 : 0.0)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // Numbers 18, 19, 20, 21 (10pt below 14-17)
                        Spacer().frame(height: 10)
                        
                        HStack(spacing: 30) {
                            Text("18")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber18 ? 1.0 : 0.0)
                            Text("19")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber19 ? 1.0 : 0.0)
                            Text("20")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber20 ? 1.0 : 0.0)
                            Text("21")
                                .font(.custom("IBMPlexMono", size: 12))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                                .opacity(showNumber21 ? 1.0 : 0.0)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        Spacer().frame(height: 10)
                        
                        // Slice 14: SETUP & INITIALIZATION with status messages
                        VStack(alignment: .leading, spacing: 4) {
                            Text(NSLocalizedString("SETUP & INITIALIZATION", comment: ""))
                                .font(.custom("IBMPlexMono", size: 16)) // Same size as CONTROL
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "141414"))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(setupManager.statusMessages, id: \.self) { message in
                                    Text(message)
                                        .font(.custom("IBMPlexMono", size: 12)) // Same as 01 > MODEL
                                        .foregroundColor(Color(hex: "141414"))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            
            // Calculate storage immediately for instant display
            calculateAvailableStorage()
            
            // Start faux loading animation sequence (3 seconds total)
            startFauxLoadingAnimation()
            
            // Start setup process immediately - no delay
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
        // Use a more efficient approach - let the animation handle the timing
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            isReadyBlinking = false
        }
    }
    
    private func stopBlinking() {
        isReadyBlinking = true
    }
    
    private func startFauxLoadingAnimation() {
        // Sequence: 02>Status, 03>Latency, 04>Temp, 05>Memory, <...> Organizing File, >>>>>, 
        // Gemma 3, Llama 3.2, Smollm2, //Hugging Face, Qwen3, Open Source, 06 07 08 09 10 11 12 13
        // Total duration: 5.1 seconds (300ms per item)
        
        let delay = 0.3 // 300ms between each item
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 1) {
            withAnimation(.easeIn(duration: 0.2)) {
                showStatus = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 2) {
            withAnimation(.easeIn(duration: 0.2)) {
                showTemp = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 3) {
            withAnimation(.easeIn(duration: 0.2)) {
                showMemory = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 4) {
            withAnimation(.easeIn(duration: 0.2)) {
                showOrganizingFile = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 5) {
            withAnimation(.easeIn(duration: 0.2)) {
                showGemma = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 6) {
            withAnimation(.easeIn(duration: 0.2)) {
                showLlama = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 7) {
            withAnimation(.easeIn(duration: 0.2)) {
                showSmollm = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 8) {
            withAnimation(.easeIn(duration: 0.2)) {
                showHuggingFace = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 9) {
            withAnimation(.easeIn(duration: 0.2)) {
                showQwen = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 10) {
            withAnimation(.easeIn(duration: 0.2)) {
                showOpenSource = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 11) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber06 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 12) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber07 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 13) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber08 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 14) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber09 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 15) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber10 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 16) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber11 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 17) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber12 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 18) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber13 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 19) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber14 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 20) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber15 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 21) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber16 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 22) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber17 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 23) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber18 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 24) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber19 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 25) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber20 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay * 26) {
            withAnimation(.easeIn(duration: 0.2)) {
                showNumber21 = true
            }
        }
    }
    
}

#Preview {
    FirstRunSetupView()
}