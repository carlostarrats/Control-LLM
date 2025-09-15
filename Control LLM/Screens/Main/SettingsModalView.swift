import SwiftUI
import UIKit
import UniformTypeIdentifiers
import Lottie

struct SettingsModalView: View {
    @Binding var isPresented: Bool
    @Binding var isSheetExpanded: Bool
    @EnvironmentObject var colorManager: ColorManager
    @ObservedObject var mainViewModel: MainViewModel
    
    // Sheet state variables for settings sub-sheets
    @State private var showingModels = false
    @State private var showingAppearance = false
    @State private var showingFAQ = false
    @State private var showingCredits = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background gradient when expanded, transparent when collapsed
                if isSheetExpanded {
                    LinearGradient(
                        colors: [Color(hex: "#1D1D1D"), Color(hex: "#141414")],
                        startPoint: .top, endPoint: .bottom
                    )
                    .ignoresSafeArea(.all)
                } else {
                    Color.clear
                    .ignoresSafeArea(.all)
                }
                
                // Red gradient overlay - extends from top to bottom of screen
                VStack(spacing: 0) {
                    // Gradient that extends from the top of the screen down to the bottom
                    LinearGradient(
                        colors: [
                            colorManager.redColor.opacity(isSheetExpanded ? 0.0 : 1.0), 
                            colorManager.redColor.opacity(isSheetExpanded ? 0.0 : 1.0)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(maxHeight: .infinity) // Extend to full height
                    .allowsHitTesting(false)
                }
                .allowsHitTesting(false)
                
                // Content layer
                VStack(spacing: 0) {
                    // Header with close button - transparent background to allow gradient through
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(isSheetExpanded ? colorManager.redColor : Color(hex: "#141414"))
                                .padding(.trailing, 6)
                            
                            Text(NSLocalizedString("SETTINGS", comment: ""))
                                .font(.custom("IBMPlexMono", size: 12))
                                .foregroundColor(settingsHeaderTextColor)
                                .padding(.leading, 0)
                            
                            Spacer()
                            
                            // Cursor rays when collapsed, X when expanded
                            if isSheetExpanded {
                                Button(action: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        isSheetExpanded = false
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(colorManager.orangeColor)
                                        .frame(width: 20, height: 20)
                                        .contentShape(Rectangle())
                                        .frame(width: 44, height: 44)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.trailing, 0)
                            } else {
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(hex: "#141414"))
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 0)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, isSheetExpanded ? 0 : 14)
                    .padding(.bottom, 10)
                    .background(Color.clear) // Make header background transparent
                    
                    // Settings content - only show when expanded
                    if isSheetExpanded {
                        ScrollView {
                            VStack(spacing: 8) {
                                // Settings list
                                VStack(spacing: 0) {
                                    ForEach(settingsItems, id: \.title) { item in
                                        SettingsItemView(item: item)
                                    }
                                }
                                .padding(.top, 0)
                                .padding(.horizontal, 20)
                                
                                // System Information Section
                                SystemInfoView(mainViewModel: mainViewModel)
                                    .padding(.horizontal, 20)
                                    .padding(.top, 40)
                                    .padding(.bottom, 60)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 20)
        }
    }
        .fullScreenCover(isPresented: $showingModels) {
            SettingsModelsView()
        }
        .fullScreenCover(isPresented: $showingAppearance) {
            AppearanceView()
        }
        .fullScreenCover(isPresented: $showingFAQ) {
            FAQView()
        }
        .fullScreenCover(isPresented: $showingCredits) {
            CreditsView()
        }
    }
    
    // Computed property to break up complex expressions
    private var settingsHeaderTextColor: Color {
        isSheetExpanded ? colorManager.redColor : Color(hex: "#141414")
    }
    
    private var settingsItems: [SettingsItem] {
        [
            SettingsItem(title: NSLocalizedString("Models", comment: ""), symbol: "terminal", action: { showingModels = true }),
            SettingsItem(title: NSLocalizedString("Appearance", comment: ""), symbol: "eye", action: { showingAppearance = true }),
            SettingsItem(title: NSLocalizedString("FAQ", comment: ""), symbol: "questionmark.circle", action: { showingFAQ = true }),
            SettingsItem(title: NSLocalizedString("Credits", comment: ""), symbol: "text.page", action: { showingCredits = true })
        ]
    }
}

// SettingsItem, SettingsItemView, and SystemInfoView are imported from SettingsView.swift

#Preview {
    SettingsModalView(isPresented: .constant(true), isSheetExpanded: .constant(false), mainViewModel: MainViewModel())
        .preferredColorScheme(.dark)
}
