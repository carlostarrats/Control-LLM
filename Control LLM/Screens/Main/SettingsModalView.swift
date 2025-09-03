import SwiftUI
import UIKit
import UniformTypeIdentifiers
import Lottie

struct SettingsModalView: View {
    @Binding var isPresented: Bool
    @Binding var isSheetExpanded: Bool
    @EnvironmentObject var colorManager: ColorManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Transparent background to allow color fading through
                Color.clear
                .ignoresSafeArea(.all)
                
                // Orange gradient overlay - extends from sheet to bottom of screen
                VStack(spacing: 0) {
                    // Gradient that extends from the sheet down to the bottom
                    LinearGradient(
                        colors: [
                            colorManager.orangeColor.opacity(isSheetExpanded ? 0.0 : 1.0), 
                            colorManager.orangeColor.opacity(isSheetExpanded ? 0.0 : 1.0)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(height: 600)
                    .allowsHitTesting(false)
                }
                .allowsHitTesting(false)
                
                // Content layer
                VStack(spacing: 0) {
                    // Header with text
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Text("SETTINGS")
                                .font(.custom("IBMPlexMono", size: 12))
                                .foregroundColor(isSheetExpanded ? colorManager.orangeColor : Color(hex: "#141414"))
                                .padding(.leading, 0)
                            
                            Spacer()
                            
                            // Close button - only show when expanded
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
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.trailing, 0)
                            }
                        }
                        .padding(.bottom, isSheetExpanded ? 18 : 10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, isSheetExpanded ? 0 : 14)
                    .padding(.bottom, 24)
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    SettingsModalView(isPresented: .constant(true), isSheetExpanded: .constant(false))
        .preferredColorScheme(.dark)
}
