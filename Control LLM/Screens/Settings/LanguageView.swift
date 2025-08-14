import SwiftUI

struct LanguageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLanguage: String = LanguageService.shared.selectedLanguage
    @ObservedObject private var modelManager = ModelManager.shared
    
    // MARK: - Model-specific language support (voice)
    // Enforce default English always included and counts matching spec
    private let qwenLanguages: [String] = [
        "Arabic",
        "Chinese (Simplified)",
        "Chinese (Traditional)",
        "Czech",
        "Danish",
        "Dutch",
        "English",
        "Finnish",
        "French",
        "German",
        "Greek",
        "Hebrew",
        "Hindi",
        "Hungarian",
        "Indonesian",
        "Italian",
        "Japanese",
        "Korean",
        "Norwegian",
        "Persian (Farsi)",
        "Polish",
        "Portuguese (Brazilian)",
        "Portuguese (European)",
        "Romanian",
        "Russian",
        "Spanish",
        "Swedish",
        "Thai",
        "Turkish",
        "Vietnamese"
    ]

    private let phiLanguages: [String] = [
        "Arabic",
        "Chinese (Simplified)",
        "Czech",
        "Danish",
        "Dutch",
        "English",
        "Finnish",
        "French",
        "German",
        "Hebrew",
        "Hungarian",
        "Italian",
        "Japanese",
        "Korean",
        "Norwegian",
        "Polish",
        "Portuguese (European)",
        "Russian",
        "Spanish",
        "Swedish",
        "Thai",
        "Turkish",
        "Ukrainian"
    ]

    private let gemmaLanguages: [String] = [
        "English"
    ]

    // Union of all supported languages across models, with de-duplication preserving order
    private var allLanguages: [String] {
        var seen = Set<String>()
        let combined = qwenLanguages + phiLanguages + gemmaLanguages
        var result: [String] = []
        for lang in combined {
            if !seen.contains(lang) {
                seen.insert(lang)
                result.append(lang)
            }
        }
        return result
    }

    private var currentSupportedLanguages: Set<String> {
        guard let provider = modelManager.selectedModel?.provider.lowercased() else {
            return Set(allLanguages)
        }
        if provider.contains("alibaba") { return Set(qwenLanguages) }
        if provider.contains("microsoft") { return Set(phiLanguages) }
        if provider.contains("google") { return Set(gemmaLanguages) }
        return Set(allLanguages)
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 8) {
                    // Language options
                    VStack(spacing: 0) {
                        ForEach(allLanguages, id: \.self) { language in
                            let isEnabled = currentSupportedLanguages.contains(language)
                            LanguageItemView(
                                language: language,
                                isSelected: selectedLanguage == language,
                                isEnabled: isEnabled,
                                onSelect: {
                                    guard isEnabled else { return }
                                    selectedLanguage = language
                                    // Save via LanguageService (voice-only selection)
                                    LanguageService.shared.selectedLanguage = language
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
                        .padding(.bottom, 8)
                    
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "globe")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                            
                            Text("Language")
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Voice language options depend on your selected LLM. Text language automatically follows your iOS system language.")
                            .font(.custom("IBMPlexMono", size: 12))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .multilineTextAlignment(.leading)
                        
                        Text("To access more voices, select a different LLM in Model Settings. To change text language, update the language in your IOS Settings.")
                            .font(.custom("IBMPlexMono", size: 12))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.trailing, 60) // Add right padding to avoid X button
                    .padding(.bottom, 12)
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
    }
}

struct LanguageItemView: View {
    let language: String
    let isSelected: Bool
    let isEnabled: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onSelect) {
                HStack {
                    Text(language)
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(isEnabled ? Color(hex: "#EEEEEE") : Color(hex: "#666666"))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    // Radio button style checkmark
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(isEnabled ? Color(hex: "#BBBBBB") : Color(hex: "#333333"))
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .disabled(!isEnabled)
            .frame(maxWidth: .infinity)
            
            // Horizontal line under the item
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(height: 1)
        }
    }
} 