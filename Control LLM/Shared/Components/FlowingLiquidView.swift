import SwiftUI
import MetalKit

struct FlowingLiquidView: View {
    // Voice functionality removed
    @State private var animationTime: Double = 0
    @State private var localActivationProgress: Float = 0.0  // LOCAL activation state for TARS only
    @State private var animationTimer: Timer?
    @State private var continuousAnimationTimer: Timer?  // For continuous motion
    
    // Voice Integration removed
    

    
    // Ring configuration - KEEPING EXACTLY AS IT WAS
    private let ringRadius: CGFloat = 140
    private let ringThickness: CGFloat = 35
    
    var body: some View {
        ZStack {
            // Metal shader view for flowing ring - KEEPING ORIGINAL SIZE
            FlowingRingShaderView(
                ringRadius: ringRadius,
                ringThickness: ringThickness,
                animationTime: animationTime,
                activationProgress: localActivationProgress
            )
            .frame(width: 400, height: 400) // KEEPING ORIGINAL SIZE - DON'T TOUCH RING
            
            // SwiftUI ripple effect overlay when activated
            // DistortionRippleEffect removed - voice functionality disabled
                .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)


        .onChange(of: localActivationProgress) { _, _ in
            // Force view update when activation progress changes
        }
        .onAppear {
            // Always start in deactivated state and keep it there
            localActivationProgress = 0.0
            print("🎯 TARS onAppear - Starting with localActivationProgress: \(localActivationProgress)")
            
            // Start continuous animation timer for motion
            startContinuousAnimation()
        }
        .onDisappear {
            animationTimer?.invalidate()
            animationTimer = nil
            continuousAnimationTimer?.invalidate()
            continuousAnimationTimer = nil
        }
        // Voice state change handling removed
    }
    
    private func startContinuousAnimation() {
        // Start continuous animation timer for motion - reduced to 30 FPS for less heat
        continuousAnimationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { _ in
            // Update animation time continuously for motion
            self.animationTime += 1.0/30.0
        }
    }
    
    private func startAnimation(target: Float) {
        // Only start timer if it's not already running
        guard animationTimer == nil else { return }
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { timer in
            // Only interpolate if there's a meaningful difference
            let difference = target - self.localActivationProgress
            
            if abs(difference) > 0.001 {
                // Smooth interpolation - adjust 0.08 for different transition speeds
                self.localActivationProgress += difference * 0.08
                print("🔄 TARS Timer - target: \(target), current: \(self.localActivationProgress), difference: \(difference)")
            } else if abs(difference) <= 0.001 {
                // Stop the timer when we reach the target
                timer.invalidate()
                self.animationTimer = nil
                print("🛑 TARS Timer - Reached target, stopping timer")
            }
        }
    }
}

struct FlowingRingShaderView: UIViewRepresentable {
    let ringRadius: CGFloat
    let ringThickness: CGFloat
    let animationTime: Double
    let activationProgress: Float
    
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
        context.coordinator.activationProgress = activationProgress
        print("🎨 Metal View Update - activationProgress: \(activationProgress)")
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
        var activationProgress: Float = 0.0

        
        init(_ parent: FlowingRingShaderView) {
            self.parent = parent
            super.init()
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
            uniformBuffer = device.makeBuffer(length: 4 * MemoryLayout<Float>.size, options: [])
            
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
            uniforms[2] = activationProgress  // This is what the shader expects
            uniforms[3] = ringThickness       // This is unused by the shader
            
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
