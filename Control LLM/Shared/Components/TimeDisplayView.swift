import SwiftUI

struct TimeDisplayView: View {
    @State private var currentTime = Date()
    @State private var timeUpdateTimer: Timer?
    
    var body: some View {
        Text(timeString)
            .font(.custom("IBMPlexMono-Bold", size: 48))
            .foregroundColor(Color(hex: "#666666"))
            .multilineTextAlignment(.center)
            .onAppear {
                startTimeUpdates()
            }
            .onDisappear {
                stopTimeUpdates()
            }
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: currentTime)
    }
    
    private func startTimeUpdates() {
        // Update time immediately
        currentTime = Date()
        
        // Update every second
        timeUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            currentTime = Date()
        }
    }
    
    private func stopTimeUpdates() {
        timeUpdateTimer?.invalidate()
        timeUpdateTimer = nil
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Time Display Preview")
            .foregroundColor(.white)
            .font(.title2)
            .padding()
        
        TimeDisplayView()
            .frame(width: 300, height: 100)
            .background(Color.black)
    }
    .background(Color.black)
}
