//
//  Control_LLMApp.swift
//  Control LLM
//
//  Created by Carlos Tarrats on 7/25/25.
//

import SwiftUI
import os.log
import AppIntents

// MARK: - Performance Optimization: Lazy Service Manager
class LazyServiceManager {
    static let shared = LazyServiceManager()
    
    private var services: [String: Any] = [:]
    private let serviceQueue = DispatchQueue(label: "com.controlllm.services", attributes: .concurrent)
    
    private init() {}
    
    func getService<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        
        return serviceQueue.sync {
            if let service = services[key] as? T {
                return service
            }
            
            let service = createService(type)
            services[key] = service
            return service
        }
    }
    
    private func createService<T>(_ type: T.Type) -> T {
        // This would need to be implemented based on your specific service types
        // For now, return a placeholder
        fatalError("Service creation not implemented for \(type)")
    }
}

// MARK: - Console Flooding Prevention
#if DEBUG
private func disableConsoleFlooding() {
    // Disable SwiftUI's excessive logging that causes console flooding
    UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
    setenv("OS_ACTIVITY_MODE", "disable", 1)
    setenv("SWIFTUI_DEBUG", "0", 1)
    setenv("SWIFTUI_ENABLE_LOGGING", "0", 1)
    
    // Reduce Metal/GPU logging
    setenv("METAL_DEVICE_WRAPPER_TYPE", "1", 1)
    setenv("GGML_METAL_DEBUG", "0", 1)
    
    // Disable Core Data and other verbose logging
    setenv("SQLITE_ENABLE_LOGGING", "0", 1)
    
}
#else
private func disableConsoleFlooding() {
    // In production, only disable the most critical logging
    UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
}
#endif

@main
struct Control_LLMApp: App {
    @State private var isAppReady = false
    @Environment(\.scenePhase) private var scenePhase

    init() {
        
        // FIRST: Stop console flooding immediately
        disableConsoleFlooding()
        
        
        // Register custom fonts (minimal, fast operation)
        registerCustomFonts()
        
        
        // Defer ALL heavy initialization to background - show UI immediately
        Task.detached(priority: .background) {
            await Self.initializeAllServices()
        }
        
    }
    
    var body: some Scene {
        let isFirstRun = FirstRunManager.shared.isFirstRun
        
        return WindowGroup {
            if isFirstRun {
                FirstRunSetupView()
            } else {
                BackgroundSecurityView {
                    MainView()
                        .environmentObject(ColorManager.shared)
                        .onAppear {
                            ColorManager.shared.refreshColors()
                        }
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                NSLog("App is active")
            case .inactive, .background:
                NSLog("App is inactive or in background - cleaning up model state.")
                Task {
                    await HybridLLMService.shared.ensureModelStateIsClean()
                }
            @unknown default:
                NSLog("Unknown scene phase")
            }
        }
    }
    
    private func registerCustomFonts() {
        let fontNames = ["IBMPlexMono-Regular", "IBMPlexMono-Medium", "IBMPlexMono-Bold"]
        
        for fontName in fontNames {
            if let fontURL = Bundle.main.url(forResource: fontName, withExtension: "otf") {
                var error: Unmanaged<CFError>?
                let success = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
                if !success {
                    print("Failed to load font: \(fontName)")
                    if let error = error {
                        print("Error: \(error)")
                    }
                } else {
                    print("Successfully loaded font: \(fontName)")
                }
            } else {
                print("Font file not found: \(fontName).otf")
            }
        }
    }
    
    // MARK: - Performance Optimizations
    
    /// Initialize all services in background - UI shows immediately
    private static func initializeAllServices() async {
        
        // CRITICAL DEBUG: Log app startup state for comparison
        NSLog("Control_LLMApp: 🚀 APP STARTUP - initializeAllServices() called")
        NSLog("Control_LLMApp: App state at startup:")
        NSLog("Control_LLMApp: - First run: \(FirstRunManager.shared.isFirstRun)")
        NSLog("Control_LLMApp: - App lifecycle state: \(UIApplication.shared.applicationState.rawValue)")
        NSLog("Control_LLMApp: - Background time remaining: \(UIApplication.shared.backgroundTimeRemaining)")
        
        // Initialize ModelManager
        DispatchQueue.main.async {
            let _ = ModelManager.shared
        }
        
        // Initialize security components
        Self.initializeSecurityComponents()
        
        // Initialize Shortcuts integration if available
        if #available(iOS 16.0, *) {
            Self.initializeShortcutsIntegration()
        }
        
    }
    
    private static func initializeSecurityComponents() {
        
        // Initialize Metal memory manager
        let _ = MetalMemoryManager.shared
        
        // Initialize background security manager
        let _ = BackgroundSecurityManager.shared
        
        // Initialize data cleanup manager
        let _ = DataCleanupManager.shared
        
    }
    
    @available(iOS 16.0, *)
    private static func initializeShortcutsIntegration() {
        
        // Initialize the Shortcuts service
        let _ = ShortcutsService.shared
        
        // Initialize the Shortcuts integration helper
        let _ = ShortcutsIntegrationHelper.shared
        
        // App Intents automatically handle authorization and integration
        // No need to manually request Siri authorization with App Intents
        
    }
}
