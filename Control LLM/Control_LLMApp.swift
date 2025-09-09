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
    
    print("🔇 Console flooding prevention enabled")
}
#else
private func disableConsoleFlooding() {
    // In production, only disable the most critical logging
    UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
}
#endif

@main
struct Control_LLMApp: App {
    init() {
        // FIRST: Stop console flooding immediately
        disableConsoleFlooding()
        
        #if DEBUG
        // Debug logging only - no filesystem writes for security
        let timestamp = Date().description
        print("🔍 App starting... at \(timestamp)")
        #endif
        
        print("🔍 App starting...")
        // Register custom fonts
        registerCustomFonts()
        print("🔍 App started successfully")
        
        // PERFORMANCE OPTIMIZATION: Defer heavy initialization to background
        Task.detached(priority: .background) {
            await Self.initializeNonCriticalServices()
        }
        
        // Initialize only critical services immediately
        initializeCriticalServices()
        
        #if DEBUG
        let successMessage = "🔍 App started successfully at \(timestamp)"
        print(successMessage)
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Always show red background immediately to prevent white screen
                ColorManager.shared.redColor
                    .ignoresSafeArea()
                
                if FirstRunManager.shared.isFirstRun {
                    FirstRunSetupView()
                } else {
                    BackgroundSecurityView {
                        MainView()
                            .environmentObject(ColorManager.shared)
                            .onAppear {
                                // Refresh colors on appear to apply saved settings
                                ColorManager.shared.refreshColors()
                                debugPrint("MainView appeared!", category: .ui)
                            }
                    }
                }
            }
        }
    }
    
    private func registerCustomFonts() {
        let fontNames = ["IBMPlexMono-Regular", "IBMPlexMono-Medium", "IBMPlexMono-Bold"]
        
        for fontName in fontNames {
            if let fontURL = Bundle.main.url(forResource: fontName, withExtension: "otf") {
                var error: Unmanaged<CFError>?
                CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
            }
        }
    }
    
    // MARK: - Performance Optimizations
    
    /// Initialize only critical services that are needed immediately
    private func initializeCriticalServices() {
        print("🚀 Initializing critical services...")
        
        // Only initialize essential services for app launch
        let _ = LazyServiceManager.shared
        
        print("🚀 Critical services initialized")
    }
    
    /// Initialize non-critical services in background
    private static func initializeNonCriticalServices() async {
        print("🔄 Initializing non-critical services in background...")
        
        // Initialize ModelManager (can be done in background)
        DispatchQueue.main.async {
            let _ = ModelManager.shared
        }
        
        // Initialize security components
        Self.initializeSecurityComponents()
        
        // Initialize Shortcuts integration if available
        if #available(iOS 16.0, *) {
            Self.initializeShortcutsIntegration()
        }
        
        print("✅ Non-critical services initialized")
    }
    
    private static func initializeSecurityComponents() {
        print("🔒 Initializing security components...")
        
        // Initialize Metal memory manager
        let _ = MetalMemoryManager.shared
        
        // Initialize background security manager
        let _ = BackgroundSecurityManager.shared
        
        // Initialize data cleanup manager
        let _ = DataCleanupManager.shared
        
        print("🔒 Security components initialized")
    }
    
    @available(iOS 16.0, *)
    private static func initializeShortcutsIntegration() {
        print("🔗 Initializing Shortcuts integration...")
        
        // Initialize the Shortcuts service
        let _ = ShortcutsService.shared
        
        // Initialize the Shortcuts integration helper
        let _ = ShortcutsIntegrationHelper.shared
        
        // App Intents automatically handle authorization and integration
        // No need to manually request Siri authorization with App Intents
        
        print("🔗 Shortcuts integration initialized with App Intents")
    }
}
