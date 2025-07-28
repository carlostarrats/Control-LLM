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
        // Register custom fonts
        registerCustomFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
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
