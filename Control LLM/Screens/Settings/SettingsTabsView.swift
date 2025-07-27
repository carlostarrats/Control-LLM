import SwiftUI

struct SettingsTabsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack {
            // Tab selector
            Picker("Settings Type", selection: $viewModel.selectedTab) {
                Text("UI").tag(0)
                Text("Dev").tag(1)
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
                Toggle("Voice Commands", isOn: $viewModel.appSettings.enableVoiceCommands)
                Toggle("Auto Transcribe", isOn: $viewModel.appSettings.autoTranscribe)
                Toggle("Save Chat History", isOn: $viewModel.appSettings.saveChatHistory)
                Toggle("Notifications", isOn: $viewModel.appSettings.enableNotifications)
                
                Picker("Language", selection: $viewModel.appSettings.language) {
                    Text("English").tag("English")
                    Text("Spanish").tag("Spanish")
                    Text("French").tag("French")
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
                .foregroundColor(.orange)
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
                    Text("Version")
                    Spacer()
                    Text(viewModel.developerInfo.appVersion)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text(viewModel.developerInfo.buildNumber)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Last Updated")
                    Spacer()
                    Text(viewModel.developerInfo.lastUpdated, style: .date)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("API Configuration") {
                HStack {
                    Text("API Endpoint")
                    Spacer()
                    Text(viewModel.developerInfo.apiEndpoint)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Toggle("Debug Mode", isOn: $viewModel.developerInfo.debugMode)
                
                Picker("Log Level", selection: $viewModel.developerInfo.logLevel) {
                    Text("Debug").tag("Debug")
                    Text("Info").tag("Info")
                    Text("Warning").tag("Warning")
                    Text("Error").tag("Error")
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
                .foregroundColor(.orange)
                
                Button("Reset App Data") {
                    // TODO: Implement app data reset
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.red)
            }
            
            Section("About") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Control LLM")
                        .font(.headline)
                    Text("A voice-first AI assistant with custom UI and MVVM architecture.")
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