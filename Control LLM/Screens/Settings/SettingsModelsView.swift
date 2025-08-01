import SwiftUI

struct SettingsModelsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var activeModel: String = "llama-3.2-3b-instruct-4bit"
    @State private var selectedModelsToDownload: Set<String> = ["deepseek-r1-distill-qwen-1.5b-8bit"]
    @State private var downloadingModel: String? = nil
    @State private var downloadProgress: Double = 0.0
    @State private var installedModelsList: [Model] = [
        Model(name: "llama-3.2-3b-instruct-4bit", size: "1.8 GB")
    ]
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
                        Text("INSTALLED")
                            .font(.custom("IBMPlexMono", size: 14))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 0) {
                            ForEach(installedModels, id: \.name) { model in
                                InstalledModelView(
                                    model: model,
                                    isActive: activeModel == model.name,
                                    onSelect: {
                                        activeModel = model.name
                                    },
                                    onDelete: {
                                        // Only allow deletion if not active
                                        if activeModel != model.name {
                                            // TODO: Implement actual deletion
                                        }
                                    }
                                )
                            }
                                            }
                    .padding(.horizontal, 20)
                }
                
                // 30px spacing between sections
                Spacer()
                    .frame(height: 30)
                
                // Available Downloads section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AVAILABLE DOWNLOADS")
                            .font(.custom("IBMPlexMono", size: 14))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .padding(.horizontal, 24)
                        
                                                VStack(spacing: 0) {
                            ForEach(availableModels, id: \.name) { model in
                                AvailableModelView(
                                    model: model,
                                    isSelected: false, // No longer using selection
                                    isDownloading: downloadingModel == model.name,
                                    downloadProgress: downloadProgress,
                                    onToggle: {
                                        // No longer needed
                                    },
                                    onDownload: {
                                        if downloadingModel == model.name {
                                            // Stop download
                                            downloadingModel = nil
                                            downloadProgress = 0.0
                                        } else if downloadingModel == nil {
                                            // Start download
                                            downloadingModel = model.name
                                            downloadProgress = 0.0
                                            
                                            // Simulate download progress
                                            simulateDownload(for: model.name)
                                        }
                                    }
                                )
                            }
                        }
                    .padding(.horizontal, 20)
                }
                
                // 30px spacing between sections
                Spacer()
                    .frame(height: 30)
                
                // Install your own model section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("INSTALL YOUR OWN")
                            .font(.custom("IBMPlexMono", size: 14))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 0) {
                                                    Button(action: {
                            // TODO: Implement install your own model functionality
                        }) {
                            HStack {
                                Text("Install Your Own Model")
                                    .font(.custom("IBMPlexMono", size: 16))
                                    .foregroundColor(Color(hex: "#EEEEEE"))
                                    .multilineTextAlignment(.leading)
                                
                                                    Spacer()
                    
                    Image(systemName: "arrow.down.square")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#BBBBBB"))
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
                        .padding(.horizontal, 20)
                    }
                }
                
                // 60px spacing from Install Your Own section
                Spacer()
                    .frame(height: 60)
                
                // Manage Unused Models text
                Button(action: {
                    showingUnusedModelsSheet = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checklist")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#FF6B6B"))
                        
                        Text("Manage Unused Models")
                            .font(.custom("IBMPlexMono", size: 16))
                            .foregroundColor(Color(hex: "#FF6B6B"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                .padding(.bottom, 20)
            }
            .safeAreaInset(edge: .top) {
                // Header
                VStack(spacing: 0) {
                    // Grab bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(hex: "#666666"))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "terminal")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                            
                            Text("Models")
                                .font(.custom("IBMPlexMono", size: 20))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                        }
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
                    .padding(.bottom, 20)
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
        .sheet(isPresented: $showingUnusedModelsSheet) {
            UnusedModelsSheet(
                installedModels: installedModelsList,
                activeModel: activeModel,
                selectedModels: $selectedUnusedModels,
                onDelete: {
                    // Delete selected unused models
                    for modelName in selectedUnusedModels {
                        installedModelsList.removeAll { $0.name == modelName }
                    }
                    selectedUnusedModels.removeAll()
                }
            )
            .presentationDetents(unusedModelsCount == 0 ? [.height(200)] : [.medium])
        }
    }
    
    private var installedModels: [Model] {
        installedModelsList
    }
    
    private var availableModels: [Model] {
        [
            Model(name: "deepseek-r1-distill-qwen-1.5b-4bit", size: "1 GB"),
            Model(name: "deepseek-r1-distill-qwen-1.5b-8bit", size: "1.9 GB"),
            Model(name: "llama-3.2-1b-instruct-4bit", size: "0.7 GB")
        ]
    }
    
    private var unusedModelsCount: Int {
        installedModelsList.filter { $0.name != activeModel }.count
    }
    
    private func simulateDownload(for modelName: String) {
        // Simulate download progress
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if downloadingModel == modelName {
                downloadProgress += 0.01
                
                if downloadProgress >= 1.0 {
                    // Download complete
                    timer.invalidate()
                    downloadingModel = nil
                    downloadProgress = 0.0
                    
                    // Move model from available to installed
                    if let model = availableModels.first(where: { $0.name == modelName }) {
                        // Add to installed models
                        installedModelsList.append(model)
                        // Remove from selected (no longer needed since we're not using selection)
                        selectedModelsToDownload.remove(modelName)
                    }
                }
            } else {
                timer.invalidate()
            }
        }
    }
}

struct Model: Identifiable {
    let id = UUID()
    let name: String
    let size: String
}

struct InstalledModelView: View {
    let model: Model
    let isActive: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onSelect) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(model.name)
                            .font(.custom("IBMPlexMono", size: 16))
                            .foregroundColor(Color(hex: "#EEEEEE"))
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        Text(model.size)
                            .font(.custom("IBMPlexMono", size: 10))
                            .foregroundColor(Color(hex: "#FF6B6B"))
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // Active checkmark or empty circle
                    Image(systemName: isActive ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#BBBBBB"))
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
}

struct AvailableModelView: View {
    let model: Model
    let isSelected: Bool
    let isDownloading: Bool
    let downloadProgress: Double
    let onToggle: () -> Void
    let onDownload: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(model.name)
                            .font(.custom("IBMPlexMono", size: 16))
                            .foregroundColor(Color(hex: "#EEEEEE"))
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        Text(model.size)
                            .font(.custom("IBMPlexMono", size: 10))
                            .foregroundColor(Color(hex: "#FF6B6B"))
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // Download button
                    Button(action: onDownload) {
                        Image(systemName: isDownloading ? "stop.square" : "arrow.down.square")
                            .font(.system(size: 20))
                            .foregroundColor(isDownloading ? Color(hex: "#FF6B6B") : Color(hex: "#BBBBBB"))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            
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
                    Text("Installing [\(Int(downloadProgress * 100))%]")
                        .font(.custom("IBMPlexMono", size: 10))
                        .foregroundColor(Color(hex: "#F8C762"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                        .padding(.bottom, 12)
                }
                .padding(.horizontal, 4)
                .padding(.top, 8)
            }
            
            // Horizontal line under the item
            Rectangle()
                .fill(Color(hex: "#333333"))
                .frame(height: 1)
        }
    }
} 

struct UnusedModelsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let installedModels: [Model]
    let activeModel: String
    @Binding var selectedModels: Set<String>
    let onDelete: () -> Void
    
    private var unusedModels: [Model] {
        installedModels.filter { $0.name != activeModel }
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
                    Text(unusedModels.isEmpty ? "No Unused Models" : "Delete your unused models.")
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(unusedModels.isEmpty ? Color(hex: "#FF6B6B") : Color(hex: "#EEEEEE"))
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
                                ForEach(Array(unusedModels.enumerated()), id: \.element.name) { index, model in
                                    UnusedModelRowView(
                                        model: model,
                                        isSelected: selectedModels.contains(model.name),
                                        isLastItem: index == unusedModels.count - 1,
                                        onToggle: {
                                            if selectedModels.contains(model.name) {
                                                selectedModels.remove(model.name)
                                            } else {
                                                selectedModels.insert(model.name)
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
                            onDelete()
                            dismiss()
                        }) {
                            Text(selectedModels.count <= 1 ? "Delete Model" : "Delete Models")
                                .font(.custom("IBMPlexMono", size: 16))
                                .foregroundColor(Color(hex: "#FF6B6B"))
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
                            Text("Cancel")
                                .font(.custom("IBMPlexMono", size: 16))
                                .foregroundColor(Color(hex: "#BBBBBB"))
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
            .padding(.bottom, 20)
            .safeAreaInset(edge: .top) {
                // Header
                VStack(spacing: 0) {
                    // Grab bar
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color(hex: "#666666"))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    
                    // Header
                    HStack {
                        Text("Unused Models")
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
                    .padding(.bottom, 20)
                }
                .background(
                    Color(hex: "#1D1D1D")
                )
            }
        }
    }
}

struct UnusedModelRowView: View {
    let model: Model
    let isSelected: Bool
    let isLastItem: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack(alignment: .top) {
                    Text(model.name)
                        .font(.custom("IBMPlexMono", size: 16))
                        .foregroundColor(Color(hex: "#EEEEEE"))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    // Selection indicator
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#BBBBBB"))
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