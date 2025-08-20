import SwiftUI

struct LoadingView: View {
    let message: String
    
    init(_ message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        ZStack {
            // Background gradient - matches main app design
            LinearGradient(
                colors: [
                    Color(hex: "#1D1D1D"),  // Lighter color at top
                    Color(hex: "#141414")   // Darker color at bottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(ColorManager.shared.whiteTextColor)
                
                Text(message)
                    .font(.custom("IBMPlexMono-Regular", size: 16))
                    .foregroundColor(ColorManager.shared.whiteTextColor)
            }
        }
    }
}

#Preview {
    LoadingView("Processing your request...")
} 