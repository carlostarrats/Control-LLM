import SwiftUI

struct SettingsTabsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            // Tab selector
            Picker("Settings Type", selection: $viewModel.selectedTab) {
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
            Section("App Settings") {
                // Voice commands removed
                // Auto transcribe removed
                Toggle("Save Chat History", isOn: $viewModel.appSettings.saveChatHistory)
                Toggle("Notifications", isOn: $viewModel.appSettings.enableNotifications)
                
                Picker("Language", selection: $viewModel.appSettings.language) {
                    Text(NSLocalizedString("English", comment: "")).tag("English")
                    Text(NSLocalizedString("Spanish", comment: "")).tag("Spanish")
                    Text(NSLocalizedString("French", comment: "")).tag("French")
                }
                
                Stepper("Max History Items: \(viewModel.appSettings.maxHistoryItems)", 
                       value: $viewModel.appSettings.maxHistoryItems, in: 10...1000, step: 10)
            }
            
            Section("UI Customization") {
                Toggle("Dark Mode", isOn: $viewModel.uiCustomization.useDarkMode)
                Toggle("Haptic Feedback", isOn: $viewModel.uiCustomization.enableHapticFeedback)
                Toggle("Animations", isOn: $viewModel.uiCustomization.enableAnimations)
                
                Picker("Font Size", selection: $viewModel.uiCustomization.fontSize) {
                    ForEach(FontSize.allCases, id: \.self) { size in
                        Text(size.rawValue).tag(size)
                    }
                }
                
                ColorPicker("Primary Color", selection: $viewModel.uiCustomization.primaryColor)
                ColorPicker("Secondary Color", selection: $viewModel.uiCustomization.secondaryColor)
            }
            
            Section {
                Button("Save Settings") {
                    viewModel.saveSettings()
                }
                .frame(maxWidth: .infinity)
                
                Button("Reset to Defaults") {
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
            Section("App Information") {
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
            
            Section("API Configuration") {
                HStack {
                    Text(NSLocalizedString("API Endpoint", comment: ""))
                    Spacer()
                    Text(viewModel.developerInfo.apiEndpoint)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Toggle("Debug Mode", isOn: $viewModel.developerInfo.debugMode)
                
                Picker("Log Level", selection: $viewModel.developerInfo.logLevel) {
                    Text(NSLocalizedString("Debug", comment: "")).tag("Debug")
                    Text(NSLocalizedString("Info", comment: "")).tag("Info")
                    Text(NSLocalizedString("Warning", comment: "")).tag("Warning")
                    Text(NSLocalizedString("Error", comment: "")).tag("Error")
                }
            }
            
            Section("Developer Tools") {
                Button("Export Settings") {
                    viewModel.exportSettings()
                }
                .frame(maxWidth: .infinity)
                
                Button("Clear Cache") {
                    // TODO: Implement cache clearing
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(Color(hex: "#F8C762"))
                
                Button("Reset App Data") {
                    // TODO: Implement app data reset
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.red)
            }
            
            Section("About") {
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