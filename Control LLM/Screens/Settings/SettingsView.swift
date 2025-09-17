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
                        SystemInfoView(mainViewModel: mainViewModel)
                            .padding(.horizontal, 20)
                            .padding(.top, 40)
                            .padding(.bottom, 60)
                    }
                }
                

                
                // Privacy notice text removed
            }
            // Removed header overlay (grabber, title, close button)
        }
        .fullScreenCover(isPresented: $showingModels) {
            SettingsModelsView()
        }
        .fullScreenCover(isPresented: $showingAppearance) {
            AppearanceView()
        }
        .fullScreenCover(isPresented: $showingFAQ) {
            FAQView()
        }
        // Voice settings sheet removed

        .fullScreenCover(isPresented: $showingCredits) {
            CreditsView()
        }
    }
    
    private var settingsItems: [SettingsItem] {
        [
            SettingsItem(title: NSLocalizedString("Models", comment: ""), symbol: "terminal", action: { showingModels = true }),
            // Agents removed
            SettingsItem(title: NSLocalizedString("Appearance", comment: ""), symbol: "eye", action: { showingAppearance = true }),
            // Voice settings removed
            SettingsItem(title: NSLocalizedString("FAQ", comment: ""), symbol: "questionmark.circle", action: { showingFAQ = true }),
            SettingsItem(title: NSLocalizedString("Credits", comment: ""), symbol: "text.page", action: { showingCredits = true })
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
    @ObservedObject var mainViewModel: MainViewModel
    @State private var modelManager = ModelManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Active Model Section
            if let selectedModel = modelManager.selectedModel {
                HStack(alignment: .center) {
                    Text(NSLocalizedString("Selected Model", comment: ""))
                        .font(.custom("IBMPlexMono", size: 14))
                        .foregroundColor(Color(hex: "#555555"))
                        .fixedSize()
                    
                    Spacer()
                    
                    Text(selectedModel.statusDisplayName)
                        .font(.custom("IBMPlexMono", size: 14))
                        .foregroundColor(Color(hex: "#555555"))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .fixedSize()
                }
                .background(Color(hex: "#1c1c1c").opacity(0.9))
                .cornerRadius(4)
            }
            
            // System Status Section
            HStack {
                Text(NSLocalizedString("System Status", comment: ""))
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#555555"))
                
                Spacer()
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    Text(statusText)
                        .font(.custom("IBMPlexMono", size: 14))
                        .foregroundColor(Color(hex: "#555555"))
                }
            }
            .background(Color(hex: "#1b1b1b").opacity(0.9))
            .cornerRadius(4)
                
            // Response Latency Section
            HStack {
                Text(NSLocalizedString("Response Latency", comment: ""))
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#555555"))
                
                Spacer()
                
                Text(responseLatency)
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#555555"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .fixedSize()
            }
            .background(Color(hex: "#1b1b1b").opacity(0.9))
            .cornerRadius(4)
                
            // Memory Pressure Section
            HStack {
                Text(NSLocalizedString("Memory Pressure", comment: ""))
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#555555"))
                
                Spacer()
                
                Text(memoryPressureText)
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#555555"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .fixedSize()
            }
            .background(Color(hex: "#1a1a1a").opacity(0.9))
            .cornerRadius(4)
                
            // Thermal State Section
            HStack {
                Text(NSLocalizedString("Thermal State", comment: ""))
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#555555"))
                
                Spacer()
                
                Text(thermalStateText)
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#555555"))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .fixedSize()
            }
            .background(Color(hex: "#1a1a1a").opacity(0.9))
            .cornerRadius(4)
                
            // Version Section
            HStack {
                Text(NSLocalizedString("Version", comment: ""))
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#555555"))
                
                Spacer()
                
                Text(NSLocalizedString("1.1", comment: ""))
                    .font(.custom("IBMPlexMono", size: 14))
                    .foregroundColor(Color(hex: "#555555"))
            }
            .background(Color(hex: "#1a1a1a").opacity(0.9))
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
        if mainViewModel.llm.isProcessing {
            return NSLocalizedString("Processing", comment: "System status when processing")
        } else if mainViewModel.llm.modelLoaded {
            return NSLocalizedString("Operational", comment: "System status when model is loaded")
        } else {
            return NSLocalizedString("Standby", comment: "System status when model is not loaded")
        }
    }
    
    private var statusColor: Color {
        if mainViewModel.llm.isProcessing {
            return ColorManager.shared.orangeColor
        } else if mainViewModel.llm.modelLoaded {
            return Color(hex: "#3EBBA5") // Success color - green
        } else {
            return ColorManager.shared.greyTextColor // Grey for disconnected
        }
    }
    
    @State private var responseLatency: String = NSLocalizedString("Calculating...", comment: "Status while calculating response latency")
    @State private var memoryPressureText: String = NSLocalizedString("Calculating...", comment: "Status while calculating memory pressure")
    @State private var thermalStateText: String = NSLocalizedString("Calculating...", comment: "Status while calculating thermal state")
    
    private func updateResourceInfo() {
        // Response Latency - show average from chatViewModel
        if mainViewModel.llm.averageResponseDuration > 0 {
            responseLatency = String(format: NSLocalizedString("%.0f ms avg", comment: "Average response time format"), mainViewModel.llm.averageResponseDuration * 1000)
        } else {
            responseLatency = NSLocalizedString("No data yet", comment: "Response latency when no data available")
        }
        
        // Memory Pressure - iOS doesn't expose this directly, so we'll show available memory
        let processInfo = ProcessInfo.processInfo
        let physicalMemory = processInfo.physicalMemory
        let availableMemoryGB = Double(physicalMemory) / (1024 * 1024 * 1024) // Convert to GB
        if availableMemoryGB > 2.0 {
            memoryPressureText = NSLocalizedString("Low", comment: "Memory pressure level - low")
        } else if availableMemoryGB > 1.0 {
            memoryPressureText = NSLocalizedString("Moderate", comment: "Memory pressure level - moderate")
        } else if availableMemoryGB > 0.5 {
            memoryPressureText = NSLocalizedString("High", comment: "Memory pressure level - high")
        } else {
            memoryPressureText = NSLocalizedString("Critical", comment: "Memory pressure level - critical")
        }
        
        // Thermal State
        let thermalState = ProcessInfo.processInfo.thermalState
        switch thermalState {
        case .nominal:
            thermalStateText = NSLocalizedString("Normal", comment: "Thermal state - normal")
        case .fair:
            thermalStateText = NSLocalizedString("Medium", comment: "Thermal state - medium")
        case .serious:
            thermalStateText = NSLocalizedString("High", comment: "Thermal state - high")
        case .critical:
            thermalStateText = NSLocalizedString("Critical", comment: "Thermal state - critical")
        @unknown default:
            thermalStateText = NSLocalizedString("Unknown", comment: "Thermal state - unknown")
        }
    }
} 