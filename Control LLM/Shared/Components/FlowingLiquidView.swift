import SwiftUI
import MetalKit

struct FlowingLiquidView: View {
    @Binding var isSpeaking: Bool
    @State private var animationTime: Double = 0
    @State private var activationProgress: Float = 0.0  // NEW: smooth interpolation value
    @State private var animationTimer: Timer?
    
    var onTap: (() -> Void)?
    
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
                activationProgress: activationProgress  // Pass smooth value instead of binary
            )
            .frame(width: 400, height: 400) // KEEPING ORIGINAL SIZE - DON'T TOUCH RING
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
        .onAppear {
            // Initialize based on current speaking state
            activationProgress = isSpeaking ? 1.0 : 0.0
            startAnimation()
        }
        .onDisappear {
            animationTimer?.invalidate()
            animationTimer = nil
        }
        .onChange(of: isSpeaking) { _, newValue in
            // No need to do anything here - the animation loop handles the transition
            print("isSpeaking changed to: \(newValue)")
        }
    }
    
    private func startAnimation() {
        animationTimer?.invalidate()
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { timer in
            // Update animation time
            self.animationTime += 1.0/60.0
            
            // Calculate target based on current speaking state
            let target: Float = self.isSpeaking ? 1.0 : 0.0
            
            // Smoothly interpolate towards target
            let difference = target - self.activationProgress
            if abs(difference) > 0.001 {
                // Smooth interpolation - adjust 0.08 for different transition speeds
                self.activationProgress += difference * 0.08
                print("Smooth transition: \(self.activationProgress) -> \(target)")
            }
        }
    }
}

struct FlowingRingShaderView: UIViewRepresentable {
    let ringRadius: CGFloat
    let ringThickness: CGFloat
    let animationTime: Double
    let activationProgress: Float  // Changed from Bool to Float
    
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
        context.coordinator.activationProgress = activationProgress  // Pass smooth value
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
        var activationProgress: Float = 0.0  // Changed from isActivated
        
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
            uniforms[2] = ringThickness
            uniforms[3] = activationProgress  // Pass smooth interpolation value
            
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
    FlowingLiquidView(isSpeaking: .constant(false))
        .frame(width: 300, height: 320)
        .background(Color.black)
}
