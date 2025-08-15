import SwiftUI
import AVFoundation

// Helper functions to format language codes for better readability
private func formatLanguageDisplay(_ languageCode: String) -> String {
    let components = languageCode.components(separatedBy: "-")
    if components.count >= 2 {
        let language = components[0]
        let region = components[1]
        
        let languageName = getLanguageName(language)
        let regionName = getRegionName(region)
        
        return "\(languageName) (\(regionName))"
    } else if components.count == 1 {
        return getLanguageName(components[0])
    }
    return languageCode
}

private func getLanguageName(_ code: String) -> String {
    switch code.lowercased() {
    case "ar": return "Arabic"
    case "bg": return "Bulgarian"
    case "ca": return "Catalan"
    case "cs": return "Czech"
    case "da": return "Danish"
    case "de": return "German"
    case "el": return "Greek"
    case "en": return "English"
    case "es": return "Spanish"
    case "et": return "Estonian"
    case "fa": return "Persian"
    case "fi": return "Finnish"
    case "fr": return "French"
    case "he": return "Hebrew"
    case "hi": return "Hindi"
    case "hr": return "Croatian"
    case "hu": return "Hungarian"
    case "id": return "Indonesian"
    case "it": return "Italian"
    case "ja": return "Japanese"
    case "ko": return "Korean"
    case "lt": return "Lithuanian"
    case "lv": return "Latvian"
    case "ms": return "Malay"
    case "nb": return "Norwegian Bokmål"
    case "nl": return "Dutch"
    case "no": return "Norwegian"
    case "pl": return "Polish"
    case "pt": return "Portuguese"
    case "ro": return "Romanian"
    case "ru": return "Russian"
    case "sk": return "Slovak"
    case "sl": return "Slovenian"
    case "sr": return "Serbian"
    case "sv": return "Swedish"
    case "ta": return "Tamil"
    case "th": return "Thai"
    case "tr": return "Turkish"
    case "uk": return "Ukrainian"
    case "vi": return "Vietnamese"
    case "zh": return "Chinese"
    default: return code.uppercased()
    }
}

private func getRegionName(_ code: String) -> String {
    switch code.uppercased() {
    case "AE": return "United Arab Emirates"
    case "AR": return "Argentina"
    case "AT": return "Austria"
    case "AU": return "Australia"
    case "BE": return "Belgium"
    case "BG": return "Bulgaria"
    case "BR": return "Brazil"
    case "CA": return "Canada"
    case "CH": return "Switzerland"
    case "CL": return "Chile"
    case "CN": return "China"
    case "CO": return "Colombia"
    case "CZ": return "Czech Republic"
    case "DE": return "Germany"
    case "DK": return "Denmark"
    case "EG": return "Egypt"
    case "ES": return "Spain"
    case "FI": return "Finland"
    case "FR": return "France"
    case "GB": return "United Kingdom"
    case "GR": return "Greece"
    case "HK": return "Hong Kong"
    case "HR": return "Croatia"
    case "HU": return "Hungary"
    case "ID": return "Indonesia"
    case "IE": return "Ireland"
    case "IL": return "Israel"
    case "IN": return "India"
    case "IT": return "Italy"
    case "JP": return "Japan"
    case "KR": return "South Korea"
    case "LT": return "Lithuania"
    case "LU": return "Luxembourg"
    case "LV": return "Latvia"
    case "MA": return "Morocco"
    case "MX": return "Mexico"
    case "MY": return "Malaysia"
    case "NL": return "Netherlands"
    case "NO": return "Norway"
    case "NZ": return "New Zealand"
    case "PE": return "Peru"
    case "PH": return "Philippines"
    case "PL": return "Poland"
    case "PT": return "Portugal"
    case "RO": return "Romania"
    case "RU": return "Russia"
    case "SA": return "Saudi Arabia"
    case "SE": return "Sweden"
    case "SG": return "Singapore"
    case "SI": return "Slovenia"
    case "SK": return "Slovakia"
    case "TH": return "Thailand"
    case "TR": return "Turkey"
    case "TW": return "Taiwan"
    case "UA": return "Ukraine"
    case "US": return "United States"
    case "VE": return "Venezuela"
    case "VN": return "Vietnam"
    case "ZA": return "South Africa"
    default: return code
    }
}

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
                        Text(formatLanguageDisplay(voice.language))
                            .font(.custom("IBMPlexMono", size: 10))
                            .foregroundColor(ColorManager.shared.redColor)
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