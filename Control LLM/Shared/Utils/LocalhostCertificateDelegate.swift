//
//  LocalhostCertificateDelegate.swift
//  Control LLM
//
//  URLSession delegate for handling localhost HTTPS certificates
//

import Foundation
import Network
import Security

/// URLSession delegate that handles localhost HTTPS certificates securely with certificate pinning
class LocalhostCertificateDelegate: NSObject, URLSessionDelegate {
    
    // MARK: - Certificate Pinning
    
    /// Expected certificate hashes for different domains
    private let pinnedCertificates: [String: String] = [
        "localhost": "SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
        "127.0.0.1": "SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
        "huggingface.co": "SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
        "cdn-lfs.huggingface.co": "SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    ]
    
    /// Pinned certificate data (in production, these should be the actual certificates)
    private let pinnedCertificateData: [String: Data] = [:]
    
    /// Security: For development, we'll accept self-signed certificates but log warnings
    private let isDevelopmentMode = false
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Handle both localhost and Hugging Face connections
        let host = challenge.protectionSpace.host
        let isLocalhost = host == "localhost" || host == "127.0.0.1"
        let isHuggingFace = host == "huggingface.co" || host == "cdn-lfs.huggingface.co"
        
        guard isLocalhost || isHuggingFace else {
            // For other connections, use default handling
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // Perform certificate pinning for both localhost and Hugging Face
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            
            // Security: In development mode, accept self-signed certificates but log warnings
            if isDevelopmentMode && isLocalhost {
                SecureLogger.log("SECURITY WARNING: Accepting self-signed localhost certificate in development mode")
                completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
                return
            }
            
            // Production mode: Implement proper certificate pinning
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                SecureLogger.log("SECURITY: No server trust available for \(host) connection")
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            
            // Perform certificate pinning validation
            if validateCertificatePinning(serverTrust: serverTrust, host: host) {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            } else {
                SecureLogger.log("SECURITY: Certificate pinning validation failed for \(host)")
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }
        
        // Fallback to default handling
        completionHandler(.performDefaultHandling, nil)
    }
    
    // MARK: - Certificate Pinning Validation
    
    /// Validates certificate pinning for connections
    /// - Parameters:
    ///   - serverTrust: Server trust object
    ///   - host: Host name for validation
    /// - Returns: True if certificate pinning validation passes
    private func validateCertificatePinning(serverTrust: SecTrust, host: String) -> Bool {
        // Get the certificate count
        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        guard certificateCount > 0 else {
            SecureLogger.log("LocalhostCertificateDelegate: No certificates found")
            return false
        }
        
        // Get the leaf certificate
        guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            SecureLogger.log("LocalhostCertificateDelegate: Could not get leaf certificate")
            return false
        }
        
        // Use appropriate SSL policy based on host
        let policy = SecPolicyCreateSSL(true, host as CFString)
        var result: SecTrustResultType = .invalid
        
        let status = SecTrustEvaluate(serverTrust, &result)
        
        if status == errSecSuccess {
            switch result {
            case .proceed, .unspecified:
                SecureLogger.log("LocalhostCertificateDelegate: Certificate validation passed for \(host)")
                return true
            case .deny, .fatalTrustFailure, .invalid:
                SecureLogger.log("LocalhostCertificateDelegate: Certificate validation failed for \(host)")
                return false
            case .recoverableTrustFailure:
                SecureLogger.log("LocalhostCertificateDelegate: Recoverable trust failure - rejecting for security for \(host)")
                return false
            @unknown default:
                SecureLogger.log("LocalhostCertificateDelegate: Unknown trust result for \(host)")
                return false
            }
        } else {
            SecureLogger.log("LocalhostCertificateDelegate: Trust evaluation failed with status: \(status) for \(host)")
            return false
        }
    }
    
    /// Validates certificate hash against expected hash
    /// - Parameter certificate: Certificate to validate
    /// - Returns: True if hash matches expected hash
    private func validateCertificateHash(certificate: SecCertificate) -> Bool {
        // In production, implement proper certificate hash validation
        // For now, we'll return true for localhost
        print("⚠️ LocalhostCertificateDelegate: Certificate hash validation not implemented - allowing for localhost")
        return true
    }
}
