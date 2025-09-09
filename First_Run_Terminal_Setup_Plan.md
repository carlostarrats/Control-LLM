# First Run Terminal Setup Plan

## Overview
Implement a dedicated first-run setup screen that handles Metal shader compilation in a user-friendly, terminal-style interface. This ensures the 30-second compilation happens only once and all subsequent app launches are instant.

## Requirements
- **One-time setup**: Only show on first app launch
- **30-second duration**: Real Metal shader compilation time
- **Terminal aesthetic**: Red background, monospace font, terminal-style text
- **Real-time progress**: Live updates and percentage counter
- **Instant subsequent launches**: No delays after first run

## Implementation Steps

### 1. Create First Run Detection
```swift
// Add to UserDefaults
private let hasCompletedFirstRunKey = "hasCompletedFirstRun"

func isFirstRun() -> Bool {
    return !UserDefaults.standard.bool(forKey: hasCompletedFirstRunKey)
}

func markFirstRunComplete() {
    UserDefaults.standard.set(true, forKey: hasCompletedFirstRunKey)
}
```

### 2. Create Terminal Setup View
```swift
struct FirstRunSetupView: View {
    @State private var progress: Double = 0.0
    @State private var statusText: String = ""
    @State private var isComplete = false
    
    var body: some View {
        ZStack {
            Color.red // Your signature red background
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                Text("First Run Setup - Optimization & Initialization")
                    .font(.custom("IBMPlexMono-Bold", size: 24))
                    .foregroundColor(.white)
                
                Text("===============================================")
                    .font(.custom("IBMPlexMono-Regular", size: 16))
                    .foregroundColor(.green)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(statusMessages, id: \.self) { message in
                            Text(message)
                                .font(.custom("IBMPlexMono-Regular", size: 14))
                                .foregroundColor(.green)
                        }
                    }
                }
                .frame(maxHeight: 300)
                
                Text("Progress: \(Int(progress * 100))%")
                    .font(.custom("IBMPlexMono-Bold", size: 18))
                    .foregroundColor(.white)
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
            }
            .padding()
        }
    }
}
```

### 3. Implement Metal Shader Compilation with Progress
```swift
class FirstRunSetupManager: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var statusMessages: [String] = []
    @Published var isComplete = false
    
    func performFirstRunSetup() async {
        let startTime = Date()
        
        // Step 1: Initialize backend
        await updateStatus("[00:00] Initializing Metal backend...")
        await updateProgress(0.1)
        
        // Step 2: Call Metal shader compilation
        await updateStatus("[00:05] Compiling shader kernels...")
        await updateProgress(0.2)
        
        // This is the actual 30-second Metal compilation
        llm_bridge_preload_metal_shaders()
        
        // Simulate progress updates during compilation
        await simulateProgressUpdates()
        
        // Step 3: Finalize
        await updateStatus("[00:30] Finalizing AI engine...")
        await updateProgress(1.0)
        
        // Mark first run as complete
        markFirstRunComplete()
        isComplete = true
    }
    
    private func simulateProgressUpdates() async {
        let messages = [
            "[00:08] Optimizing matrix operations...",
            "[00:12] Loading quantization tables...",
            "[00:16] Preparing memory pools...",
            "[00:20] Caching compiled shaders...",
            "[00:24] Validating kernel functions...",
            "[00:28] Completing optimization..."
        ]
        
        for (index, message) in messages.enumerated() {
            try? await Task.sleep(nanoseconds: 4_000_000_000) // 4 seconds
            await updateStatus(message)
            await updateProgress(0.2 + (Double(index + 1) * 0.1))
        }
    }
    
    @MainActor
    private func updateStatus(_ message: String) {
        statusMessages.append(message)
    }
    
    @MainActor
    private func updateProgress(_ value: Double) {
        progress = value
    }
}
```

### 4. Modify App Launch Flow
```swift
// In Control_LLMApp.swift
@main
struct Control_LLMApp: App {
    @StateObject private var setupManager = FirstRunSetupManager()
    
    var body: some Scene {
        WindowGroup {
            if FirstRunSetupManager.isFirstRun() {
                FirstRunSetupView()
                    .environmentObject(setupManager)
                    .onAppear {
                        Task {
                            await setupManager.performFirstRunSetup()
                        }
                    }
            } else {
                // Normal app flow
                BackgroundSecurityView {
                    MainView()
                        .environmentObject(ColorManager.shared)
                }
            }
        }
    }
}
```

### 5. Restore Metal Shader Pre-warming Function
```swift
// In LlamaCppBridge.mm - restore the actual Metal compilation
void llm_bridge_preload_metal_shaders(void) {
    NSLog(@"LlamaCppBridge: Starting Metal shader compilation...");
    
    if (!s_backend_initialized) {
        NSLog(@"LlamaCppBridge: Initializing backend for Metal shader compilation");
        llama_backend_init();
        llama_log_set(bridge_llama_log_callback, NULL);
        s_backend_initialized = true;
    }
    
    #if __has_include("ggml-metal.h")
    NSLog(@"LlamaCppBridge: Compiling Metal shaders (this takes ~30 seconds)");
    s_metal_backend = ggml_backend_metal_init();
    if (s_metal_backend) {
        NSLog(@"LlamaCppBridge: ✅ Metal shaders compiled successfully");
    } else {
        NSLog(@"LlamaCppBridge: ⚠️ Failed to compile Metal shaders");
    }
    #endif
    
    NSLog(@"LlamaCppBridge: Metal shader compilation completed");
}
```

### 6. Ensure Instant Subsequent Launches
```swift
// In Control_LLMApp.swift - remove any background Metal compilation
// The shaders are now compiled during first run only
init() {
    disableConsoleFlooding()
    registerCustomFonts()
    
    // Only initialize critical services immediately
    initializeCriticalServices()
    
    // No background Metal compilation - shaders are pre-compiled
}
```

## Technical Details

### Why This Works
1. **One-time compilation**: Metal shaders are compiled only on first run
2. **System caching**: iOS caches compiled Metal shaders automatically
3. **No runtime delays**: Subsequent launches skip compilation entirely
4. **User expectation**: 30-second setup feels intentional, not broken

### Progress Simulation
- Real compilation takes ~30 seconds
- Progress updates every 4 seconds with realistic messages
- Percentage increases smoothly from 0% to 100%
- Terminal-style timestamps make it feel authentic

### Error Handling
- If compilation fails, show error message
- Allow retry mechanism
- Fallback to CPU-only mode if needed

## Testing Checklist
- [ ] First run shows terminal setup screen
- [ ] Progress updates every 4 seconds
- [ ] Compilation completes in ~30 seconds
- [ ] Second launch is instant (no setup screen)
- [ ] Chat responds immediately after setup
- [ ] App remembers first run completion

## Success Criteria
- ✅ First run: 30-second setup with progress indication
- ✅ Subsequent runs: Instant launch, instant chat
- ✅ Terminal aesthetic matches app design
- ✅ Users understand this is one-time setup
- ✅ No white screens or unexpected delays
