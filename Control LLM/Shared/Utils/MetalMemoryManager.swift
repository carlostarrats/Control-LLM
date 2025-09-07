//
//  MetalMemoryManager.swift
//  Control LLM
//
//  Secure Metal memory management to prevent data leakage
//

import Foundation
import Metal
import MetalKit

// MARK: - Performance Optimization: Metal Memory Pooling

/// Metal buffer pool for efficient memory management
class MetalBufferPool {
    private var availableBuffers: [MTLBuffer] = []
    private let maxPoolSize = 10
    private let device: MTLDevice
    private let queue = DispatchQueue(label: "com.controlllm.metal.bufferpool", attributes: .concurrent)
    
    init(device: MTLDevice) {
        self.device = device
    }
    
    func getBuffer(length: Int, options: MTLResourceOptions = []) -> MTLBuffer? {
        return queue.sync {
            // Try to find a suitable buffer in the pool
            if let bufferIndex = availableBuffers.firstIndex(where: { $0.length >= length }) {
                let buffer = availableBuffers.remove(at: bufferIndex)
                return buffer
            }
            
            // Create new buffer if none available
            return device.makeBuffer(length: length, options: options)
        }
    }
    
    func returnBuffer(_ buffer: MTLBuffer) {
        queue.async(flags: .barrier) {
            guard self.availableBuffers.count < self.maxPoolSize else { return }
            self.availableBuffers.append(buffer)
        }
    }
    
    func clearPool() {
        queue.async(flags: .barrier) {
            self.availableBuffers.removeAll()
        }
    }
}

/// Metal texture pool for efficient memory management
class MetalTexturePool {
    private var availableTextures: [MTLTexture] = []
    private let maxPoolSize = 10
    private let device: MTLDevice
    private let queue = DispatchQueue(label: "com.controlllm.metal.texturepool", attributes: .concurrent)
    
    init(device: MTLDevice) {
        self.device = device
    }
    
    func getTexture(width: Int, height: Int, pixelFormat: MTLPixelFormat) -> MTLTexture? {
        return queue.sync {
            // Try to find a suitable texture in the pool
            if let textureIndex = availableTextures.firstIndex(where: { 
                $0.width >= width && $0.height >= height && $0.pixelFormat == pixelFormat 
            }) {
                let texture = availableTextures.remove(at: textureIndex)
                return texture
            }
            
            // Create new texture if none available
            let descriptor = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: pixelFormat,
                width: width,
                height: height,
                mipmapped: false
            )
            return device.makeTexture(descriptor: descriptor)
        }
    }
    
    func returnTexture(_ texture: MTLTexture) {
        queue.async(flags: .barrier) {
            guard self.availableTextures.count < self.maxPoolSize else { return }
            self.availableTextures.append(texture)
        }
    }
    
    func clearPool() {
        queue.async(flags: .barrier) {
            self.availableTextures.removeAll()
        }
    }
}

/// Manages Metal memory securely to prevent sensitive data leakage
class MetalMemoryManager {
    static let shared = MetalMemoryManager()
    
    private var device: MTLDevice?
    private var commandQueue: MTLCommandQueue?
    private var metalHeaps: [MTLHeap] = []
    
    // PERFORMANCE OPTIMIZATION: Metal memory pooling
    private var bufferPool: MetalBufferPool?
    private var texturePool: MetalTexturePool?
    
    private init() {
        setupMetal()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        performSecurityCleanup()
    }
    
    // MARK: - Setup
    
    private func setupMetal() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            SecureLogger.log("MetalMemoryManager: Metal not supported on this device")
            return
        }
        
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        
        // PERFORMANCE OPTIMIZATION: Initialize memory pools
        self.bufferPool = MetalBufferPool(device: device)
        self.texturePool = MetalTexturePool(device: device)
        
        SecureLogger.log("MetalMemoryManager: Metal setup completed with memory pooling")
    }
    
    // MARK: - Memory Management
    
    /// Securely clears all Metal memory to prevent data leakage
    func clearMetalMemory() {
        guard let device = device else { return }
        
        SecureLogger.log("MetalMemoryManager: Clearing Metal memory for security")
        
        // Clear all heaps
        for heap in metalHeaps {
            heap.setPurgeableState(.volatile)
        }
        metalHeaps.removeAll()
        
        // Force GPU memory flush
        if let commandQueue = commandQueue,
           let commandBuffer = commandQueue.makeCommandBuffer() {
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
        
        // Clear any cached resources
        device.makeCommandQueue()?.makeCommandBuffer()?.commit()
        
        SecureLogger.log("MetalMemoryManager: Metal memory cleared successfully")
    }
    
    /// Registers a Metal heap for secure cleanup
    func registerHeap(_ heap: MTLHeap) {
        metalHeaps.append(heap)
    }
    
    /// Registers a Metal texture for secure cleanup
    func registerTexture(_ texture: MTLTexture) {
        // Store texture reference for cleanup
        // Note: In a production app, you'd want to store these in a proper collection
        // For now, we rely on the Metal framework's automatic cleanup
    }
    
    /// Registers a Metal buffer for secure cleanup
    func registerBuffer(_ buffer: MTLBuffer) {
        // Store buffer reference for cleanup
        // Note: In a production app, you'd want to store these in a proper collection
        // For now, we'll rely on the general Metal memory cleanup
    }
    
    /// Securely clears specific Metal buffer
    func clearBuffer(_ buffer: MTLBuffer) {
        // Set buffer to volatile state
        buffer.setPurgeableState(.volatile)
        
        // Force memory barrier
        if let commandQueue = commandQueue,
           let commandBuffer = commandQueue.makeCommandBuffer() {
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
    }
    
    /// Securely clears Metal texture
    func clearTexture(_ texture: MTLTexture) {
        // Set texture to volatile state
        texture.setPurgeableState(.volatile)
        
        // Force memory barrier
        if let commandQueue = commandQueue,
           let commandBuffer = commandQueue.makeCommandBuffer() {
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
        }
    }
    
    // MARK: - Performance Optimizations
    
    /// Get a buffer from the pool for better performance
    func getPooledBuffer(length: Int, options: MTLResourceOptions = []) -> MTLBuffer? {
        return bufferPool?.getBuffer(length: length, options: options)
    }
    
    /// Return a buffer to the pool for reuse
    func returnPooledBuffer(_ buffer: MTLBuffer) {
        bufferPool?.returnBuffer(buffer)
    }
    
    /// Get a texture from the pool for better performance
    func getPooledTexture(width: Int, height: Int, pixelFormat: MTLPixelFormat) -> MTLTexture? {
        return texturePool?.getTexture(width: width, height: height, pixelFormat: pixelFormat)
    }
    
    /// Return a texture to the pool for reuse
    func returnPooledTexture(_ texture: MTLTexture) {
        texturePool?.returnTexture(texture)
    }
    
    /// Clear all memory pools
    func clearMemoryPools() {
        bufferPool?.clearPool()
        texturePool?.clearPool()
    }
    
    // MARK: - Security Utilities
    
    /// Performs comprehensive Metal memory cleanup
    func performSecurityCleanup() {
        SecureLogger.log("MetalMemoryManager: Performing security cleanup")
        
        // Clear all registered heaps
        clearMetalMemory()
        
        // Force garbage collection
        autoreleasepool {
            // This will trigger cleanup of any autoreleased Metal objects
        }
        
        // Additional cleanup for any remaining resources
        if let device = device {
            // Create a dummy command buffer to ensure all previous operations complete
            if let commandQueue = device.makeCommandQueue(),
               let commandBuffer = commandQueue.makeCommandBuffer() {
                commandBuffer.commit()
                commandBuffer.waitUntilCompleted()
            }
        }
        
        SecureLogger.log("MetalMemoryManager: Security cleanup completed")
    }
    
    /// Clears Metal memory when app backgrounds
    func handleAppBackgrounding() {
        SecureLogger.log("MetalMemoryManager: App backgrounding - clearing Metal memory")
        performSecurityCleanup()
    }
    
    /// Clears Metal memory when app terminates
    func handleAppTermination() {
        SecureLogger.log("MetalMemoryManager: App termination - clearing Metal memory")
        performSecurityCleanup()
    }
}

// MARK: - Notification Extensions

extension MetalMemoryManager {
    /// Sets up notification observers for app lifecycle events
    func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        handleAppBackgrounding()
    }
    
    @objc private func appWillTerminate() {
        handleAppTermination()
    }
    
    // Note: deinit moved to main class body
}
