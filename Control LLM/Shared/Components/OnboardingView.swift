import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentScreen = 0
    @State private var showingModelsSheet = false
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
            } else if currentScreen == 1 {
                InstructionsScreen(
                    onNext: {
                        // Show models sheet
                        showingModelsSheet = true
                    },
                    onSkip: {
                        // Skip to main app
                        completeOnboarding()
                    },
                    onBack: {
                        // Go back to first screen
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = 0
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showingModelsSheet) {
            ModelsSheetView(
                isPresented: $showingModelsSheet,
                onComplete: {
                    completeOnboarding()
                }
            )
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
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 20) // Move everything down 20pt
            
            // Logo
            Image("onboarding_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .opacity(0.8)
                .padding(.top, 10) // Move logo down 10pt
            
            Spacer()
                .frame(height: 50) // Reduce spacer to compensate for logo padding
            
            // Disclaimer heading
            Text("DISCLAIMER")
                .font(.custom("IBMPlexMono", size: 16))
                .foregroundColor(ColorManager.shared.redColor)
            
            Spacer()
                .frame(height: 30)
            
            // Content container - fixed width
            VStack(spacing: 0) {
                // Disclaimer text
                VStack(alignment: .leading, spacing: 8) {
                    Text("This app uses AI models that")
                    Text("may generate incorrect,")
                    Text("inappropriate, or misleading")
                    Text("content. Do not rely on AI-")
                    Text("generated content for legal,")
                    Text("financial, or medical advice.")
                    Text("This software is provided \"as")
                    Text("is\" without warranties. For")
                    Text("personal use only.")
                }
                .font(.custom("IBMPlexMono", size: 16))
                .foregroundColor(Color(hex: "#94A8E1")) // Specific purple
                .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Page indicator
                HStack {
                    Text("1/2")
                        .font(.custom("IBMPlexMono", size: 14))
                        .foregroundColor(Color(hex: "#3EBBA5")) // Specific green
                    Spacer()
                }
                .padding(.bottom, 20)
                
                // I Understand button
                Button(action: onNext) {
                    Text("I Understand")
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
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

// MARK: - Screen 2: Instructions
struct InstructionsScreen: View {
    let onNext: () -> Void
    let onSkip: () -> Void
    let onBack: () -> Void
    @EnvironmentObject var colorManager: ColorManager
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 20) // Move everything down 20pt
            
            // Logo
            Image("onboarding_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .opacity(0.8)
                .padding(.top, 10) // Move logo down 10pt
            
            Spacer()
                .frame(height: 50) // Reduce spacer to compensate for logo padding
            
            // Instructions heading
            Text("INSTRUCTIONS")
                .font(.custom("IBMPlexMono", size: 16))
                .foregroundColor(ColorManager.shared.redColor)
            
            Spacer()
                .frame(height: 30)
            
            // Content container - fixed width
            VStack(spacing: 0) {
                // Instructions text
                VStack(alignment: .leading, spacing: 0) {
                    Text("1. Download a model")
                    
                    Spacer()
                        .frame(height: 30)
                    
                    Text("2. Tap for settings")
                    
                    Spacer()
                        .frame(height: 30)
                    
                    Text("3. Tap for chat")
                    
                    Spacer()
                        .frame(height: 20)
                    
                    Text("This app stores all data on your device only - nothing is saved or shared, and no account exists.")
                        .font(.custom("IBMPlexMono", size: 14))
                }
                .font(.custom("IBMPlexMono", size: 16))
                .foregroundColor(Color(hex: "#F8C762")) // Specific orange
                .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Page indicator
                HStack {
                    Text("2/2")
                        .font(.custom("IBMPlexMono", size: 14))
                        .foregroundColor(Color(hex: "#3EBBA5")) // Specific green
                    Spacer()
                }
                .padding(.bottom, 20)
                
                // Select Model button
                Button(action: onNext) {
                    Text("Select Model")
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(Color(hex: "#94A8E1")) // Specific purple
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#94A8E1").opacity(0.1)) // 10% purple fill
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(hex: "#94A8E1"), lineWidth: 1) // 1px purple stroke
                        )
                        .cornerRadius(4)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 40)
            }
            .frame(width: 280) // Fixed width based on body copy
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    // Only allow swipe right (back) gesture
                    if value.translation.width > 100 && abs(value.translation.height) < 100 {
                        onBack()
                    }
                }
        )
    }
}

// MARK: - Models Sheet
struct ModelsSheetView: View {
    @Binding var isPresented: Bool
    let onComplete: () -> Void
    @StateObject private var viewModel = ModelsViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 0) {
                    // Grab bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(hex: "#3EBBA5"))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
                    // Header content
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SELECT MODEL")
                                .font(.custom("IBMPlexMono-Bold", size: 18))
                                .foregroundColor(Color(hex: "#EEEEEE"))
                            
                            Text("Choose a model to get started")
                                .font(.custom("IBMPlexMono", size: 14))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            onComplete()
                        }) {
                            Text("Skip")
                                .font(.custom("IBMPlexMono-Medium", size: 16))
                                .foregroundColor(Color(hex: "#F8C762"))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(Color(hex: "#1D1D1D"))
                
                // Models list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.availableModels) { model in
                            OnboardingModelRow(
                                model: model,
                                isSelected: viewModel.selectedModel?.id == model.id
                            ) {
                                viewModel.selectModel(model)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .background(Color(hex: "#1D1D1D"))
                
                // Continue button
                VStack {
                    Button(action: {
                        onComplete()
                    }) {
                        Text("Continue")
                            .font(.custom("IBMPlexMono-Medium", size: 16))
                            .foregroundColor(Color(hex: "#EEEEEE"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#3EBBA5"))
                            .cornerRadius(4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(Color(hex: "#1D1D1D"))
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Onboarding Model Row for Sheet
struct OnboardingModelRow: View {
    let model: LLMModelInfo
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(model.name)
                            .font(.custom("IBMPlexMono-Medium", size: 16))
                            .foregroundColor(Color(hex: "#EEEEEE"))
                        Text("•")
                            .font(.custom("IBMPlexMono", size: 16))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                        Text(model.provider)
                            .font(.custom("IBMPlexMono", size: 14))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                    }
                    
                    Text(model.description)
                        .font(.custom("IBMPlexMono", size: 14))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                        .lineLimit(2)
                    
                    HStack {
                        Text(model.size)
                            .font(.custom("IBMPlexMono-Regular", size: 12))
                            .foregroundColor(Color(hex: "#94A8E1"))
                        Text("•")
                            .font(.custom("IBMPlexMono-Regular", size: 12))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                        Text("Available")
                            .font(.custom("IBMPlexMono-Regular", size: 12))
                            .foregroundColor(Color(hex: "#3EBBA5"))
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#3EBBA5"))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color(hex: "#2A2A2A") : Color(hex: "#1A1A1A"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color(hex: "#3EBBA5") : Color(hex: "#333333"), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
        .environmentObject(ColorManager.shared)
}
