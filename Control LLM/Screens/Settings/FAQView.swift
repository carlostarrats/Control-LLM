import SwiftUI

struct FAQView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
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
                        .fill(Color(hex: "#666666"))
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
                question: "Privacy",
                answer: "This app stores all data on your device only - nothing is saved or shared, and no account exists. To remove all data, delete the app."
            ),
            FAQItem(
                question: "LLM Models",
                answer: "Multiple models are available in Settings, each varying in size and capability. Model performance depends on your device - newer phones typically handle larger, more powerful models better, while smaller models are optimized for older devices."
            ),
            FAQItem(
                question: "Chat History",
                answer: "No chat history is saved. Messages in the chat window gradually fade over 7 days until completely erased, ensuring complete privacy and freeing up device storage."
            ),
            FAQItem(
                question: "Language",
                answer: "English is the default language, though various models support multiple languages. The app automatically uses your iOS localization settings when supported. Unsupported languages will default to English."
            ),
            FAQItem(
                question: "UI Color",
                answer: "All text colors can be customized in Appearance settings, allowing you to create your preferred visual theme."
            ),
            FAQItem(
                question: "Control Units",
                answer: "Three LLM avatars are available in Appearance settings. These are purely cosmetic choices to personalize your chat experience."
            ),
            FAQItem(
                question: "iOS Shortcuts Integration",
                answer: "Actions are available as building blocks in Apple's Shortcuts app, allowing you to create automation workflows. Chain multiple messages together, set up custom voice commands with Siri, and build sequences that run in the background. Simply use the app normally - your actions are automatically suggested to Shortcuts for creating automations, all on device."
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

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.question)
                    .font(.custom("IBMPlexMono", size: 16))
                    .foregroundColor(ColorManager.shared.redColor)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(item.answer)
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(ColorManager.shared.greyTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 12)
        }
    }
}


