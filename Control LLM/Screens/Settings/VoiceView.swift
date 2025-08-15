import SwiftUI
import AVFoundation

struct VoiceView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var tts = TTSService.shared
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 8) {
                    // Installed iOS voices
                    VStack(spacing: 0) {
                        ForEach(TTSService.shared.availableVoices(), id: \.identifier) { voice in
                            VoiceRowView(
                                voice: voice,
                                isSelected: tts.selectedVoiceIdentifier == voice.identifier,
                                onSelect: {
                                    tts.setSelectedVoice(identifier: voice.identifier)
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
                            
                            Text(NSLocalizedString("Voice", comment: ""))
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
                    .padding(.bottom, 8)

                    // Sub copy under headline
                    HStack {
                        Text(NSLocalizedString("iOS System Voices", comment: ""))
                            .font(.custom("IBMPlexMono", size: 12))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                        Spacer()
                    }
                    .padding(.leading, 20)
                    .padding(.bottom, 12)
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
    }
    
}

struct VoiceRowView: View {
    let voice: AVSpeechSynthesisVoice
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onSelect) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(voice.name)
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(Color(hex: "#EEEEEE"))
                        .multilineTextAlignment(.leading)
                        Text(voice.language)
                            .font(.custom("IBMPlexMono", size: 10))
                            .foregroundColor(Color(hex: "#666666"))
                    }
                    
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