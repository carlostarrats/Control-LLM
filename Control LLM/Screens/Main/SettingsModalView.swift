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
                // Full background gradient
                LinearGradient(
                    colors: [Color(hex: "#1D1D1D"), Color(hex: "#141414")],
                    startPoint: .top, endPoint: .bottom
                )
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
                    // Header with grabber and text
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(colorManager.greenColor)
                            .frame(width: 36, height: 5)
                            .padding(.top, 8).padding(.bottom, 6)

                        HStack(spacing: 0) {
                            Text("SWIPE UP FOR SETTINGS")
                                .font(.custom("IBMPlexMono", size: 12))
                                .foregroundColor(Color(hex: "#141414"))
                                .padding(.leading, 0)
                            
                            Spacer()
                            
                            Image(systemName: isSheetExpanded ? "arrow.down" : "arrow.up")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "#141414"))
                                .padding(.trailing, 0)
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
