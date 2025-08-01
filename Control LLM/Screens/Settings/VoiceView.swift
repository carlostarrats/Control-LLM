import SwiftUI

struct VoiceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedVoice: String = "Tom" // Default selection
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 8) {
                    // Voice personas list
                    VStack(spacing: 0) {
                        ForEach(voicePersonas, id: \.name) { persona in
                            VoicePersonaView(
                                persona: persona,
                                isSelected: selectedVoice == persona.name,
                                onSelect: {
                                    selectedVoice = persona.name
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
            .safeAreaInset(edge: .top) {
                // Header
                VStack(spacing: 0) {
                    // Grab bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(hex: "#666666"))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                            
                            Text("Voice")
                                .font(.custom("IBMPlexMono", size: 20))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                        }
                        .padding(.leading, 20)
                        
                        Spacer()

                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(width: 32, height: 32)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, 20)
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
    }
    
    private var voicePersonas: [VoicePersona] {
        [
            VoicePersona(name: "Tom"),
            VoicePersona(name: "Frank"),
            VoicePersona(name: "Mary")
        ]
    }
}

struct VoicePersona: Identifiable {
    let id = UUID()
    let name: String
}

struct VoicePersonaView: View {
    let persona: VoicePersona
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onSelect) {
                HStack {
                    Text(persona.name)
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(Color(hex: "#EEEEEE"))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    // Circular checkmark button
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#BBBBBB"))
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