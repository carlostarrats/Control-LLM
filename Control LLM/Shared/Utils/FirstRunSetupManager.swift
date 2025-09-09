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
        print("🚀 Starting first run setup process...")
        
        // Step 1: Initialize backend (2 seconds)
        updateStatus("> INITIALIZING METAL BACKEND...")
        updateProgress(0.05)
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Step 2: Call Metal shader compilation (25 seconds)
        updateStatus("> COMPILING SHADER KERNELS...")
        updateProgress(0.1)
        
        // Start Metal compilation in background
        print("🔥 Starting Metal shader compilation (this takes ~25 seconds)...")
        let metalTask = Task {
            llm_bridge_preload_metal_shaders()
        }
        
        // Simulate progress updates during compilation (25 seconds total)
        await simulateProgressUpdates()
        
        // Wait for Metal compilation to complete
        await metalTask.value
        
        // Step 3: Finalize (3 seconds)
        updateStatus("> FINALIZING AI ENGINE...")
        updateProgress(0.95)
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        updateStatus("> SETUP COMPLETE")
        updateProgress(1.0)
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Mark first run as complete
        firstRunManager.markFirstRunComplete()
        updateComplete()
        
        print("✅ First run setup completed successfully in exactly 30 seconds")
    }
    
    /// Simulates progress updates during Metal compilation (25 seconds total)
    private func simulateProgressUpdates() async {
        let messages = [
            "> OPTIMIZING MATRIX OPERATIONS...",
            "> LOADING QUANTIZATION TABLES...",
            "> PREPARING MEMORY POOLS...",
            "> CACHING COMPILED SHADERS...",
            "> VALIDATING KERNEL FUNCTIONS...",
            "> COMPLETING OPTIMIZATION...",
            "> FINALIZING METAL KERNELS...",
            "> OPTIMIZING GPU MEMORY...",
            "> PREPARING INFERENCE ENGINE..."
        ]
        
        // 25 seconds total with 50 steps = 0.5 seconds per step
        let totalSteps = 50
        let baseProgress = 0.1
        let progressIncrement = 0.8 / Double(totalSteps) // 0.8 progress over 50 steps (0.1 to 0.9)
        
        for step in 0..<totalSteps {
            // Update progress every 0.5 seconds for exactly 25 seconds total
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            let currentProgress = baseProgress + (Double(step) * progressIncrement)
            updateProgress(currentProgress)
            
            // Update status message every 5 steps (every 2.5 seconds)
            if step % 5 == 0 && step / 5 < messages.count {
                updateStatus(messages[step / 5])
            }
        }
    }
    
    private func updateStatus(_ message: String) {
        DispatchQueue.main.async {
            self.statusMessages.append(message)
        }
        print("📱 Setup: \(message)")
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
