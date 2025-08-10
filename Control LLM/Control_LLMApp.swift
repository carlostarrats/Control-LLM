//
//  Control_LLMApp.swift
//  Control LLM
//
//  Created by Carlos Tarrats on 7/25/25.
//

import SwiftUI

@main
struct Control_LLMApp: App {
    init() {
        // Write to a file to test if the app is actually running
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let logFile = documentsPath.appendingPathComponent("app_log.txt")
        let timestamp = Date().description
        let logMessage = "🔍 App starting... at \(timestamp)\n"
        try? logMessage.write(to: logFile, atomically: true, encoding: .utf8)
        
        NSLog("🔍 App starting...")
        // Register custom fonts
        registerCustomFonts()
        NSLog("🔍 App started successfully")
        
        // Initialize ModelManager to ensure models are discovered at startup
        DispatchQueue.main.async {
            let _ = ModelManager.shared
        }
        
        let successMessage = "🔍 App started successfully at \(timestamp)\n"
        try? successMessage.write(to: logFile, atomically: false, encoding: .utf8)
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    NSLog("🔍 MainView appeared!")
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
}
