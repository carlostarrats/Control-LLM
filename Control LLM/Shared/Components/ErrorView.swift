import SwiftUI

struct ErrorView: View {
    let title: String
    let message: String
    let retryAction: (() -> Void)?
    
    init(title: String = "Error", message: String, retryAction: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.retryAction = retryAction
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
            
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(Color(hex: "#F8C762"))
                
                Text(title)
                    .font(.custom("IBMPlexMono-Medium", size: 18))
                    .foregroundColor(Color(hex: "#EEEEEE"))
                
                Text(message)
                    .font(.custom("IBMPlexMono-Regular", size: 16))
                    .foregroundColor(Color(hex: "#EEEEEE"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if let retryAction = retryAction {
                    Button("Retry") {
                        retryAction()
                    }
                    .font(.custom("IBMPlexMono-Medium", size: 16))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(4)
                }
            }
        }
    }
}

#Preview {
    ErrorView(
        title: "Connection Error",
        message: "Unable to connect to the server. Please check your internet connection and try again.",
        retryAction: { print("Retry tapped") }
    )
} 
