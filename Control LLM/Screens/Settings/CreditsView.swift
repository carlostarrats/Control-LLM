import SwiftUI

struct CreditsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "#1D1D1D"),  // Lighter color at top
                    Color(hex: "#141414")   // Darker color at bottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
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
                    .padding(.top, 0)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
            .safeAreaInset(edge: .top) {
                // iOS standard header overlay
                VStack(spacing: 0) {
                    // Grab bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(hex: "#666666"))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
                    // Header
                    HStack {
                        Text("Credits")
                            .font(.custom("IBMPlexMono", size: 20))
                            .foregroundColor(Color(hex: "#BBBBBB"))
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
                    
                    // Buffer space below header
                    Spacer()
                        .frame(height: 18)
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
                        .foregroundColor(Color(hex: "#EEEEEE"))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
                .background(Color(hex: "#333333"))
                .padding(.leading, 20)
        }
    }
} 