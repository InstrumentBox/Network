//
//  ServerTrustURLAuthenticationHandler.swift
//
//  Copyright © 2024 Aleksei Zaikin.
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

/// A handler that processes server trust url authentication challenge.
public final class ServerTrustURLAuthenticationHandler: URLAuthenticationHandler {
   private let serverTrustPolicies: [String: any ServerTrustPolicy]

   // MARK: - Init
   
   /// Creates and returns a new instance if `ServerTrustURLAuthenticationHandler` with a given
   /// parameter.
   ///
   /// - Parameters:
   ///   - serverTrustPolicies: The dictionary of policies mapped to a particular host. Map policy
   ///                          to `*` if you want to use this policy for each host, for which
   ///                          separate policy is not specified.
   public init(serverTrustPolicies: [String: any ServerTrustPolicy]) {
      self.serverTrustPolicies = serverTrustPolicies
   }

   // MARK: - URLAuthenticationHandler

   public func canHandleChallenge(_ challenge: URLAuthenticationChallenge) -> Bool {
      challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
   }

   public func handleChallenge(_ challenge: URLAuthenticationChallenge) async -> (
      URLSession.AuthChallengeDisposition,
      URLCredential?
   ) {
      let host = challenge.protectionSpace.host
      guard
         let serverTrust = challenge.protectionSpace.serverTrust,
         let policy = serverTrustPolicies[host] ?? serverTrustPolicies["*"]
      else {
         return (.performDefaultHandling, nil)
      }

      if policy.evaluate(serverTrust, for: host) {
         let credential = URLCredential(trust: serverTrust)
         return (.useCredential, credential)
      } else {
         return (.cancelAuthenticationChallenge, nil)
      }
   }
}
