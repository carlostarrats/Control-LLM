import SwiftUI

struct SettingsTabsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            // Tab selector
            Picker(NSLocalizedString("Settings Type", comment: ""), selection: $viewModel.selectedTab) {
                Text(NSLocalizedString("UI", comment: "")).tag(0)
                Text(NSLocalizedString("Dev", comment: "")).tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Tab content
            TabView(selection: $viewModel.selectedTab) {
                UISettingsTab(viewModel: viewModel)
                    .tag(0)
                
                DeveloperSettingsTab(viewModel: viewModel)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

struct UISettingsTab: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        Form {
            Section(NSLocalizedString("App Settings", comment: "")) {
                // Voice commands removed
                // Auto transcribe removed
                Toggle(NSLocalizedString("Notifications", comment: ""), isOn: $viewModel.appSettings.enableNotifications)
                
                Picker(NSLocalizedString("Language", comment: ""), selection: $viewModel.appSettings.language) {
                    Text(NSLocalizedString("English", comment: "")).tag("English")
                    Text(NSLocalizedString("Spanish", comment: "")).tag("Spanish")
                    Text(NSLocalizedString("French", comment: "")).tag("French")
                }
            }
            
            Section(NSLocalizedString("UI Customization", comment: "")) {
                Toggle(NSLocalizedString("Dark Mode", comment: ""), isOn: $viewModel.uiCustomization.useDarkMode)
                Toggle(NSLocalizedString("Haptic Feedback", comment: ""), isOn: $viewModel.uiCustomization.enableHapticFeedback)
                Toggle(NSLocalizedString("Animations", comment: ""), isOn: $viewModel.uiCustomization.enableAnimations)
                
                Picker(NSLocalizedString("Font Size", comment: ""), selection: $viewModel.uiCustomization.fontSize) {
                    Text(NSLocalizedString("Small", comment: "")).tag(FontSize.small)
                    Text(NSLocalizedString("Medium", comment: "")).tag(FontSize.medium)
                    Text(NSLocalizedString("Large", comment: "")).tag(FontSize.large)
                }
                
                ColorPicker(NSLocalizedString("Primary Color", comment: ""), selection: $viewModel.uiCustomization.primaryColor)
                ColorPicker(NSLocalizedString("Secondary Color", comment: ""), selection: $viewModel.uiCustomization.secondaryColor)
            }
            
            Section {
                Button(NSLocalizedString("Save Settings", comment: "")) {
                    viewModel.saveSettings()
                }
                .frame(maxWidth: .infinity)
                
                Button(NSLocalizedString("Reset to Defaults", comment: "")) {
                    viewModel.resetToDefaults()
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(ColorManager.shared.orangeColor)
            }
        }
    }
}

struct DeveloperSettingsTab: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        Form {
            Section(NSLocalizedString("App Information", comment: "")) {
                HStack {
                    Text(NSLocalizedString("Version", comment: ""))
                    Spacer()
                    Text(viewModel.developerInfo.appVersion)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(NSLocalizedString("Build", comment: ""))
                    Spacer()
                    Text(viewModel.developerInfo.buildNumber)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(NSLocalizedString("Last Updated", comment: ""))
                    Spacer()
                    Text(viewModel.developerInfo.lastUpdated, style: .date)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(NSLocalizedString("API Configuration", comment: "")) {
                HStack {
                    Text(NSLocalizedString("API Endpoint", comment: ""))
                    Spacer()
                    Text(viewModel.developerInfo.apiEndpoint)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Toggle(NSLocalizedString("Debug Mode", comment: ""), isOn: $viewModel.developerInfo.debugMode)
                
                Picker(NSLocalizedString("Log Level", comment: ""), selection: $viewModel.developerInfo.logLevel) {
                    Text(NSLocalizedString("Debug", comment: "")).tag("Debug")
                    Text(NSLocalizedString("Info", comment: "")).tag("Info")
                    Text(NSLocalizedString("Warning", comment: "")).tag("Warning")
                    Text(NSLocalizedString("Error", comment: "")).tag("Error")
                }
            }
            
            Section(NSLocalizedString("Developer Tools", comment: "")) {
                Button(NSLocalizedString("Export Settings", comment: "")) {
                    viewModel.exportSettings()
                }
                .frame(maxWidth: .infinity)
                
                Button(NSLocalizedString("Clear Cache", comment: "")) {
                    // TODO: Implement cache clearing
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(Color(hex: "#F8C762"))
                
                Button(NSLocalizedString("Reset App Data", comment: "")) {
                    // TODO: Implement app data reset
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.red)
            }
            
            Section(NSLocalizedString("About", comment: "")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("Control LLM", comment: ""))
                        .font(.headline)
                    Text(NSLocalizedString("A text-based AI assistant with custom UI and MVVM architecture.", comment: ""))
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

#Preview {
    SettingsTabsView(viewModel: SettingsViewModel())
} 