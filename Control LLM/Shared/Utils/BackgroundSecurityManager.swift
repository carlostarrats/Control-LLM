//
//  BackgroundSecurityManager.swift
//  Control LLM
//
//  Background security manager for hiding sensitive content when app backgrounds
//

import Foundation
import SwiftUI
import UIKit

/// Manages background security by hiding sensitive content when app backgrounds
class BackgroundSecurityManager: ObservableObject {
    static let shared = BackgroundSecurityManager()
    
    @Published var isAppInBackground = false
    @Published var shouldHideSensitiveContent = false
    
    private var blurEffectView: UIVisualEffectView?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    private init() {
        setupNotifications()
    }
    
    deinit {
        removeNotifications()
    }
    
    // MARK: - Notification Setup
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    private func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Background Handling
    
    @objc private func appDidEnterBackground() {
        debugPrint("BackgroundSecurityManager: App entered background - hiding sensitive content", category: .security)
        
        isAppInBackground = true
        shouldHideSensitiveContent = true
        
        // Start background task to ensure we have time to hide content
        startBackgroundTask()
        
        // Hide sensitive content immediately
        hideSensitiveContent()
        
        // Log security event
        SecureLogger.log("App entered background - sensitive content hidden")
    }
    
    @objc private func appWillEnterForeground() {
        debugPrint("BackgroundSecurityManager: App will enter foreground - preparing to show content", category: .security)
        
        // End background task
        endBackgroundTask()
    }
    
    @objc private func appDidBecomeActive() {
        debugPrint("BackgroundSecurityManager: App became active - showing sensitive content", category: .security)
        
        isAppInBackground = false
        shouldHideSensitiveContent = false
        
        // Show sensitive content
        showSensitiveContent()
        
        // Log security event
        SecureLogger.log("App became active - sensitive content shown")
    }
    
    @objc private func appWillResignActive() {
        debugPrint("BackgroundSecurityManager: App will resign active - preparing to hide content", category: .security)
        
        // Don't hide immediately on resign active, only on background
        // This prevents hiding content when user pulls down notification center
    }
    
    // MARK: - Background Task Management
    
    private func startBackgroundTask() {
        endBackgroundTask() // End any existing task
        
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "HideSensitiveContent") {
            // This block is called when the background task is about to expire
            print("🔒 BackgroundSecurityManager: Background task expiring - ensuring content is hidden")
            self.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
    
    // MARK: - Content Hiding/Showing
    
    private func hideSensitiveContent() {
        DispatchQueue.main.async {
            // Post notification for views to hide sensitive content
            NotificationCenter.default.post(name: .hideSensitiveContent, object: nil)
        }
    }
    
    private func showSensitiveContent() {
        DispatchQueue.main.async {
            // Post notification for views to show sensitive content
            NotificationCenter.default.post(name: .showSensitiveContent, object: nil)
        }
    }
    
    // MARK: - Manual Control
    
    /// Manually hide sensitive content (for testing or special cases)
    func manuallyHideSensitiveContent() {
        shouldHideSensitiveContent = true
        hideSensitiveContent()
    }
    
    /// Manually show sensitive content (for testing or special cases)
    func manuallyShowSensitiveContent() {
        shouldHideSensitiveContent = false
        showSensitiveContent()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let hideSensitiveContent = Notification.Name("hideSensitiveContent")
    static let showSensitiveContent = Notification.Name("showSensitiveContent")
}

// MARK: - SwiftUI Background Security View

struct BackgroundSecurityView<Content: View>: View {
    let content: Content
    @StateObject private var securityManager = BackgroundSecurityManager.shared
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Main content
            content
                .opacity(securityManager.shouldHideSensitiveContent ? 0 : 1)
                .animation(.easeInOut(duration: 0.3), value: securityManager.shouldHideSensitiveContent)
            
            // Blur overlay when content is hidden
            if securityManager.shouldHideSensitiveContent {
                BlurOverlayView()
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: securityManager.shouldHideSensitiveContent)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .hideSensitiveContent)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                securityManager.shouldHideSensitiveContent = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showSensitiveContent)) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                securityManager.shouldHideSensitiveContent = false
            }
        }
    }
}

// MARK: - Blur Overlay View

struct BlurOverlayView: View {
    var body: some View {
        ZStack {
            // Background color
            Color.black.opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App icon or logo
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundColor(.primary)
                    .opacity(0.7)
                
                // App name
                Text("Control LLM")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .opacity(0.8)
                
                // Security message
                Text("Tap to continue")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .opacity(0.6)
            }
        }
        .background(
            // Blur effect
            VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
                .ignoresSafeArea()
        )
    }
}

// MARK: - Visual Effect View

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView()
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

// MARK: - Background Security Modifier

struct BackgroundSecurityModifier: ViewModifier {
    @StateObject private var securityManager = BackgroundSecurityManager.shared
    
    func body(content: Content) -> some View {
        content
            .opacity(securityManager.shouldHideSensitiveContent ? 0 : 1)
            .animation(.easeInOut(duration: 0.3), value: securityManager.shouldHideSensitiveContent)
            .overlay(
                Group {
                    if securityManager.shouldHideSensitiveContent {
                        BlurOverlayView()
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: securityManager.shouldHideSensitiveContent)
                    }
                }
            )
    }
}

// MARK: - View Extension

extension View {
    /// Adds background security to hide sensitive content when app backgrounds
    func backgroundSecurity() -> some View {
        self.modifier(BackgroundSecurityModifier())
    }
}
