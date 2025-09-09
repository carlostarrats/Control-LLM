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
        
        // Step 1: Initialize backend
        updateStatus("> INITIALIZING METAL BACKEND...")
        updateProgress(0.1)
        
        // Step 2: Call Metal shader compilation
        updateStatus("> COMPILING SHADER KERNELS...")
        updateProgress(0.2)
        
        // This is the actual 30-second Metal compilation
        print("🔥 Starting Metal shader compilation (this takes ~30 seconds)...")
        llm_bridge_preload_metal_shaders()
        
        // Simulate progress updates during compilation
        await simulateProgressUpdates()
        
        // Step 3: Finalize
        updateStatus("> FINALIZING AI ENGINE...")
        updateProgress(1.0)
        
        // Mark first run as complete
        firstRunManager.markFirstRunComplete()
        updateComplete()
        
        print("✅ First run setup completed successfully")
    }
    
    /// Simulates progress updates during Metal compilation
    private func simulateProgressUpdates() async {
        let messages = [
            "> OPTIMIZING MATRIX OPERATIONS...",
            "> LOADING QUANTIZATION TABLES...",
            "> PREPARING MEMORY POOLS...",
            "> CACHING COMPILED SHADERS...",
            "> VALIDATING KERNEL FUNCTIONS...",
            "> COMPLETING OPTIMIZATION..."
        ]
        
        // Start with more frequent progress updates
        let totalSteps = 30 // More granular progress
        let baseProgress = 0.2
        let progressIncrement = 0.6 / Double(totalSteps) // 0.6 progress over 30 steps
        
        for step in 0..<totalSteps {
            // Update progress every 0.5 seconds for smoother animation
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            let currentProgress = baseProgress + (Double(step) * progressIncrement)
            updateProgress(currentProgress)
            
            // Update status message every 3 steps (every 1.5 seconds)
            if step % 3 == 0 && step / 3 < messages.count {
                updateStatus(messages[step / 3])
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
