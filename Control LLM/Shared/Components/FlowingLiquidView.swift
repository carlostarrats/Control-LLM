import SwiftUI
import MetalKit

// MARK: - Performance Optimization: Adaptive Frame Rate Manager
class AdaptiveFrameRateManager {
    static let shared = AdaptiveFrameRateManager()
    
    private var currentFPS: Double = 60
    private var performanceHistory: [Double] = []
    private let maxHistorySize = 10
    private var lastUpdateTime: Date = Date()
    
    private init() {
        // Start performance monitoring
        startPerformanceMonitoring()
    }
    
    func getOptimalFrameRate() -> Double {
        // Update performance metrics
        updatePerformanceMetrics()
        
        // Calculate average performance
        let averagePerformance = performanceHistory.isEmpty ? 1.0 : 
            performanceHistory.reduce(0, +) / Double(performanceHistory.count)
        
        // Adjust frame rate based on performance
        if averagePerformance < 0.7 {
            currentFPS = 24  // Very low performance
        } else if averagePerformance < 0.8 {
            currentFPS = 30  // Low performance
        } else if averagePerformance < 0.9 {
            currentFPS = 45  // Medium performance
        } else {
            currentFPS = 60  // High performance
        }
        
        // Check thermal state
        let thermalState = ProcessInfo.processInfo.thermalState
        if thermalState == .critical {
            currentFPS = min(currentFPS, 24)
        } else if thermalState == .serious {
            currentFPS = min(currentFPS, 30)
        }
        
        return currentFPS
    }
    
    private func startPerformanceMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updatePerformanceMetrics()
        }
    }
    
    private func updatePerformanceMetrics() {
        let now = Date()
        let timeSinceLastUpdate = now.timeIntervalSince(lastUpdateTime)
        
        if timeSinceLastUpdate >= 1.0 {
            // Calculate performance score (0.0 to 1.0)
            let performanceScore = calculatePerformanceScore()
            
            performanceHistory.append(performanceScore)
            if performanceHistory.count > maxHistorySize {
                performanceHistory.removeFirst()
            }
            
            lastUpdateTime = now
        }
    }
    
    private func calculatePerformanceScore() -> Double {
        // Simple performance calculation based on available memory and CPU usage
        let availableMemory = getAvailableMemory()
        let memoryScore = min(1.0, Double(availableMemory) / 1_000_000_000) // Normalize to 1GB
        
        // Basic CPU usage estimation (simplified)
        let cpuScore = 0.8 // Placeholder - would need more sophisticated monitoring
        
        return (memoryScore + cpuScore) / 2.0
    }
    
    private func getAvailableMemory() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        }
        
        return 0
    }
}

struct FlowingLiquidView: View {
    @State private var animationTime: Double = 0
    @State private var continuousAnimationTimer: Timer?  // For continuous motion
    @State private var isVisible = true
    
    // Ring configuration - KEEPING EXACTLY AS IT WAS
    private let ringRadius: CGFloat = 140
    private let ringThickness: CGFloat = 35
    
    var body: some View {
        ZStack {
            // Metal shader view for flowing ring - KEEPING ORIGINAL SIZE
            FlowingRingShaderView(
                ringRadius: ringRadius,
                ringThickness: ringThickness,
                animationTime: animationTime
            )
            .frame(width: 400, height: 400) // KEEPING ORIGINAL SIZE - DON'T TOUCH RING
            
            // SwiftUI ripple effect overlay when activated
            // DistortionRippleEffect removed - voice functionality disabled
                .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)


        .onChange(of: animationTime) { _, _ in
            // Force view update when animation time changes
        }
        .onAppear {
            // Always start in deactivated state and keep it there
            print("🎯 TARS onAppear - Starting with animationTime: \(animationTime)")
            
            isVisible = true
            // Start continuous animation timer for motion
            startContinuousAnimation()
        }
        .onDisappear {
            isVisible = false
            continuousAnimationTimer?.invalidate()
            continuousAnimationTimer = nil
            
            // Security: Clear Metal memory when view disappears
            MetalMemoryManager.shared.clearMetalMemory()
        }
        // Voice state change handling removed
    }
    
    private func startContinuousAnimation() {
        // PERFORMANCE OPTIMIZATION: Adaptive frame rate based on device performance
        let targetFPS = AdaptiveFrameRateManager.shared.getOptimalFrameRate()
        let frameInterval = 1.0 / targetFPS

        // PERFORMANCE OPTIMIZATION: Use CADisplayLink for smoother animations
        if #available(iOS 10.0, *) {
            startDisplayLinkAnimation(targetFPS: targetFPS)
        } else {
            // Fallback to Timer for older iOS versions
            continuousAnimationTimer = Timer.scheduledTimer(withTimeInterval: frameInterval, repeats: true) { _ in
                self.animationTime += frameInterval
            }
        }
    }
    
    @available(iOS 10.0, *)
    private func startDisplayLinkAnimation(targetFPS: Double) {
        // Use Timer instead of CADisplayLink for struct compatibility
        continuousAnimationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / targetFPS, repeats: true) { _ in
            self.updateAnimation()
        }
    }
    
    private func updateAnimation() {
        // PERFORMANCE OPTIMIZATION: Only update if view is visible
        guard isVisible else { return }
        
        // Update animation time with adaptive frame rate
        let targetFPS = AdaptiveFrameRateManager.shared.getOptimalFrameRate()
        let frameInterval = 1.0 / targetFPS
        animationTime += frameInterval
    }
}

struct FlowingRingShaderView: UIViewRepresentable {
    let ringRadius: CGFloat
    let ringThickness: CGFloat
    let animationTime: Double
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.framebufferOnly = false
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.enableSetNeedsDisplay = true
        mtkView.preferredFramesPerSecond = 60
        mtkView.backgroundColor = UIColor.clear
        mtkView.isOpaque = false
        mtkView.layer.backgroundColor = UIColor.clear.cgColor
        mtkView.layer.isOpaque = false
        mtkView.colorPixelFormat = .bgra8Unorm
        
        context.coordinator.setupMetal(mtkView: mtkView)
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.animationTime = Float(animationTime)
        context.coordinator.ringRadius = Float(ringRadius)
        context.coordinator.ringThickness = Float(ringThickness)
        uiView.setNeedsDisplay()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: FlowingRingShaderView
        var device: MTLDevice!
        var commandQueue: MTLCommandQueue!
        var pipelineState: MTLRenderPipelineState!
        var vertexBuffer: MTLBuffer!
        var uniformBuffer: MTLBuffer!
        
        var animationTime: Float = 0
        var ringRadius: Float = 140
        var ringThickness: Float = 35

        
        init(_ parent: FlowingRingShaderView) {
            self.parent = parent
            super.init()
        }
        
        deinit {
            // Security: Clear Metal resources on deinit
            cleanupMetalResources()
        }
        
        /// Cleans up Metal resources to prevent memory leaks
        func cleanupMetalResources() {
            // Clear command queue
            commandQueue = nil
            
            // Clear pipeline state
            pipelineState = nil
            
            // Clear buffers
            vertexBuffer = nil
            uniformBuffer = nil
            
            // Clear device reference
            device = nil
            
            SecureLogger.log("FlowingRingShaderView: Metal resources cleaned up")
        }
        
        func setupMetal(mtkView: MTKView) {
            device = mtkView.device
            commandQueue = device.makeCommandQueue()
            
            // Create vertex buffer for full-screen quad
            let vertices: [Float] = [
                -1.0, -1.0, 0.0, 0.0, 0.0,
                 1.0, -1.0, 0.0, 1.0, 0.0,
                 1.0,  1.0, 0.0, 1.0, 1.0,
                -1.0, -1.0, 0.0, 0.0, 0.0,
                 1.0,  1.0, 0.0, 1.0, 1.0,
                -1.0,  1.0, 0.0, 0.0, 1.0
            ]
            
            vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: [])
            uniformBuffer = device.makeBuffer(length: 2 * MemoryLayout<Float>.size, options: [])
            
            // Security: Register Metal buffers with MetalMemoryManager for secure cleanup
            if let vertexBuffer = vertexBuffer {
                MetalMemoryManager.shared.registerBuffer(vertexBuffer)
            }
            if let uniformBuffer = uniformBuffer {
                MetalMemoryManager.shared.registerBuffer(uniformBuffer)
            }
            
            let library = device.makeDefaultLibrary()
            let vertexFunction = library?.makeFunction(name: "vertexShader")
            let fragmentFunction = library?.makeFunction(name: "fragmentShader")
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
            
            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
            pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
            
            pipelineDescriptor.depthAttachmentPixelFormat = .invalid
            pipelineDescriptor.stencilAttachmentPixelFormat = .invalid
            
            do {
                pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                print("Failed to create pipeline state: \(error)")
            }
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let renderPassDescriptor = view.currentRenderPassDescriptor,
                  let commandBuffer = commandQueue.makeCommandBuffer(),
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                return
            }
            
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            renderPassDescriptor.colorAttachments[0].storeAction = .store
            
            let uniforms = uniformBuffer.contents().assumingMemoryBound(to: Float.self)
            uniforms[0] = animationTime
            uniforms[1] = ringRadius
            
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderEncoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
            
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
            
            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

#Preview {
            FlowingLiquidView()
        .frame(width: 300, height: 320)
        .background(Color.black)
}
