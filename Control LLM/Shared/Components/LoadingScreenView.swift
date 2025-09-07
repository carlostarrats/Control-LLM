import SwiftUI

struct LoadingScreenView: View {
    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background color FF6B6B (coral red) - fill entire screen
            Color(hex: "#FF6B6B")
                .ignoresSafeArea(.all)
                .onAppear {
                    NSLog("🔍 LoadingScreenView body appeared!")
                }
            
            ZStack {
                // Logo container that can expand beyond bounds
                ZStack {
                    Image("load_logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                }
                .scaleEffect(logoScale, anchor: .center)
                .opacity(logoOpacity)
                .allowsHitTesting(false)
                    .onAppear {
                        // Step 1: Red page loads first (already showing)
                        
                        // Step 2: Logo and text quickly fade in together
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    withAnimation(.easeOut(duration: 0.6)) {
                                        logoScale = 1.0 // Scale to 1.0 with ease out
                                        logoOpacity = 1.0
                                        textOpacity = 1.0
                                    }
                                    
                                    // Step 3: Logo contracts 10% with ease in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation(.easeIn(duration: 0.3)) {
                                            logoScale = 0.6 // 40% contraction from 1.0 (1.0 * 0.6 = 0.6)
                                        }
                                        
                                        // Step 4: Logo expands completely with ease out
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            NSLog("🔍 Logo starting expansion animation")
                                            withAnimation(.easeOut(duration: 0.1)) {
                                                logoScale = 6.0 // Much larger than screen
                                            }
                                        }
                                    }
                                }
                            }
                
                // "CONTROL" text at the bottom
                VStack {
                    Spacer()
                    Text("CONTROL")
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(Color(hex: "#141414")) // Color as requested by user
                        .opacity(textOpacity)
                        .padding(.bottom, 56) // 40pt (button bottom) + 16pt (button vertical padding) = 56pt
                }
            }
        }
    }
}

#Preview {
    LoadingScreenView()
}
