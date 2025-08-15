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
                        .fill(Color(hex: "#666666"))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)

                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))

                            Text("FAQs")
                                .font(.custom("IBMPlexMono", size: 20))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                        }
                        .padding(.leading, 20)

                        Spacer()

                        Button(action: { dismiss() }) {
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

    private var faqItems: [FAQItem] {
        [
            FAQItem(
                question: "How does voice work?",
                answer: "Voice input is only on the main screen. Speak, then press the sparkle to process. The reply is spoken and saved to chat."
            ),
            FAQItem(
                question: "Is chat text-only?",
                answer: "Yes. The chat window is text-only and shows the full conversation history."
            ),
            FAQItem(
                question: "Are my chats private?",
                answer: "All data stays on-device. Nothing is uploaded or shared. Delete the app to remove all data."
            ),
            FAQItem(
                question: "Which voices are available?",
                answer: "The Voice settings list the iOS system voices installed on your device. If a picked voice isn't available, a default voice is used."
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
                    .foregroundColor(Color(hex: "#EEEEEE"))

                Text(item.answer)
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#BBBBBB"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 12)

            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(height: 1)
        }
    }
}


