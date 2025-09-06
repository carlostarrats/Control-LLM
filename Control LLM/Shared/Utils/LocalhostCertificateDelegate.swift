//
//  LocalhostCertificateDelegate.swift
//  Control LLM
//
//  URLSession delegate for handling localhost HTTPS certificates
//

import Foundation
import Network

/// URLSession delegate that handles localhost HTTPS certificates securely
class LocalhostCertificateDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Only handle localhost connections
        let host = challenge.protectionSpace.host
        guard host == "localhost" || host == "127.0.0.1" else {
            // For non-localhost connections, use default handling
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // For localhost, we can be more permissive with certificates
        // This is acceptable since localhost is a trusted environment
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }
        
        // Fallback to default handling
        completionHandler(.performDefaultHandling, nil)
    }
}
