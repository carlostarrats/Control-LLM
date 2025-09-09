import SwiftUI
import Foundation
import Liquid

class AnimationExportService: ObservableObject {
    @Published var isExporting = false
    @Published var progress: Double = 0.0
    @Published var currentFrame: Int = 0
    @Published var totalFrames: Int = 0
    
    private let fileManager = FileManager.default
    
    func exportMycroftAnimation(
        frameCount: Int = 60,
        duration: Double = 3.0,
        size: CGSize = CGSize(width: 400, height: 400)
    ) async {
        await MainActor.run {
            isExporting = true
            progress = 0.0
            currentFrame = 0
            totalFrames = frameCount
        }
        
        // Create export directory
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            await MainActor.run {
                isExporting = false
            }
            return
        }
        
        let exportPath = documentsPath.appendingPathComponent("AnimationFrames")
        
        do {
            try fileManager.createDirectory(at: exportPath, withIntermediateDirectories: true)
        } catch {
            await MainActor.run {
                isExporting = false
            }
            return
        }
        
        // Export frames one by one
        for frameIndex in 0..<frameCount {
            let progress = Double(frameIndex) / Double(frameCount - 1)
            
            await MainActor.run {
                self.progress = progress
                self.currentFrame = frameIndex + 1
            }
            
            // Create and render frame on main actor
            let image = await MainActor.run {
                let frameView = MycroftExportView(animationProgress: progress)
                    .frame(width: size.width, height: size.height)
                    .background(Color.clear)
                
                let renderer = ImageRenderer(content: frameView)
                renderer.scale = 1.0
                
                return renderer.uiImage
            }
            
            if let image = image {
                // Save frame
                let filename = String(format: "frame_%04d.png", frameIndex)
                let fileURL = exportPath.appendingPathComponent(filename)
                
                if let pngData = image.pngData() {
                    try? pngData.write(to: fileURL)
                }
            }
            
            // Small delay to prevent memory issues
            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
        }
        
        await MainActor.run {
            isExporting = false
            progress = 1.0
        }
        
    }
}

// Export view for MYCROFT animation
struct MycroftExportView: View {
    let animationProgress: Double
    
    var body: some View {
        ZStack {
            // Deep background wave layer
            Liquid(samples: 50, period: 3.0)
                .frame(width: 400, height: 400)
                .foregroundColor(Color(hex: "#5D0C14"))
                .opacity(0.6)
                .blur(radius: 30)
                .offset(x: sin(animationProgress * 2 * .pi * 0.5) * 8,
                        y: cos(animationProgress * 2 * .pi * 0.5) * 6)
            
            // Mid-depth wave layer
            Liquid(samples: 20)
                .frame(width: 360, height: 360)
                .foregroundColor(Color(hex: "#D20001"))
                .opacity(0.3)
                .blur(radius: 20)
                .offset(x: cos(animationProgress * 2 * .pi * 0.6) * 6,
                        y: sin(animationProgress * 2 * .pi * 0.6) * 4)
            
            // Organic irregular ring 1 - Pink outer ring
            Ellipse()
                .fill(Color(hex: "#FF00D0"))
                .frame(width: 280 + sin(animationProgress * 2 * .pi * 1.2) * 32,
                       height: 280 + cos(animationProgress * 2 * .pi * 1.8) * 24)
                .scaleEffect(1.0 + sin(animationProgress * 2 * .pi * 0.8) * 0.08)
                .offset(x: sin(animationProgress * 2 * .pi * 1.0) * 6,
                        y: cos(animationProgress * 2 * .pi * 1.0) * 5)
                .blur(radius: 12)
                .opacity(0.8)
            
            // Organic irregular ring 2 - Red inner ring
            Ellipse()
                .fill(Color(hex: "#D20001"))
                .frame(width: 240 + cos(animationProgress * 2 * .pi * 1.5) * 28,
                       height: 240 + sin(animationProgress * 2 * .pi * 1.3) * 20)
                .scaleEffect(1.0 + cos(animationProgress * 2 * .pi * 0.9) * 0.06)
                .offset(x: cos(animationProgress * 2 * .pi * 1.1) * 4,
                        y: sin(animationProgress * 2 * .pi * 1.1) * 3)
                .blur(radius: 8)
                .opacity(0.7)
            
            // Core ring - Bright red center
            Ellipse()
                .fill(Color(hex: "#FF0000"))
                .frame(width: 180 + sin(animationProgress * 2 * .pi * 2.0) * 20,
                       height: 180 + cos(animationProgress * 2 * .pi * 1.7) * 16)
                .scaleEffect(1.0 + sin(animationProgress * 2 * .pi * 1.0) * 0.04)
                .offset(x: sin(animationProgress * 2 * .pi * 1.2) * 2,
                        y: cos(animationProgress * 2 * .pi * 1.2) * 2)
                .blur(radius: 4)
                .opacity(0.9)
        }
    }
}
