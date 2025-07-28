import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var showingTextModal = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "#141414"),
                    Color(hex: "#2A2A2A")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top navigation buttons
                HStack {
                    NavigationButton(title: "History") {
                        print("History tapped")
                    }
                    
                    Spacer()
                    
                    NavigationButton(title: "Model") {
                        print("Model tapped")
                    }
                    
                    Spacer()
                    
                    NavigationButton(title: "Setting") {
                        print("Setting tapped")
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                Spacer()
                
                                        // Central visual design element
                        CentralVisualizerView(isSpeaking: $viewModel.isSpeaking)
                            .frame(width: 253, height: 253)
                            .onTapGesture {
                                viewModel.toggleRecording()
                            }
                            .accessibilityLabel("Voice recording button")
                            .accessibilityHint("Double tap to start or stop voice recording")
                
                Spacer()
                
                // Bottom manual input button
                VStack(spacing: 0) {
                    // Dashed line above the text
                    DashedLineAboveText(text: "Manual Input")
                        .padding(.bottom, 8) // 8px spacing above text
                    
                    Button(action: {
                        showingTextModal = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "keyboard")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "#B3B3B3"))
                            
                            Text("Manual Input")
                                .font(.system(size: 16, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(hex: "#B3B3B3"))
                                .lineSpacing(8) // 24px - 16px = 8px line spacing
                                .tracking(0)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("Manual Input")
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.1), value: true)
                }
                .padding(.bottom, 50)
                .frame(maxWidth: .infinity) // Ensure full width for centering
            }
        }
        .sheet(isPresented: $showingTextModal) {
            TextModalView(viewModel: viewModel, isPresented: $showingTextModal)
        }
        
    }
}

struct NavigationButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(Color(hex: "#B3B3B3"))
                .lineSpacing(8) // 24px - 16px = 8px line spacing
                .tracking(0)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(title)
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: true)
    }
}

struct DashedLineAboveText: View {
    let text: String
    
    var body: some View {
        // Calculate total width including icon and spacing
        let iconWidth: CGFloat = 14 // keyboard icon width
        let spacing: CGFloat = 8 // spacing between icon and text
        let extraPadding: CGFloat = 6 // small extra padding for visual balance
        let textWidth = textWidth(for: text)
        let totalWidth = iconWidth + spacing + textWidth + extraPadding
        
        let dashLength: CGFloat = 4
        let gapLength: CGFloat = 2
        let totalPatternLength = dashLength + gapLength
        
        // Calculate how many complete patterns fit within the total width
        let completePatterns = Int(totalWidth / totalPatternLength)
        let remainingWidth = totalWidth - CGFloat(completePatterns) * totalPatternLength
        
        Path { path in
            var currentX: CGFloat = 0
            
            // Draw complete patterns
            for _ in 0..<completePatterns {
                path.move(to: CGPoint(x: currentX, y: 0))
                path.addLine(to: CGPoint(x: currentX + dashLength, y: 0))
                currentX += totalPatternLength
            }
            
            // If there's enough remaining space for a full dash, add it
            if remainingWidth >= dashLength {
                path.move(to: CGPoint(x: currentX, y: 0))
                path.addLine(to: CGPoint(x: currentX + dashLength, y: 0))
            }
        }
        .stroke(Color(hex: "#B3B3B3"), lineWidth: 1)
        .frame(width: totalWidth, height: 1)
        .frame(maxWidth: .infinity, alignment: .center) // Center the dashed line
    }
    
    private func textWidth(for text: String) -> CGFloat {
        let font = UIFont.monospacedSystemFont(ofSize: 16, weight: .medium)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (text as NSString).size(withAttributes: attributes)
        return size.width
    }
}







#Preview {
    MainView()
        .preferredColorScheme(.dark)
} 