import SwiftUI

struct SettingsView: View {
    @Binding var showingTextModal: Bool
    @ObservedObject var mainViewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Sheet state variables
    @State private var showingModels = false
    @State private var showingAgents = false
    @State private var showingAppearance = false
    @State private var showingVoice = false
    @State private var showingLanguage = false

    @State private var showingHistory = false
    @State private var showingCredits = false
    
    // Toast state
    @State private var showingToast = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "#1D1D1D"),  // Lighter color at top
                    Color(hex: "#141414")   // Darker color at bottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                // Scrollable content
                ScrollView {
                    VStack(spacing: 8) { // Reduced to 8 to move content up
                        // Settings list
                        VStack(spacing: 0) {
                            ForEach(settingsItems, id: \.title) { item in
                                SettingsItemView(item: item)
                            }
                        }
                        .padding(.top, 0) // Removed negative padding
                        .padding(.horizontal, 20)
                        
                        // Footer section
                        VStack(spacing: 4) {
                            Text("V 1.0")
                                .font(.custom("IBMPlexMono", size: 14))
                                .foregroundColor(Color(hex: "#666666"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                            
                            Text("Made by Control.Design")
                                .font(.custom("IBMPlexMono", size: 14))
                                .foregroundColor(Color(hex: "#666666"))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                }
                
                Spacer()
                
                // Privacy notice text
                Text("This app stores all data on your device only — nothing is saved or shared, and no account exists. To remove all data, delete the app.")
                    .font(.custom("IBMPlexMono", size: 12))
                    .foregroundColor(Color(hex: "#666666"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
            .safeAreaInset(edge: .top) {
                // iOS standard header overlay
                VStack(spacing: 0) {
                    // Grab bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(hex: "#666666"))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                            
                            Text("Settings")
                                .font(.custom("IBMPlexMono", size: 20))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                        }
                        .padding(.leading, 20)
                        
                        Spacer()

                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 20)
                    }
                    
                    // Buffer space below header
                    Spacer()
                        .frame(height: 18) // Changed from 16 to 18
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
        .sheet(isPresented: $showingModels) {
            SettingsModelsView()
        }
        .sheet(isPresented: $showingAgents) {
            AgentsView()
        }
        .sheet(isPresented: $showingAppearance) {
            AppearanceView()
        }
        .sheet(isPresented: $showingVoice) {
            VoiceView()
        }
        .sheet(isPresented: $showingLanguage) {
            LanguageView()
        }

        .sheet(isPresented: $showingHistory) {
            SettingsHistoryView(onHistoryDeleted: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showingToast = true
                    }
                }
            })
        }
        .sheet(isPresented: $showingCredits) {
            CreditsView()
        }
        .overlay {
            if showingToast {
                ToastView(message: "History Deleted")
                    .transition(.asymmetric(
                        insertion: AnyTransition.offset(y: 20).combined(with: .opacity),
                        removal: AnyTransition.offset(y: 20).combined(with: .opacity)
                    ))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                showingToast = false
                            }
                        }
                    }
            }
        }
    }
    
    private var settingsItems: [SettingsItem] {
        [
            SettingsItem(title: "Models", symbol: "terminal", action: { showingModels = true }),
            SettingsItem(title: "Agents", symbol: "square.3.layers.3d", action: { showingAgents = true }),
            SettingsItem(title: "Appearance", symbol: "paintbrush.pointed", action: { showingAppearance = true }),
            SettingsItem(title: "Voice", symbol: "bubble.left", action: { showingVoice = true }),
            SettingsItem(title: "Language", symbol: "globe", action: { showingLanguage = true }),

            SettingsItem(title: "Chat History", symbol: "list.bullet", action: { showingHistory = true }),
            SettingsItem(title: "Credits", symbol: "text.page", action: { showingCredits = true })
        ]
    }
}

struct SettingsItem: Identifiable {
    let id = UUID()
    let title: String
    let symbol: String
    let action: () -> Void
}

struct SettingsItemView: View {
    let item: SettingsItem
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: item.action) {
                HStack {
                    Image(systemName: item.symbol)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        // Show language with current selection on same line
                        if item.title == "Language" {
                            HStack(spacing: 4) {
                                Text(item.title)
                                    .font(.custom("IBMPlexMono", size: 16))
                                    .foregroundColor(Color(hex: "#EEEEEE"))
                                
                                Text(":")
                                    .font(.custom("IBMPlexMono", size: 16))
                                    .foregroundColor(Color(hex: "#EEEEEE"))
                                
                                Text(LanguageService.shared.selectedLanguage)
                                    .font(.custom("IBMPlexMono", size: 16))
                                    .foregroundColor(Color(hex: "#666666"))
                            }

                        } else {
                            Text(item.title)
                                .font(.custom("IBMPlexMono", size: 16))
                                .foregroundColor(Color(hex: "#EEEEEE"))
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            
            // Horizontal line under each item
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(height: 1)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ToastView: View {
    let message: String
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 12) {
                // Checkmark icon
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(hex: "#1D1D1D"))
                
                // Message text
                Text(message)
                    .font(.custom("IBMPlexMono", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "#1D1D1D"))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                Color(hex: "#FF6B6B")
                    .opacity(0.9)
            )
            .cornerRadius(4)
            .padding(.horizontal, 40)
            .padding(.bottom, 100)
        }
        .transition(.asymmetric(
            insertion: AnyTransition.offset(y: 20).combined(with: .opacity),
            removal: AnyTransition.offset(y: 20).combined(with: .opacity)
        ))
        .animation(.easeInOut(duration: 0.5), value: true)
    }
} 