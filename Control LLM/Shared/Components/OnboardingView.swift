import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentScreen = 0
    @EnvironmentObject var colorManager: ColorManager
    
    private let totalScreens = 2
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()
            
            if currentScreen == 0 {
                DisclaimerScreen(
                    onNext: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = 1
                        }
                    }
                )
            } else {
                ModelsScreen(
                    onNext: {
                        completeOnboarding()
                    }
                )
            }
        }
    }
    
    private func completeOnboarding() {
        // Mark onboarding as seen
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        isPresented = false
    }
}

// MARK: - Screen 1: Disclaimer
struct DisclaimerScreen: View {
    let onNext: () -> Void
    @EnvironmentObject var colorManager: ColorManager
    @State private var isBlinking = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Content container - fixed width
            VStack(spacing: 0) {
                // Disclaimer heading - 70pts from top
                HStack {
                    Text(NSLocalizedString("DISCLAIMER", comment: ""))
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(ColorManager.shared.redColor)
                        .opacity(isBlinking ? 0.3 : 1.0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                isBlinking = true
                            }
                        }
                    Spacer()
                }
                .padding(.top, 70)
                
                Spacer()
                    .frame(height: 150) // 150pts space
                
                // Disclaimer text - blue body text
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("This app uses AI models that", comment: ""))
                    Text(NSLocalizedString("may generate incorrect,", comment: ""))
                    Text(NSLocalizedString("inappropriate, or misleading", comment: ""))
                    Text(NSLocalizedString("content. Do not rely on AI-", comment: ""))
                    Text(NSLocalizedString("generated content for legal,", comment: ""))
                    Text(NSLocalizedString("financial, or medical advice.", comment: ""))
                    Text(NSLocalizedString("This software is provided \"as", comment: ""))
                    Text(NSLocalizedString("is\" without warranties. For", comment: ""))
                    Text(NSLocalizedString("personal use only.", comment: ""))
                }
                .font(.custom("IBMPlexMono", size: 16))
                .foregroundColor(Color(hex: "#94A8E1")) // Blue color
                .multilineTextAlignment(.leading)
                
                Spacer()
                    .frame(height: 40) // 40pts space
                
                // Green text
                Text(NSLocalizedString("This app stores all data on your device only - nothing is saved or shared, and no account exists.", comment: ""))
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#3EBBA5")) // Green color
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // I Understand button - keep at same exact spot
                Button(action: onNext) {
                    Text(NSLocalizedString("I Understand", comment: ""))
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(Color(hex: "#F8C762")) // Specific orange
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#F8C762").opacity(0.1)) // 10% orange fill
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "#F8C762"), lineWidth: 1) // 1px orange stroke
                        )
                        .cornerRadius(4)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 40)
            }
            .frame(width: 280) // Fixed width based on body copy
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

// MARK: - Screen 2: Models Selection
struct ModelsScreen: View {
    let onNext: () -> Void
    @EnvironmentObject var colorManager: ColorManager
    @StateObject private var modelManager = ModelManager.shared
    @State private var selectedModelsToDownload: Set<String> = []
    @State private var downloadingModel: String? = nil
    @State private var downloadProgress: Double = 0.0
    @State private var showingUnusedModelsSheet = false
    @State private var selectedUnusedModels: Set<String> = []
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 8) {
                    // Add small top padding to align with other settings pages
                    Spacer()
                        .frame(height: 5)
                    
                    // Available Downloads section
                    VStack(alignment: .leading, spacing: 4) {
                        Text(NSLocalizedString("AVAILABLE DOWNLOADS", comment: ""))
                            .font(.custom("IBMPlexMono", size: 12))
                            .foregroundColor(colorManager.orangeColor)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 0) {
                            if availableDownloadModels.isEmpty {
                                // Show "Already Installed" when no downloads available
                                HStack {
                                    Text(NSLocalizedString("All Available Installed", comment: ""))
                                        .font(.custom("IBMPlexMono", size: 16))
                                        .foregroundColor(Color(hex: "#666666"))
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 4)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Horizontal line under the item
                                Rectangle()
                                    .fill(Color(hex: "#333333"))
                                    .frame(height: 1)
                            } else {
                                ForEach(availableDownloadModels, id: \.filename) { model in
                                    AvailableDownloadModelView(
                                        model: model,
                                        isDownloading: downloadingModel == model.filename,
                                        downloadProgress: downloadProgress,
                                        onDownload: {
                                            if downloadingModel == model.filename {
                                                // Stop download
                                                downloadingModel = nil
                                                downloadProgress = 0.0
                                            } else if downloadingModel == nil {
                                                // Start download
                                                downloadingModel = model.filename
                                                downloadProgress = 0.0
                                                
                                                // Simulate download progress
                                                simulateDownload(for: model.filename)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                
                // 30px spacing between sections
                Spacer()
                    .frame(height: 30)
                
                // 30px spacing from Available Downloads section
                Spacer()
                    .frame(height: 30)
                
                // Begin button instead of Manage Unused Models
                Button(action: onNext) {
                    Text(NSLocalizedString("Begin...", comment: ""))
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(Color(hex: "#F8C762"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#F8C762").opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "#F8C762"), lineWidth: 1)
                        )
                        .cornerRadius(4)
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 280) // Fixed width to match "I Understand" button
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 40)
            }
        }
            .safeAreaInset(edge: .top) {
                // Header
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "terminal")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(ColorManager.shared.purpleColor)
                            
                            Text(NSLocalizedString("MODELS", comment: ""))
                                .font(.custom("IBMPlexMono", size: 12))
                                .foregroundColor(ColorManager.shared.purpleColor)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()

                        Button(action: onNext) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(ColorManager.shared.orangeColor)
                                .frame(width: 20, height: 20)
                                .contentShape(Rectangle())
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, 10)
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
    }
    
    private var availableDownloadModels: [LLMModelInfo] {
        // For now, show no available downloads since all models are installed
        // This will be updated when actual download functionality is implemented
        return []
    }
    
    private var unusedModelsCount: Int {
        modelManager.availableModels.filter { $0.filename != (modelManager.selectedModel?.filename ?? "") }.count
    }
    
    private func simulateDownload(for modelName: String) {
        // Simulate download progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            downloadProgress += 0.1
            if downloadProgress >= 1.0 {
                timer.invalidate()
                downloadingModel = nil
                downloadProgress = 0.0
            }
        }
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
        .environmentObject(ColorManager.shared)
}
