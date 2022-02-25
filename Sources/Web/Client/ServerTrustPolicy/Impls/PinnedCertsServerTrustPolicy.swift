//
//  PinnedCertsServerTrustPolicy.swift
//
//  Copyright © 2022 Aleksei Zaikin.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// A policy that uses pinned certificates to evaluate the server trust.
///
/// The server trust is considered valid if one of the pinned certificates match one of the server
/// certificates. By evaluating both the certificate chain and host, certificate pinning provides
/// a very secure form of server trust evaluation mitigating most, if not all, MITM attacks.
/// Applications are encouraged to always validate the host and require a valid certificate chain
/// in production environments.
public final class PinnedCertsServerTrustPolicy: ServerTrustPolicy {
   private let certs: [SecCertificate]
   private let evaluateHost: Bool
   private let allowSelfSigned: Bool

   // MARK: - Init

   /// Creates and returns a `PinnedCertsServerTrustPolicy` with provided parameters.
   ///
   /// - Parameters:
   ///   - certs: Array of `SecCertificate`s to use to evaluate the trust. Defaults to all
   ///            .cer/.CER, .crt/.CRT, .der/.DER certificates included in the main bundle.
   ///   - evaluateHost: Determines whether or not the policy should evaluate the host, in addition
   ///                   to performing the default evaluation. Defaults to `true`.
   ///   - allowSelfSigned: Adds the provided certificates as anchors for the trust evaluation,
   ///                      allowing self-signed certificates to pass. Defaults to `false`.
   ///                      **Don't use this setting in production!**
   public init(
      certs: [SecCertificate] = SecCertificate.all(),
      evaluateHost: Bool = true,
      allowSelfSigned: Bool = false
   ) {
      self.certs = certs
      self.evaluateHost = evaluateHost
      self.allowSelfSigned = allowSelfSigned
   }

   // MARK: - ServerTrustPolicy

   public func evaluate(_ serverTrust: SecTrust, for host: String) -> Bool {
      let host = host as CFString
      let policy = SecPolicyCreateSSL(true, evaluateHost ? host : nil)
      SecTrustSetPolicies(serverTrust, policy)

      if allowSelfSigned {
         SecTrustSetAnchorCertificates(serverTrust, certs as CFArray)
         SecTrustSetAnchorCertificatesOnly(serverTrust, true)
      }

      guard SecTrustEvaluateWithError(serverTrust, nil) else {
         return false
      }

      let serverCerts = serverTrust.certificates
      for serverCert in serverCerts {
         for cert in certs {
            if serverCert.equals(to: cert) {
               return true
            }
         }
      }
      return false
   }
}
