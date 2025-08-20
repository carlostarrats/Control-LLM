import SwiftUI

struct OnboardingModal: View {
    @Binding var isPresented: Bool
    @State private var headerOpacity: Double = 1.0
    @State private var blinkTimer: Timer?
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        NSLog("🔍 OnboardingModal init called")
    }
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            // Modal content
            VStack(spacing: 0) {
                // Close button (X) in top-right corner
                HStack {
                    Spacer()
                    Button(action: {
                        // Mark onboarding as seen and close
                        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(hex: "#141414"))
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
                
                Spacer()
                
                // Content container - all text as a group with 80px spacing
                VStack(spacing: 80) {
                    // Header: "INSTRUCTION:" with blinking effect
                    Text("INSTRUCTION:")
                        .font(.custom("IBMPlexMono", size: 15))
                        .foregroundColor(headerOpacity > 0.5 ? ColorManager.shared.orangeColor : Color(hex: "#141414"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                                                                .onAppear {
                                            // Start blinking animation - 1.5 seconds on each color, instant transitions
                                            blinkTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                                                headerOpacity = headerOpacity > 0.5 ? 0.0 : 1.0
                                            }
                                        }
                        .onDisappear {
                            blinkTimer?.invalidate()
                            blinkTimer = nil
                        }
                    
                    Text("Swipe Left")
                        .font(.custom("IBMPlexMono", size: 15))
                        .foregroundColor(Color(hex: "#141414"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("Swipe Right")
                        .font(.custom("IBMPlexMono", size: 15))
                        .foregroundColor(Color(hex: "#141414"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("Read FAQs")
                        .font(.custom("IBMPlexMono", size: 15))
                        .foregroundColor(Color(hex: "#141414"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .frame(width: 350, height: 600)
            .background(ColorManager.shared.redColor)
            .cornerRadius(4)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
}

#Preview {
    OnboardingModal(isPresented: .constant(true))
        .environmentObject(ColorManager.shared)
}
