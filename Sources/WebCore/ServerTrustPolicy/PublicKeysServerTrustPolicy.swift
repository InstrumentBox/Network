//
//  PublicKeysServerTrustPolicy.swift
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

@preconcurrency
import Foundation

/// A policy that uses the pinned public keys to validate the server trust.
///
/// The server trust is considered valid if one of the pinned public keys match one of the server
/// certificate public keys. By evaluating both the certificate chain and host, public key pinning
/// provides a very secure form of server trust evaluation mitigating most, if not all, MITM
/// attacks. Applications are encouraged to always evaluate the host and require a valid certificate
/// chain in production environments.
public final class PublicKeysServerTrustPolicy: ServerTrustPolicy {
   private let keys: [SecKey]
   private let evaluateHost: Bool

   // MARK: - Init

   /// Creates and returns a `PublicKeysServerTrustPolicy` with provided parameters.
   ///
   /// - Parameters:
   ///   - keys: Array of `SecKey`s to use to evaluate public keys. Defaults to public keys of all
   ///           certificates included in the main bundle.
   ///   - evaluateHost: Determines whether or not the policy should evaluate the host, in addition
   ///                   to performing the default evaluation. Defaults to `true`.
   public init(keys: [SecKey] = SecKey.allPublicKeys(), evaluateHost: Bool = true) {
      self.keys = keys
      self.evaluateHost = evaluateHost
   }

   // MARK: - ServerTrustPolicy

   public func evaluate(_ serverTrust: SecTrust, for host: String) -> Bool {
      let host = host as CFString
      let policy = SecPolicyCreateSSL(true, evaluateHost ? host : nil)
      SecTrustSetPolicies(serverTrust, policy)
      guard SecTrustEvaluateWithError(serverTrust, nil) else {
         return false
      }

      let serverKeys = serverTrust.certificates.compactMap(\.publicKey)
      for serverKey in serverKeys {
         for key in keys {
            if serverKey.equals(to: key) {
               return true
            }
         }
      }
      return false
   }
}
