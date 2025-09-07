import SwiftUI

struct SettingsModelsView: View {
    @EnvironmentObject var colorManager: ColorManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var modelManager = ModelManager.shared
    @StateObject private var downloadService = ModelDownloadService.shared
    @State private var selectedModelsToDownload: Set<String> = []
    @State private var showingUnusedModelsSheet = false
    @State private var selectedUnusedModels: Set<String> = []
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 8) {
                    // Add small top padding to align with other settings pages
                    Spacer()
                        .frame(height: 5)
                    
                    // INSTALLED section
                    VStack(alignment: .leading, spacing: 4) {
                        Text(NSLocalizedString("INSTALLED", comment: ""))
                            .font(.custom("IBMPlexMono", size: 12))
                            .foregroundColor(colorManager.orangeColor)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 0) {
                            if modelManager.availableModels.isEmpty {
                                // Show "No Installed Models" when no models are installed
                                HStack {
                                    Text(NSLocalizedString("No Installed Models", comment: ""))
                                        .font(.custom("IBMPlexMono", size: 16))
                                        .foregroundColor(Color(hex: "#666666"))
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 4)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                ForEach(modelManager.availableModels, id: \.filename) { model in
                                    InstalledLLMModelView(
                                        model: model,
                                        isActive: modelManager.selectedModel?.filename == model.filename,
                                        onSelect: {
                                            modelManager.selectModel(model)
                                        },
                                        onDelete: {
                                            Task {
                                                do {
                                                    try await modelManager.deleteModel(model)
                                                    print("✅ Successfully deleted model: \(model.filename)")
                                                } catch {
                                                    print("❌ Failed to delete model: \(error.localizedDescription)")
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                
                // 30px spacing between sections
                Spacer()
                    .frame(height: 30)
                
                // Available Downloads section
                    VStack(alignment: .leading, spacing: 4) {
                        Text(NSLocalizedString("AVAILABLE DOWNLOADS", comment: ""))
                            .font(.custom("IBMPlexMono", size: 12))
                            .foregroundColor(colorManager.orangeColor)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 0) {
                            if availableDownloadModels.isEmpty {
                                // Show "Already Installed" when no downloads available
                                HStack {
                                    Text(NSLocalizedString("All Available Installed", comment: ""))
                                        .font(.custom("IBMPlexMono", size: 16))
                                        .foregroundColor(Color(hex: "#666666"))
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 4)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Horizontal line under the item
                                Rectangle()
                                    .fill(Color(hex: "#333333"))
                                    .frame(height: 1)
                            } else {
                                ForEach(availableDownloadModels, id: \.filename) { model in
                                    AvailableDownloadModelView(
                                        model: model,
                                        isDownloading: downloadService.isDownloading(model.filename),
                                        downloadProgress: downloadService.getDownloadProgress(model.filename),
                                        onDownload: {
                                            if downloadService.isDownloading(model.filename) {
                                                // Stop download
                                                downloadService.cancelDownload(model.filename)
                                            } else {
                                                // Start download
                                                Task {
                                                    do {
                                                        try await downloadService.downloadModel(model.filename)
                                                    } catch {
                                                        print("Download failed: \(error.localizedDescription)")
                                                    }
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                
                // 30px spacing between sections
                Spacer()
                    .frame(height: 30)
                
                // Manage Unused Models text
                Button(action: {
                    showingUnusedModelsSheet = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checklist")
                            .font(.system(size: 16))
                            .foregroundColor(colorManager.redColor)
                        
                        Text(NSLocalizedString("Manage Unused Models", comment: ""))
                            .font(.custom("IBMPlexMono", size: 16))
                            .foregroundColor(colorManager.redColor)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                .padding(.bottom, 12)
            }
        }
            .safeAreaInset(edge: .top) {
                // Header
                VStack(spacing: 0) {
                    // Grab bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(ColorManager.shared.greenColor)
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 10)
                    
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "terminal")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(ColorManager.shared.purpleColor)
                            
                            Text(NSLocalizedString("MODELS", comment: ""))
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
                    .padding(.bottom, 10)
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
        .sheet(isPresented: $showingUnusedModelsSheet) {
            UnusedModelsSheet(
                availableModels: modelManager.availableModels,
                activeModel: modelManager.selectedModel?.filename ?? "",
                selectedModels: $selectedUnusedModels,
                onDelete: {
                    // Delete selected unused models
                    Task {
                        for modelFilename in selectedUnusedModels {
                            if let model = modelManager.availableModels.first(where: { $0.filename == modelFilename }) {
                                do {
                                    try await modelManager.deleteModel(model)
                                    print("✅ Successfully deleted unused model: \(modelFilename)")
                                } catch {
                                    print("❌ Failed to delete unused model \(modelFilename): \(error.localizedDescription)")
                                }
                            }
                        }
                        selectedUnusedModels.removeAll()
                    }
                }
            )
            .presentationDetents(unusedModelsCount == 0 ? [.height(200)] : [.medium])
        }
    }
    
    private var availableDownloadModels: [LLMModelInfo] {
        return downloadService.getAvailableDownloadModels()
    }
    
    private var unusedModelsCount: Int {
        modelManager.availableModels.count
    }
    
}



struct AvailableDownloadModelView: View {
    let model: LLMModelInfo
    let isDownloading: Bool
    let downloadProgress: Double
    let onDownload: () -> Void
    @EnvironmentObject var colorManager: ColorManager
    
    // MARK: - Subtitle helper for available models
    private var availableModelSubtitle: String? {
        // Use the actual model description from ModelManager instead of hardcoded values
        return model.description
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(model.displayName)
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(ColorManager.shared.whiteTextColor)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    // Subtitle for available models
                    if let subtitle = availableModelSubtitle {
                        Text(subtitle)
                            .font(.custom("IBMPlexMono", size: 12))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    HStack {
                        Text(model.size)
                            .font(.custom("IBMPlexMono", size: 10))
                            .foregroundColor(colorManager.redColor)
                        
                        Text("•")
                            .font(.custom("IBMPlexMono", size: 10))
                            .foregroundColor(Color(hex: "#666666"))
                        
                        Text(model.provider)
                            .font(.custom("IBMPlexMono", size: 10))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                    }
                }
                
                Spacer()
                
                // Download button
                Button(action: onDownload) {
                    Image(systemName: isDownloading ? "square.inset.filled" : "arrow.down.square")
                        .font(.system(size: 20))
                        .foregroundColor(isDownloading ? colorManager.redColor : Color(hex: "#BBBBBB"))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Download progress bar (only show when downloading)
            if isDownloading {
                VStack(spacing: 4) {
                    // Progress bar
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(hex: "#333333"))
                            .frame(height: 2)
                        
                        Rectangle()
                            .fill(Color(hex: "#F8C762"))
                            .frame(width: UIScreen.main.bounds.width * 0.8 * CGFloat(downloadProgress), height: 2)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 2)
                    
                    // Progress text
                    Text(String(format: NSLocalizedString("Installing [%d%%]", comment: ""), Int(downloadProgress * 100)))
                        .font(.custom("IBMPlexMono", size: 10))
                        .foregroundColor(ColorManager.shared.greyTextColor)
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 12)
            }
            
            // Divider
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(height: 1)
        }
    }
}

struct InstalledLLMModelView: View {
    let model: LLMModelInfo
    let isActive: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onSelect) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(model.displayName)
                            .font(.custom("IBMPlexMono", size: 16))
                            .foregroundColor(ColorManager.shared.whiteTextColor)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        // Subtext under model name
                        if let subtitle = modelSubtitle {
                            Text(subtitle)
                                .font(.custom("IBMPlexMono", size: 12))
                                .foregroundColor(ColorManager.shared.greyTextColor)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // "In Use" indicator for active model
                        if isActive {
                            Text("In Use")
                                .font(.custom("IBMPlexMono", size: 10))
                                .foregroundColor(ColorManager.shared.greenColor)
                                .multilineTextAlignment(.leading)
                        }

                        // Voice capabilities text removed

                        HStack {
                            Text(model.size)
                                .font(.custom("IBMPlexMono", size: 10))
                                .foregroundColor(ColorManager.shared.redColor)
                            
                            Text("•")
                                .font(.custom("IBMPlexMono", size: 10))
                                .foregroundColor(Color(hex: "#666666"))
                            
                            Text(model.provider)
                                .font(.custom("IBMPlexMono", size: 10))
                                .foregroundColor(ColorManager.shared.greyTextColor)
                        }
                    }
                    
                    Spacer()
                    
                    // Active checkmark or empty circle
                    Image(systemName: isActive ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(ColorManager.shared.greyTextColor)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            
            // Horizontal line under the item
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(height: 1)
        }
    }

    // MARK: - Subtitle helper
    private var modelSubtitle: String? {
        // Use the actual model description from ModelManager instead of hardcoded values
        return model.description
    }
}



 

struct UnusedModelsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let availableModels: [LLMModelInfo]
    let activeModel: String
    @Binding var selectedModels: Set<String>
    let onDelete: () -> Void
    
    private var unusedModels: [LLMModelInfo] {
        availableModels
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#1D1D1D")
                .ignoresSafeArea()
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 20) {
                    // Description
                    Text(unusedModels.isEmpty ? NSLocalizedString("No Unused Models", comment: "") : NSLocalizedString("Delete your unused models.", comment: ""))
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(unusedModels.isEmpty ? Color(hex: "#666666") : ColorManager.shared.greyTextColor)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                
                if unusedModels.isEmpty {
                    Spacer()
                } else {
                    // List of unused models
                                            ScrollView {
                            VStack(spacing: 0) {
                                ForEach(Array(unusedModels.enumerated()), id: \.element.filename) { index, model in
                                    UnusedLLMModelRowView(
                                        model: model,
                                        isSelected: selectedModels.contains(model.filename),
                                        isLastItem: index == unusedModels.count - 1,
                                        isActive: model.filename == activeModel,
                                        onToggle: {
                                            if selectedModels.contains(model.filename) {
                                                selectedModels.remove(model.filename)
                                            } else {
                                                selectedModels.insert(model.filename)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    
                    // Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            FeedbackService.shared.playHaptic(.light)
                            onDelete()
                            dismiss()
                        }) {
                            Text(selectedModels.count == 1 ? NSLocalizedString("Delete Model", comment: "") : NSLocalizedString("Delete Models", comment: ""))
                                .font(.custom("IBMPlexMono", size: 16))
                                .foregroundColor(ColorManager.shared.redColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#2A2A2A"))
                                .cornerRadius(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(selectedModels.isEmpty)
                        
                        Button(action: {
                            dismiss()
                        }) {
                            Text(NSLocalizedString("Cancel", comment: ""))
                                .font(.custom("IBMPlexMono", size: 16))
                                .foregroundColor(ColorManager.shared.greyTextColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: "#2A2A2A"))
                                .cornerRadius(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
            .padding(.bottom, 12)
            .safeAreaInset(edge: .top) {
                // Header
                VStack(spacing: 0) {
                    // Grab bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(ColorManager.shared.greenColor)
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 10)
                    
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "checklist")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(ColorManager.shared.redColor)
                            
                            Text(NSLocalizedString("UNUSED MODELS", comment: ""))
                                .font(.custom("IBMPlexMono", size: 12))
                                .foregroundColor(ColorManager.shared.redColor)
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
                    .padding(.bottom, 10)
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
    }
}

struct UnusedLLMModelRowView: View {
    let model: LLMModelInfo
    let isSelected: Bool
    let isLastItem: Bool
    let isActive: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(model.displayName)
                            .font(.custom("IBMPlexMono", size: 16))
                            .foregroundColor(ColorManager.shared.whiteTextColor)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        // "In Use" indicator for active model
                        if isActive {
                            Text("In Use")
                                .font(.custom("IBMPlexMono", size: 10))
                                .foregroundColor(ColorManager.shared.greenColor)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(ColorManager.shared.whiteTextColor)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            
            // Horizontal line under the item (only if not the last item)
            if !isLastItem {
                Rectangle()
                    .fill(Color(hex: "#333333"))
                    .frame(height: 1)
            }
        }
    }
}

 