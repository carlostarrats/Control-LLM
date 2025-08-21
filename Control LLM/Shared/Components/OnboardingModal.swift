import SwiftUI

struct OnboardingModal: View {
    @Binding var isPresented: Bool
    
    // Typewriter animation state
    @State private var currentWordIndex: Int = 0
    @State private var currentCharIndex: Int = 0
    @State private var typewriterTimer: Timer?
    @State private var charDelay: Double = 0.1 // Delay between each character
    @State private var wordDelay: Double = 0.8 // Delay between words
    @State private var animationStarted: Bool = false
    
    // Words to animate in diagonal pattern
    private let words = ["INSTRUCTION:", "Swipe Left", "Swipe Right", "Read FAQs"]
    
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
                
                // Content container with diagonal word animation
                ZStack {
                    // Background for the words area
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 270, height: 320) // Match the diagonal area
                    
                    // All words visible from start - just revealing whole words
                    ForEach(0..<words.count, id: \.self) { index in
                        Text(words[index])
                            .font(.custom("IBMPlexMono", size: 15))
                            .foregroundColor(Color(hex: "#141414")) // All text is now black
                            .multilineTextAlignment(.center)
                            .opacity((index == 0 || (animationStarted && index <= currentWordIndex)) ? 1.0 : 0.0)
                            .position(
                                x: index == 3 ? 240 : 40 + CGFloat(index) * 60, // "Read FAQs" positioned 20px from right edge
                                y: 40 + CGFloat(index) * 80   // Move down for each word
                            )
                    }
                }
                .frame(width: 270, height: 320)
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .frame(width: 350, height: 600)
            .background(ColorManager.shared.redColor)
            .cornerRadius(4)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        .onAppear {
            startTypewriterAnimation()
        }
        .onDisappear {
            stopTypewriterAnimation()
        }
    }
    
    // MARK: - Typewriter Animation
    
        private func startTypewriterAnimation() {
        // Reset animation state
        currentWordIndex = 0
        currentCharIndex = 0
        animationStarted = false

        // Start with 1.5 second delay before showing "Swipe Left"
        typewriterTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            self.animationStarted = true
            self.currentWordIndex = 1
            // Schedule next word after 0.8 seconds
            self.typewriterTimer?.invalidate()
            self.typewriterTimer = Timer.scheduledTimer(withTimeInterval: self.wordDelay, repeats: false) { _ in
                self.animateNextWord()
            }
        }
    }
    
        private func animateNextWord() {
        if currentWordIndex < words.count - 1 {
            // Move to next word
            currentWordIndex += 1

            // Use normal 0.8 second delay for subsequent words
            typewriterTimer?.invalidate()
            typewriterTimer = Timer.scheduledTimer(withTimeInterval: wordDelay, repeats: false) { _ in
                // Continue to next word
                self.animateNextWord()
            }
        } else {
            // Animation complete, stop timer
            stopTypewriterAnimation()
        }
    }
    
    private func stopTypewriterAnimation() {
        typewriterTimer?.invalidate()
        typewriterTimer = nil
    }
    
    // MARK: - Helper Functions
    
    private func isWordVisible(wordIndex: Int) -> Bool {
        return wordIndex <= currentWordIndex
    }
}

#Preview {
    OnboardingModal(isPresented: .constant(true))
        .environmentObject(ColorManager.shared)
}
