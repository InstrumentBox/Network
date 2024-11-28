//
//  DefaultServerTrustPolicy.swift
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

/// A policy that uses the default server trust evaluation.
///
///  It allows you to control whether to validate the host provided by the challenge. Applications
///  are encouraged to always validate the host in production environments to guarantee the
///  validity of the server's certificate chain.
public final class DefaultServerTrustPolicy: ServerTrustPolicy {
   private let evaluateHost: Bool

   // MARK: - Init

   /// Creates and returns a `DefaultServerTrustPolicy` with provided parameters.
   ///
   /// - Parameters:
   ///   - evaluateHost: Determines whether or not the policy should evaluate the host, in addition
   ///                   to performing the default evaluation. Defaults to `true`.
   public init(evaluateHost: Bool = true) {
      self.evaluateHost = evaluateHost
   }

   // MARK: - ServerTrustPolicy

   public func evaluate(_ serverTrust: SecTrust, for host: String) -> Bool {
      let host = host as CFString
      let policy = SecPolicyCreateSSL(true, evaluateHost ? host : nil)
      SecTrustSetPolicies(serverTrust, policy)
      return SecTrustEvaluateWithError(serverTrust, nil)
   }
}
