import SwiftUI

struct CreditsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()
            
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
                .padding(.bottom, 20)
            }
            .safeAreaInset(edge: .top) {
                // Header
                VStack(spacing: 0) {
                    // Grab bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(ColorManager.shared.greenColor)
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
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
                    .padding(.bottom, 20)
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
    }
    
    private var creditsItems: [CreditsItem] {
        [
            CreditsItem(title: "Michael Verges - Liquid", url: "https://github.com/maustinstar/liquid"),
            CreditsItem(title: "IBM Plex Mono", url: "https://github.com/IBM/plex?tab=readme-ov-file"),
            CreditsItem(title: "Control.Design", url: "https://control.design") // Placeholder URL
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