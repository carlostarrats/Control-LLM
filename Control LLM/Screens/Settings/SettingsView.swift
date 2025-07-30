import SwiftUI

struct SettingsView: View {
    @Binding var showingTextModal: Bool
    @ObservedObject var mainViewModel: MainViewModel
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
                VStack(spacing: 8) { // Reduced to 8 to move content up
                    // Settings list
                    VStack(spacing: 0) {
                        ForEach(settingsItems, id: \.title) { item in
                            SettingsItemView(item: item)
                        }
                    }
                    .padding(.top, 0) // Removed negative padding
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
                        Text("Settings")
                            .font(.custom("IBMPlexMono", size: 20))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                    
                    // Buffer space below header
                    Spacer()
                        .frame(height: 18) // Changed from 16 to 18
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
    }
    
    private var settingsItems: [SettingsItem] {
        [
            SettingsItem(title: "Voice Settings", action: {}),
            SettingsItem(title: "Model Configuration", action: {}),
            SettingsItem(title: "Privacy & Security", action: {}),
            SettingsItem(title: "About", action: {})
        ]
    }
}

struct SettingsItem: Identifiable {
    let id = UUID()
    let title: String
    let action: () -> Void
}

struct SettingsItemView: View {
    let item: SettingsItem
    
    var body: some View {
        Button(action: item.action) {
            VStack(spacing: 0) {
                HStack {
                    Text(item.title)
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(Color(hex: "#EEEEEE"))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Horizontal line under each item
                Rectangle()
                    .fill(Color(hex: "#333333"))
                    .frame(height: 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
} 