import SwiftUI
import MetalKit
import simd

struct RippleView: UIViewRepresentable {
    let rippleCenter: CGPoint
    let rippleTime: Float
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("RippleView: Metal is not supported on this device")
            return mtkView
        }
        
        mtkView.device = device
        mtkView.framebufferOnly = false
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.backgroundColor = UIColor.clear
        mtkView.enableSetNeedsDisplay = true // Enable setNeedsDisplay mode
        mtkView.isPaused = true // Start paused, we'll control when to draw
        
        context.coordinator.setupMetal(mtkView: mtkView)
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.rippleCenter = rippleCenter
        context.coordinator.rippleTime = rippleTime
        // Force the Metal view to redraw when parameters change
        uiView.setNeedsDisplay()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: RippleView
        var device: MTLDevice?
        var commandQueue: MTLCommandQueue?
        var pipelineState: MTLRenderPipelineState?
        var vertexBuffer: MTLBuffer?
        var rippleCenterBuffer: MTLBuffer?
        var rippleTimeBuffer: MTLBuffer?
        var rippleCenter: CGPoint = .zero
        var rippleTime: Float = 0.0
        
        init(_ parent: RippleView) {
            self.parent = parent
            super.init()
        }
        
        func setupMetal(mtkView: MTKView) {
            guard let device = mtkView.device else {
                print("RippleView: Metal device is nil")
                return
            }
            
            self.device = device
            
            guard let commandQueue = device.makeCommandQueue() else {
                print("RippleView: Failed to create command queue")
                return
            }
            
            self.commandQueue = commandQueue
            
            // Create vertex data for a full-screen quad (position + texCoord)
            let vertices: [Float] = [
                -1.0, -1.0, 0.0, 0.0, 0.0, 0.0,  // position, texCoord
                 1.0, -1.0, 0.0, 1.0, 0.0, 0.0,
                 1.0,  1.0, 0.0, 1.0, 1.0, 0.0,
                -1.0,  1.0, 0.0, 0.0, 1.0, 0.0
            ]
            
            guard let vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: []) else {
                print("RippleView: Failed to create vertex buffer")
                return
            }
            
            self.vertexBuffer = vertexBuffer
            
            // Create buffers for shader parameters
            guard let rippleCenterBuffer = device.makeBuffer(length: MemoryLayout<simd_float2>.size, options: []) else {
                print("RippleView: Failed to create ripple center buffer")
                return
            }
            
            guard let rippleTimeBuffer = device.makeBuffer(length: MemoryLayout<Float>.size, options: []) else {
                print("RippleView: Failed to create ripple time buffer")
                return
            }
            
            self.rippleCenterBuffer = rippleCenterBuffer
            self.rippleTimeBuffer = rippleTimeBuffer
            
            // Load shader
            guard let library = device.makeDefaultLibrary() else {
                print("RippleView: Failed to create Metal library")
                return
            }
            
            guard let vertexFunction = library.makeFunction(name: "vertex_main") else {
                print("RippleView: Failed to create vertex function")
                return
            }
            
            guard let fragmentFunction = library.makeFunction(name: "fragment_main") else {
                print("RippleView: Failed to create fragment function")
                return
            }
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
            
            // Enable alpha blending for the ripple effect
            let colorAttachment = pipelineDescriptor.colorAttachments[0]!
            colorAttachment.isBlendingEnabled = true
            colorAttachment.sourceRGBBlendFactor = .sourceAlpha
            colorAttachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
            colorAttachment.sourceAlphaBlendFactor = .sourceAlpha
            colorAttachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
            do {
                pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                print("RippleView: Failed to create pipeline state: \(error)")
            }
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            // Check if Metal is properly initialized
            guard let _ = device,
                  let commandQueue = commandQueue,
                  let pipelineState = pipelineState,
                  let vertexBuffer = vertexBuffer,
                  let rippleCenterBuffer = rippleCenterBuffer,
                  let rippleTimeBuffer = rippleTimeBuffer,
                  let drawable = view.currentDrawable,
                  let commandBuffer = commandQueue.makeCommandBuffer(),
                  let renderPassDescriptor = view.currentRenderPassDescriptor,
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                return
            }
            
            // Normalize coordinates
            let normalizedCenter = CGPoint(
                x: rippleCenter.x / view.bounds.width,
                y: rippleCenter.y / view.bounds.height
            )
            
            // Update shader parameters
            var center = simd_float2(Float(normalizedCenter.x), Float(normalizedCenter.y))
            rippleCenterBuffer.contents().copyMemory(from: &center, byteCount: MemoryLayout<simd_float2>.size)
            
            var time = rippleTime
            rippleTimeBuffer.contents().copyMemory(from: &time, byteCount: MemoryLayout<Float>.size)
            
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderEncoder.setFragmentBuffer(rippleCenterBuffer, offset: 0, index: 0)
            renderEncoder.setFragmentBuffer(rippleTimeBuffer, offset: 0, index: 1)
            
            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            renderEncoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
} 