import SwiftUI

struct SettingsView: View {
    @Binding var showingTextModal: Bool
    @ObservedObject var mainViewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Sheet state variables
    @State private var showingModels = false
    @State private var showingAppearance = false
    @State private var showingFAQ = false
    // Voice functionality removed


    @State private var showingCredits = false
    
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
            
            VStack {
                // Top spacing
                Spacer()
                    .frame(height: 40)
                
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
                        
                        // Footer section
                        VStack(spacing: 4) {
                            Text("V 1.0")
                                .font(.custom("IBMPlexMono", size: 14))
                                .foregroundColor(Color(hex: "#666666"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 40)
                            
                            Text(NSLocalizedString("Made by Control.Design", comment: ""))
                                .font(.custom("IBMPlexMono", size: 14))
                                .foregroundColor(Color(hex: "#666666"))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                }
                
                Spacer()
                
                // Privacy notice text removed
            }
            // Removed header overlay (grabber, title, close button)
        }
        .sheet(isPresented: $showingModels) {
            SettingsModelsView()
        }
        .sheet(isPresented: $showingAppearance) {
            AppearanceView()
        }
        .sheet(isPresented: $showingFAQ) {
            FAQView()
        }
        // Voice settings sheet removed

        .sheet(isPresented: $showingCredits) {
            CreditsView()
        }
    }
    
    private var settingsItems: [SettingsItem] {
        [
            SettingsItem(title: "Models", symbol: "terminal", action: { showingModels = true }),
            // Agents removed
            SettingsItem(title: "Appearance", symbol: "eye", action: { showingAppearance = true }),
            // Voice settings removed
            SettingsItem(title: "FAQ", symbol: "questionmark.circle", action: { showingFAQ = true }),
            SettingsItem(title: "Credits", symbol: "text.page", action: { showingCredits = true })
        ]
    }
}

struct SettingsItem: Identifiable {
    let id = UUID()
    let title: String
    let symbol: String
    let action: () -> Void
}

struct SettingsItemView: View {
	let item: SettingsItem

	
	var body: some View {
		VStack(spacing: 0) {
			Button(action: item.action) {
				HStack {
					Image(systemName: item.symbol)
						.font(.system(size: 16, weight: .medium))
						.foregroundColor(Color(hex: "#BBBBBB"))
						.frame(width: 20)
					
					Text(NSLocalizedString(item.title, comment: ""))
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
			}
			.frame(maxWidth: .infinity)
			
			// Horizontal line under each item
			Rectangle()
				.fill(Color(hex: "#333333"))
				.frame(height: 1)
		}
		.frame(maxWidth: .infinity)
	}
}

struct ToastView: View {
    let message: String
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 12) {
                // Checkmark icon
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(hex: "#1D1D1D"))
                
                // Message text
                Text(message)
                    .font(.custom("IBMPlexMono", size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "#1D1D1D"))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                ColorManager.shared.redColor
                    .opacity(0.9)
            )
            .cornerRadius(4)
            .padding(.horizontal, 40)
            .padding(.bottom, 100)
        }
        .transition(.asymmetric(
            insertion: AnyTransition.offset(y: 20).combined(with: .opacity),
            removal: AnyTransition.offset(y: 20).combined(with: .opacity)
        ))
        .animation(.easeInOut(duration: 0.5), value: true)
    }
} 