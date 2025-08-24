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
                        
                        // System Information Section
                        SystemInfoView()
                            .padding(.horizontal, 20)
                            .padding(.top, 40)
                            .padding(.bottom, 60)
                    }
                }
                
                // Footer section - moved outside ScrollView to stick to bottom
                VStack {
                    Text(NSLocalizedString("Made by Control.Design", comment: ""))
                        .font(.custom("IBMPlexMono", size: 14))
                        .foregroundColor(Color(hex: "#666666"))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                
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
						.foregroundColor(ColorManager.shared.whiteTextColor)
						.frame(width: 20)
					
					Text(NSLocalizedString(item.title, comment: ""))
						.font(.custom("IBMPlexMono", size: 16))
						                .foregroundColor(ColorManager.shared.whiteTextColor)
						.multilineTextAlignment(.leading)
					
					Spacer()
					
					Image(systemName: "chevron.right")
						.font(.system(size: 12))
						.foregroundColor(ColorManager.shared.whiteTextColor)
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

struct SystemInfoView: View {
    @State private var modelManager = ModelManager.shared
    @State private var chatViewModel = ChatViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            // Active Model Section
            if let selectedModel = modelManager.selectedModel {
                HStack(alignment: .center) {
                    Text("Model")
                        .font(.custom("IBMPlexMono", size: 14))
                        .foregroundColor(Color(hex: "#666666"))
                        .fixedSize()
                    
                    Spacer()
                    
                    Text(selectedModel.displayName)
                        .font(.custom("IBMPlexMono", size: 14))
                        .foregroundColor(Color(hex: "#666666"))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .fixedSize()
                }
                .background(Color(hex: "#1d1d1d"))
                .cornerRadius(4)
            }
            
            // System Status Section
            HStack {
                Text("System Status")
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#666666"))
                
                Spacer()
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    Text(statusText)
                        .font(.custom("IBMPlexMono", size: 14))
                        .foregroundColor(Color(hex: "#666666"))
                }
            }
            .background(Color(hex: "#1d1d1d"))
            .cornerRadius(4)
            
            // Response Latency Section
            HStack {
                Text("Response Latency")
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#666666"))
                
                Spacer()
                
                Text(responseLatency)
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#666666"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .fixedSize()
            }
            .background(Color(hex: "#1d1d1d"))
            .cornerRadius(4)
            
            // Memory Pressure Section
            HStack {
                Text("Memory Pressure")
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#666666"))
                
                Spacer()
                
                Text(memoryPressureText)
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#666666"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .fixedSize()
            }
            .background(Color(hex: "#1d1d1d"))
            .cornerRadius(4)
            
            // Thermal State Section
            HStack {
                Text("Thermal State")
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#666666"))
                
                Spacer()
                
                Text(thermalStateText)
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#666666"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .fixedSize()
            }
            .background(Color(hex: "#1d1d1d"))
            .cornerRadius(4)
            
            // Version Section
            HStack {
                Text("Version")
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#666666"))
                
                Spacer()
                
                Text("1.0")
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#666666"))
            }
            .background(Color(hex: "#1d1d1d"))
            .cornerRadius(4)
        }
        .onAppear {
            updateResourceInfo()
            // Start timer to update thermal state and memory pressure every 5 seconds
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                updateResourceInfo()
            }
        }
    }
    
    private var statusText: String {
        if chatViewModel.isProcessing {
            return "Processing"
        } else if chatViewModel.modelLoaded {
            return "Ready"
        } else {
            return "Idle"
        }
    }
    
    private var statusColor: Color {
        if chatViewModel.isProcessing {
            return ColorManager.shared.orangeColor
        } else if chatViewModel.modelLoaded {
            return Color(hex: "#3EBBA5") // Success color
        } else {
            return ColorManager.shared.greyTextColor
        }
    }
    
    @State private var responseLatency: String = "Calculating..."
    @State private var memoryPressureText: String = "Calculating..."
    @State private var thermalStateText: String = "Calculating..."
    
    private func updateResourceInfo() {
        // Response Latency - show average response time
        if chatViewModel.averageResponseDuration > 0 {
            responseLatency = String(format: "%.0f ms avg", chatViewModel.averageResponseDuration * 1000)
        } else {
            responseLatency = "No responses yet"
        }
        
        // Memory Pressure - iOS doesn't expose this directly, so we'll show available memory
        let processInfo = ProcessInfo.processInfo
        let physicalMemory = processInfo.physicalMemory
        let availableMemoryGB = Double(physicalMemory) / (1024 * 1024 * 1024) // Convert to GB
        if availableMemoryGB > 2.0 {
            memoryPressureText = "Low"
        } else if availableMemoryGB > 1.0 {
            memoryPressureText = "Moderate"
        } else if availableMemoryGB > 0.5 {
            memoryPressureText = "High"
        } else {
            memoryPressureText = "Critical"
        }
        
        // Thermal State
        let thermalState = ProcessInfo.processInfo.thermalState
        switch thermalState {
        case .nominal:
            thermalStateText = "Nominal"
        case .fair:
            thermalStateText = "Fair"
        case .serious:
            thermalStateText = "Serious"
        case .critical:
            thermalStateText = "Critical"
        @unknown default:
            thermalStateText = "Unknown"
        }
    }
} 