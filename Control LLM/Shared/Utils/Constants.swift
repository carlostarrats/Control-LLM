//
//  Constants.swift
//  Control LLM
//
//  Created during Phase 3: Consistency of Limits
//  Centralizes all token and content length limits to prevent inconsistencies
//

import Foundation

/// Centralized constants for token and content length limits
/// This ensures consistency across all parts of the system
struct Constants {
    
    // MARK: - Token Limits (llama.cpp)
    
    /// Maximum tokens for llama.cpp (hard limit)
    static let maxTokens = 2048
    
    /// Safe token limit (80% of max to prevent edge cases)
    static let safeTokenLimit = 1638 // 2048 * 0.8
    
    // MARK: - Character Limits (Conservative estimates)
    
    /// Conservative character limit that safely fits within token limits
    /// 1 token ≈ 4 characters, so 3000 chars ≈ 750 tokens (well within 1638 safe limit)
    static let maxSafeCharacters = 4000 // Reduced to ensure chunks fit within 8192 token limit
    
    /// Maximum input length for file uploads (allows ~2-3 pages of content)
    static let maxInputLength = 8000
    
    /// Warning threshold for prompts approaching token limits
    static let warningThreshold = 3000
    
    /// Critical threshold where tokenization failures become likely
    static let criticalThreshold = 12000
    
    // MARK: - Buffer Sizes
    
    /// Buffer size for instruction overhead (newlines, separators, etc.)
    static let instructionBuffer = 200
    
    /// Buffer size for prompt overhead (formatting, context, etc.)
    static let promptBuffer = 200
    
    /// Minimum content length to ensure meaningful processing
    static let minContentLength = 500
    
    // MARK: - Multi-Pass Processing
    
    /// Default chunk size for multi-pass processing
    static let defaultChunkSize = 3000
    
    /// Maximum chunk size for multi-pass processing
    static let maxChunkSize = 3000
    
    // MARK: - Timeouts and Limits
    
    /// Maximum wait time for multi-pass processing (3 minutes)
    static let maxWaitTime = 180000 // milliseconds
    
    /// Required stable checks for response completion (4 seconds)
    static let requiredStableChecks = 8 // 8 * 0.5s = 4s
    
    /// Maximum polls for single-pass processing (15 seconds)
    static let maxSinglePassPolls = 150 // 150 * 0.1s = 15s
    
    /// Maximum polls for multi-pass processing (120 seconds)
    static let maxMultiPassPolls = 1200 // 1200 * 0.1s = 120s
    
    /// Maximum polls for clipboard messages (30 seconds)
    static let maxClipboardPolls = 300 // 300 * 0.1s = 30s
    
    // MARK: - Stop Button Reliability (Phase 4)
    
    /// Maximum time to wait for cancellation to take effect (100ms)
    static let maxCancellationWaitTime = 100 // milliseconds
    
    /// Number of cancellation checks per second during stop button press
    static let cancellationCheckFrequency = 10 // checks per second
    
    /// Maximum attempts to cancel generation before force stop
    static let maxCancellationAttempts = 3
    
    /// Timeout for stop button press feedback (50ms)
    static let stopButtonFeedbackTimeout = 50 // milliseconds
    
    // MARK: - Execution Flow Resilience (Phase 5)
    
    /// Maximum retry attempts for failed LLM operations
    static let maxLLMRetryAttempts = 3
    
    /// Delay between retry attempts (seconds)
    static let retryDelaySeconds = 2.0
    
    /// Maximum time to wait for LLM response before considering it stuck (seconds)
    static let maxLLMResponseTime = 300.0 // 5 minutes
    
    /// Maximum consecutive failures before aborting multi-pass processing
    static let maxConsecutiveFailures = 2
    
    /// Timeout for file processing operations (seconds)
    static let fileProcessingTimeout = 600.0 // 10 minutes
    
    /// Maximum memory usage threshold (MB) before cleanup
    static let maxMemoryThreshold = 512 // MB
    
    /// Minimum progress threshold for multi-pass processing (percentage)
    static let minProgressThreshold = 0.25 // 25%
    
    /// Recovery timeout for stuck operations (seconds)
    static let recoveryTimeout = 30.0
    
    /// Maximum number of partial results to preserve on failure
    static let maxPartialResults = 3
}
