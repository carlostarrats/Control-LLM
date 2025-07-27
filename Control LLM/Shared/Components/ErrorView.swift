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
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let retryAction = retryAction {
                Button("Retry") {
                    retryAction()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    ErrorView(
        title: "Connection Error",
        message: "Unable to connect to the server. Please check your internet connection and try again.",
        retryAction: { print("Retry tapped") }
    )
} 
