import SwiftUI

struct CreditsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with grabber
                VStack(spacing: 0) {
                    // Enhanced grab bar with larger invisible touch area
                    RoundedRectangle(cornerRadius: 3)
                        .fill(ColorManager.shared.greenColor)
                        .frame(width: 50, height: 6)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                        .contentShape(Rectangle())
                        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 80, height: UIDevice.current.userInterfaceIdiom == .pad ? 50 : 40)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // Visual feedback during drag
                                }
                                .onEnded { value in
                                    // More sensitive dismissal - reduce threshold
                                    if value.translation.height > 20 {
                                        dismiss()
                                    }
                                }
                        )
                    
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "text.page")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(ColorManager.shared.purpleColor)
                            
                            Text(NSLocalizedString("CREDITS", comment: ""))
                                .font(.custom("IBMPlexMono", size: 12))
                                .foregroundColor(ColorManager.shared.purpleColor)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()

                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(ColorManager.shared.orangeColor)
                                .frame(width: 20, height: 20)
                                .contentShape(Rectangle())
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, 10)
                }
                .background(Color(hex: "#1D1D1D"))
                
                // Scrollable content
                ScrollView {
                    VStack(spacing: 8) {
                        // Credits list
                        VStack(spacing: 0) {
                            ForEach(creditsItems, id: \.title) { item in
                                CreditsItemView(item: item)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 10)
                }
                .background(Color(hex: "#1D1D1D"))
            }
            .background(Color(hex: "#1D1D1D"))
        }
    }
    
    private var creditsItems: [CreditsItem] {
        [
            CreditsItem(title: "Gemma 3", url: "https://huggingface.co/unsloth/gemma-3-1b-it-GGUF"),
            CreditsItem(title: "IBM Plex Mono", url: "https://github.com/IBM/plex?tab=readme-ov-file"),
            CreditsItem(title: "LLaMA.cpp", url: "https://github.com/ggml-org/llama.cpp"),
            CreditsItem(title: "Liquid", url: "https://github.com/maustinstar/liquid"),
            CreditsItem(title: "Llama 3.2", url: "https://huggingface.co/unsloth/Llama-3.2-1B-Instruct-GGUF"),
            CreditsItem(title: "Qwen 3", url: "https://huggingface.co/unsloth/Qwen3-1.7B-GGUF"),
            CreditsItem(title: "SmolLM2", url: "https://huggingface.co/HuggingFaceTB/SmolLM2-1.7B-Instruct-GGUF")
        ]
    }
}

struct CreditsItem: Identifiable {
    let id = UUID()
    let title: String
    let url: String?
}

struct CreditsItemView: View {
    let item: CreditsItem
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                if let url = item.url, let urlObject = URL(string: url) {
                    UIApplication.shared.open(urlObject)
                }
            }) {
                HStack {
                    Text(item.title)
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(ColorManager.shared.whiteTextColor)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ColorManager.shared.whiteTextColor)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            
            // Horizontal line under the item
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(height: 1)
        }
    }
} 