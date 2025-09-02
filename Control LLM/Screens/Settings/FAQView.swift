import SwiftUI

struct FAQView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 8) {
                    VStack(spacing: 0) {
                        ForEach(faqItems, id: \.question) { item in
                            FAQItemView(item: item)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
            .safeAreaInset(edge: .top) {
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(ColorManager.shared.greenColor)
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)

                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(ColorManager.shared.whiteTextColor)

                            Text(NSLocalizedString("FAQs", comment: ""))
                                .font(.custom("IBMPlexMono", size: 20))
                                .foregroundColor(ColorManager.shared.whiteTextColor)
                        }
                        .padding(.leading, 20)

                        Spacer()

                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ColorManager.shared.whiteTextColor)
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

    private var faqItems: [FAQItem] {
        [
            FAQItem(
                question: NSLocalizedString("Privacy", comment: ""),
                answer: NSLocalizedString("This app stores all data on your device only - nothing is saved or shared, and no account exists. To remove all data, delete the app.", comment: "")
            ),
            FAQItem(
                question: NSLocalizedString("LLM Models", comment: ""),
                answer: NSLocalizedString("Multiple models are available in Settings. Each model has different strengths, so you may find one works better than another depending on your specific needs.", comment: "")
            ),
            FAQItem(
                question: NSLocalizedString("Chat History", comment: ""),
                answer: NSLocalizedString("Chat history is temporary and automatically resets when you close and reopen the app. If you keep the app open in the background, your chat history will reset after 24 hours to ensure privacy.", comment: "")
            ),
            FAQItem(
                question: NSLocalizedString("Language", comment: ""),
                answer: NSLocalizedString("English is the default language, though various models support multiple languages. The app automatically uses your iOS localization settings when supported. Unsupported languages will default to English.", comment: "")
            ),
            FAQItem(
                question: NSLocalizedString("UI Color", comment: ""),
                answer: NSLocalizedString("All text colors can be customized in Appearance settings, allowing you to create your preferred visual theme.", comment: "")
            ),
            FAQItem(
                question: NSLocalizedString("Control Units", comment: ""),
                answer: NSLocalizedString("Three LLM avatars are available in Appearance settings. These are purely cosmetic choices to personalize your chat experience.", comment: "")
            ),
            FAQItem(
                question: NSLocalizedString("File Processing", comment: ""),
                answer: NSLocalizedString("The app supports these file types: .txt, .md, .rtf, .pdf, .jpg, .jpeg, .png, .heic, .doc, .docx.\n\nFor documents and images with text, the app uses rule-based text analysis and pattern matching rather than LLM processing. This approach is fast and efficient, though the analysis is limited compared to what larger cloud-based models can provide.", comment: "")
            ),
            FAQItem(
                question: NSLocalizedString("iOS Shortcuts Integration", comment: ""),
                answer: NSLocalizedString("Actions are available as building blocks in Apple's Shortcuts app, allowing you to create automation workflows. Chain multiple messages together, set up custom voice commands with Siri, and build sequences that run in the background. Simply use the app normally - your actions are automatically suggested to Shortcuts for creating automations, all on device.", comment: "")
            )
        ]
    }
}

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQItemView: View {
    let item: FAQItem
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {
                    Text(item.question)
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(ColorManager.shared.whiteTextColor)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ColorManager.shared.whiteTextColor)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            
            // Answer content (shown when expanded)
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    Text(item.answer)
                        .font(.custom("IBMPlexMono", size: 14))
                        .foregroundColor(ColorManager.shared.orangeColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 4)
                        .padding(.bottom, 12)
                }
            }
            
            // Horizontal line under the item
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(height: 1)
        }
    }
}


