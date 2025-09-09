//
//  NetworkRequestBatcher.swift
//  Control LLM
//
//  Performance optimization for batching network requests
//

import Foundation
import Combine

// MARK: - Performance Optimization: Network Request Batcher

/// Batches network requests for better performance and reduced overhead
class NetworkRequestBatcher {
    static let shared = NetworkRequestBatcher()
    
    // MARK: - Properties
    
    private var pendingRequests: [String: BatchedRequest] = [:]
    private let batchQueue = DispatchQueue(label: "com.controlllm.network.batch", attributes: .concurrent)
    private var batchTimer: Timer?
    private let maxBatchSize = 10
    private let batchTimeout: TimeInterval = 2.0 // 2 seconds
    
    // Request types
    enum RequestType: String, CaseIterable {
        case modelDownload = "model_download"
        case fileUpload = "file_upload"
        case dataSync = "data_sync"
        case cacheUpdate = "cache_update"
    }
    
    enum RequestPriority: Int, CaseIterable {
        case critical = 0    // Model downloads, critical operations
        case high = 1        // File uploads, user-initiated
        case medium = 2      // Data sync, background operations
        case low = 3         // Cache updates, optimization
        
        var maxBatchSize: Int {
            switch self {
            case .critical: return 3
            case .high: return 5
            case .medium: return 8
            case .low: return 10
            }
        }
    }
    
    private init() {
        setupBatchTimer()
    }
    
    // MARK: - Public Methods
    
    /// Adds a request to the batch queue
    /// - Parameters:
    ///   - request: Network request to batch
    ///   - priority: Request priority
    /// - Returns: Task that will complete when the request is processed
    func addRequest<T: Codable>(
        _ request: NetworkRequest,
        priority: RequestPriority = .medium
    ) -> Task<T?, Error> {
        return Task {
            return try await withCheckedThrowingContinuation { continuation in
                batchQueue.async(flags: .barrier) {
                    let requestId = UUID().uuidString
                    let batchedRequest = BatchedRequest(
                        id: requestId,
                        request: request,
                        priority: priority,
                        continuation: continuation as! CheckedContinuation<Any?, Error>
                    )
                    
                    self.pendingRequests[requestId] = batchedRequest
                    
                    // Check if we should process immediately
                    if self.shouldProcessBatch(priority: priority) {
                        self.processBatch()
                    }
                }
            }
        }
    }
    
    /// Processes all pending requests immediately
    func flushAllRequests() {
        batchQueue.async(flags: .barrier) {
            self.processBatch()
        }
    }
    
    /// Gets current request count
    var currentRequestCount: Int {
        return batchQueue.sync { pendingRequests.count }
    }
    
    /// Checks if a specific request type is pending
    func hasPendingRequests(type: RequestType) -> Bool {
        return batchQueue.sync {
            return pendingRequests.contains { $0.value.request.type == type }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBatchTimer() {
        batchTimer = Timer.scheduledTimer(withTimeInterval: batchTimeout, repeats: true) { [weak self] _ in
            self?.batchQueue.async(flags: .barrier) {
                self?.processBatch()
            }
        }
    }
    
    private func shouldProcessBatch(priority: RequestPriority) -> Bool {
        let priorityRequests = pendingRequests.values.filter { $0.priority == priority }
        return priorityRequests.count >= priority.maxBatchSize
    }
    
    private func processBatch() {
        guard !pendingRequests.isEmpty else { return }
        
        let requests = pendingRequests
        pendingRequests.removeAll()
        
        // Group requests by priority
        let groupedRequests = Dictionary(grouping: requests.values) { $0.priority }
        
        // Process requests in priority order
        for priority in RequestPriority.allCases.sorted(by: { $0.rawValue < $1.rawValue }) {
            guard let priorityRequests = groupedRequests[priority] else { continue }
            
            Task {
                await processRequestsInBatch(priorityRequests)
            }
        }
    }
    
    private func processRequestsInBatch(_ requests: [BatchedRequest]) async {
        // Process requests in parallel within the same priority group
        await withTaskGroup(of: Void.self) { group in
            for request in requests {
                group.addTask {
                    await self.executeRequest(request)
                }
            }
        }
    }
    
    private func executeRequest(_ batchedRequest: BatchedRequest) async {
        do {
            let result = try await performNetworkRequest(batchedRequest.request)
            batchedRequest.continuation.resume(returning: result)
        } catch {
            batchedRequest.continuation.resume(throwing: error)
        }
    }
    
    private func performNetworkRequest(_ request: NetworkRequest) async throws -> Any? {
        // Simulate network request based on type
        switch request.type {
        case .modelDownload:
            return try await performModelDownload(request)
        case .fileUpload:
            return try await performFileUpload(request)
        case .dataSync:
            return try await performDataSync(request)
        case .cacheUpdate:
            return try await performCacheUpdate(request)
        }
    }
    
    // MARK: - Request Type Handlers
    
    private func performModelDownload(_ request: NetworkRequest) async throws -> Any? {
        // Simulate model download with progress tracking
        
        // Simulate download progress
        for i in 1...10 {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        }
        
        return ModelDownloadResult(
            modelName: request.url.lastPathComponent,
            downloadPath: request.url,
            success: true
        )
    }
    
    private func performFileUpload(_ request: NetworkRequest) async throws -> Any? {
        // Simulate file upload
        
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second
        
        return FileUploadResult(
            fileName: request.url.lastPathComponent,
            uploadPath: request.url,
            success: true
        )
    }
    
    private func performDataSync(_ request: NetworkRequest) async throws -> Any? {
        // Simulate data synchronization
        
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 second
        
        return DataSyncResult(
            syncId: UUID().uuidString,
            success: true
        )
    }
    
    private func performCacheUpdate(_ request: NetworkRequest) async throws -> Any? {
        // Simulate cache update
        
        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 second
        
        return CacheUpdateResult(
            cacheKey: request.url.lastPathComponent,
            success: true
        )
    }
    
    deinit {
        batchTimer?.invalidate()
    }
}

// MARK: - Supporting Types

struct NetworkRequest {
    let type: NetworkRequestBatcher.RequestType
    let url: URL
    let data: Data?
    let headers: [String: String]?
    let method: String
}

struct BatchedRequest {
    let id: String
    let request: NetworkRequest
    let priority: NetworkRequestBatcher.RequestPriority
    let continuation: CheckedContinuation<Any?, Error>
}

// MARK: - Result Types

struct ModelDownloadResult: Codable {
    let modelName: String
    let downloadPath: URL
    let success: Bool
}

struct FileUploadResult: Codable {
    let fileName: String
    let uploadPath: URL
    let success: Bool
}

struct DataSyncResult: Codable {
    let syncId: String
    let success: Bool
}

struct CacheUpdateResult: Codable {
    let cacheKey: String
    let success: Bool
}

// MARK: - Convenience Extensions

extension NetworkRequestBatcher {
    /// Downloads a model with batching
    func downloadModel(url: URL, headers: [String: String]? = nil) -> Task<ModelDownloadResult?, Error> {
        let request = NetworkRequest(
            type: .modelDownload,
            url: url,
            data: nil,
            headers: headers,
            method: "GET"
        )
        return addRequest(request, priority: .critical)
    }
    
    /// Uploads a file with batching
    func uploadFile(url: URL, data: Data, headers: [String: String]? = nil) -> Task<FileUploadResult?, Error> {
        let request = NetworkRequest(
            type: .fileUpload,
            url: url,
            data: data,
            headers: headers,
            method: "POST"
        )
        return addRequest(request, priority: .high)
    }
    
    /// Syncs data with batching
    func syncData(url: URL, data: Data? = nil, headers: [String: String]? = nil) -> Task<DataSyncResult?, Error> {
        let request = NetworkRequest(
            type: .dataSync,
            url: url,
            data: data,
            headers: headers,
            method: "POST"
        )
        return addRequest(request, priority: .medium)
    }
    
    /// Updates cache with batching
    func updateCache(url: URL, data: Data? = nil, headers: [String: String]? = nil) -> Task<CacheUpdateResult?, Error> {
        let request = NetworkRequest(
            type: .cacheUpdate,
            url: url,
            data: data,
            headers: headers,
            method: "PUT"
        )
        return addRequest(request, priority: .low)
    }
}
