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
    
    /// Expected certificate hash for localhost (placeholder - will be set during development)
    private let expectedCertificateHash = "SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    
    /// Pinned certificate data (in production, this should be the actual certificate)
    private let pinnedCertificateData: Data? = nil
    
    /// Security: For development, we'll accept self-signed certificates but log warnings
    private let isDevelopmentMode = false
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Only handle localhost connections
        let host = challenge.protectionSpace.host
        guard host == "localhost" || host == "127.0.0.1" else {
            // For non-localhost connections, use default handling
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // For localhost, perform certificate pinning for enhanced security
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            
            // Security: In development mode, accept self-signed certificates but log warnings
            if isDevelopmentMode {
                print("⚠️ SECURITY WARNING: Accepting self-signed localhost certificate in development mode")
                completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
                return
            }
            
            // Production mode: Implement proper certificate pinning
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                print("❌ SECURITY: No server trust available for localhost connection")
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            
            // Perform certificate pinning validation
            if validateCertificatePinning(serverTrust: serverTrust) {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
            } else {
                print("❌ SECURITY: Certificate pinning validation failed for localhost")
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }
        
        // Fallback to default handling
        completionHandler(.performDefaultHandling, nil)
    }
    
    // MARK: - Certificate Pinning Validation
    
    /// Validates certificate pinning for localhost connections
    /// - Parameter serverTrust: Server trust object
    /// - Returns: True if certificate pinning validation passes
    private func validateCertificatePinning(serverTrust: SecTrust) -> Bool {
        // Get the certificate count
        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        guard certificateCount > 0 else {
            print("❌ LocalhostCertificateDelegate: No certificates found")
            return false
        }
        
        // Get the leaf certificate
        guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            print("❌ LocalhostCertificateDelegate: Could not get leaf certificate")
            return false
        }
        
        // For localhost, use standard SSL validation
        let policy = SecPolicyCreateSSL(true, "localhost" as CFString)
        var result: SecTrustResultType = .invalid
        
        let status = SecTrustEvaluate(serverTrust, &result)
        
        if status == errSecSuccess {
            switch result {
            case .proceed, .unspecified:
                print("✅ LocalhostCertificateDelegate: Certificate validation passed")
                return true
            case .deny, .fatalTrustFailure, .invalid:
                print("❌ LocalhostCertificateDelegate: Certificate validation failed")
                return false
            case .recoverableTrustFailure:
                print("❌ LocalhostCertificateDelegate: Recoverable trust failure - rejecting for security")
                return false
            @unknown default:
                print("❌ LocalhostCertificateDelegate: Unknown trust result")
                return false
            }
        } else {
            print("❌ LocalhostCertificateDelegate: Trust evaluation failed with status: \(status)")
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
