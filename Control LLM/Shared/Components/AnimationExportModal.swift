import SwiftUI

struct AnimationExportModal: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var exportService = AnimationExportService()
    
    @State private var frameCount: Int = 60
    @State private var duration: Double = 3.0
    @State private var exportSize: CGSize = CGSize(width: 400, height: 400)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text(NSLocalizedString("Export MYCROFT Animation", comment: ""))
                        .font(.custom("IBMPlexMono", size: 18))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                    
                    Text(NSLocalizedString("Export frames as transparent PNGs", comment: ""))
                        .font(.custom("IBMPlexMono", size: 14))
                        .foregroundColor(Color(hex: "#666666"))
                }
                .padding(.top, 20)
                
                // Configuration
                VStack(spacing: 16) {
                    // Frame count
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("Frame Count", comment: ""))
                            .font(.custom("IBMPlexMono", size: 14))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                        
                        HStack {
                            Slider(value: Binding(
                                get: { Double(frameCount) },
                                set: { frameCount = Int($0) }
                            ), in: 30...120, step: 1)
                            .accentColor(Color(hex: "#FF00D0"))
                            
                            Text("\(frameCount)")
                                .font(.custom("IBMPlexMono", size: 14))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                    
                    // Duration
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("Duration (seconds)", comment: ""))
                            .font(.custom("IBMPlexMono", size: 14))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                        
                        HStack {
                            Slider(value: $duration, in: 1.0...10.0, step: 0.5)
                                .accentColor(Color(hex: "#FF00D0"))
                            
                            Text(String(format: "%.1f", duration))
                                .font(.custom("IBMPlexMono", size: 14))
                                .foregroundColor(Color(hex: "#BBBBBB"))
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                    
                    // Export size
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("Export Size", comment: ""))
                            .font(.custom("IBMPlexMono", size: 14))
                            .foregroundColor(Color(hex: "#BBBBBB"))
                        
                        Picker("Size", selection: $exportSize) {
                            Text("400x400").tag(CGSize(width: 400, height: 400))
                            Text("600x600").tag(CGSize(width: 600, height: 600))
                            Text("800x800").tag(CGSize(width: 800, height: 800))
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .accentColor(Color(hex: "#FF00D0"))
                    }
                }
                .padding(.horizontal, 20)
                
                // Preview
                VStack(spacing: 8) {
                    Text(NSLocalizedString("Preview", comment: ""))
                        .font(.custom("IBMPlexMono", size: 14))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                    
                    MycroftExportView(animationProgress: 0.0)
                        .frame(width: 200, height: 200)
                        .background(Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: "#333333"), lineWidth: 1)
                        )
                }
                
                Spacer()
                
                // Export button
                Button(action: {
                    Task {
                        await exportService.exportMycroftAnimation(
                            frameCount: frameCount,
                            duration: duration,
                            size: exportSize
                        )
                    }
                }) {
                    HStack {
                        if exportService.isExporting {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        
                        Text(exportService.isExporting ? NSLocalizedString("Exporting...", comment: "") : NSLocalizedString("Export Animation", comment: ""))
                            .font(.custom("IBMPlexMono", size: 16))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        exportService.isExporting 
                            ? Color(hex: "#666666") 
                            : Color(hex: "#FF00D0")
                    )
                    .cornerRadius(8)
                }
                .disabled(exportService.isExporting)
                .padding(.horizontal, 20)
                
                // Progress bar
                if exportService.isExporting {
                    VStack(spacing: 8) {
                        ProgressView(value: exportService.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#FF00D0")))
                        
                        Text(String(format: NSLocalizedString("Frame %d of %d", comment: ""), exportService.currentFrame, exportService.totalFrames))
                            .font(.custom("IBMPlexMono", size: 12))
                            .foregroundColor(Color(hex: "#666666"))
                    }
                    .padding(.horizontal, 20)
                }
                
                // Close button
                Button(NSLocalizedString("Close", comment: "")) {
                    dismiss()
                }
                .font(.custom("IBMPlexMono", size: 16))
                .foregroundColor(Color(hex: "#BBBBBB"))
                .padding(.bottom, 20)
            }
            .background(Color.black)
            .navigationBarHidden(true)
        }
        .background(Color.black)
    }
}

#Preview {
    AnimationExportModal()
        .background(Color.black)
}
