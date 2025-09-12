//
//  FirstRunSetupManager.swift
//  Control LLM
//
//  Created by Carlos Tarrats on 9/8/25.
//

import Foundation
import SwiftUI

/// Manages the first run setup process with progress tracking
class FirstRunSetupManager: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var statusMessages: [String] = []
    @Published var isComplete = false
    
    private let firstRunManager = FirstRunManager.shared
    
    /// Performs the complete first run setup process
    func performFirstRunSetup() async {
        
        // Step 1: Initialize backend (1 second)
        updateStatus(NSLocalizedString("> INITIALIZING METAL BACKEND...", comment: ""))
        updateProgress(0.1)
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Step 2: Start Metal compilation in background (don't wait for it)
        updateStatus(NSLocalizedString("> COMPILING SHADER KERNELS...", comment: ""))
        updateProgress(0.2)
        
        // Test Metal compilation with DispatchQueue.global().async (background thread)
        DispatchQueue.global().async {
            llm_bridge_preload_metal_shaders()
        }
        
        // Step 3: Simulate progress updates for 16 seconds (18 total)
        await simulateProgressUpdates()
        
        // Step 4: Finalize (1 second)
        updateStatus(NSLocalizedString("> FINALIZING AI ENGINE...", comment: ""))
        updateProgress(0.95)
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        updateStatus(NSLocalizedString("> SETUP COMPLETE", comment: ""))
        updateProgress(1.0)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Mark first run as complete (Metal still compiling in background)
        firstRunManager.markFirstRunComplete()
        updateComplete()
        
    }
    
    /// Simulates progress updates during setup (16 seconds total)
    private func simulateProgressUpdates() async {
        let messages = [
            NSLocalizedString("> OPTIMIZING MATRIX OPERATIONS...", comment: ""),
            NSLocalizedString("> LOADING QUANTIZATION TABLES...", comment: ""),
            NSLocalizedString("> PREPARING MEMORY POOLS...", comment: ""),
            NSLocalizedString("> CACHING COMPILED SHADERS...", comment: ""),
            NSLocalizedString("> VALIDATING KERNEL FUNCTIONS...", comment: ""),
            NSLocalizedString("> COMPLETING OPTIMIZATION...", comment: ""),
            NSLocalizedString("> FINALIZING METAL KERNELS...", comment: ""),
            NSLocalizedString("> OPTIMIZING GPU MEMORY...", comment: ""),
            NSLocalizedString("> PREPARING INFERENCE ENGINE...", comment: "")
        ]
        
        // 16 seconds total with 32 steps = 0.5 seconds per step
        let totalSteps = 32
        let baseProgress = 0.2
        let progressIncrement = 0.7 / Double(totalSteps) // 0.7 progress over 32 steps (0.2 to 0.9)
        
        for step in 0..<totalSteps {
            // Update progress every 0.5 seconds for exactly 16 seconds total
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            let currentProgress = baseProgress + (Double(step) * progressIncrement)
            updateProgress(currentProgress)
            
            // Update status message every 4 steps (every 2 seconds)
            if step % 4 == 0 && step / 4 < messages.count {
                updateStatus(messages[step / 4])
            }
        }
    }
    
    private func updateStatus(_ message: String) {
        DispatchQueue.main.async {
            self.statusMessages.append(message)
        }
    }
    
    private func updateProgress(_ value: Double) {
        DispatchQueue.main.async {
            self.progress = value
        }
    }
    
    private func updateComplete() {
        DispatchQueue.main.async {
            self.isComplete = true
        }
    }
}
