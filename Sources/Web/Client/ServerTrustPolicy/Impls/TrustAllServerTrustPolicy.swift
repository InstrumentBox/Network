//
//  TrustAllServerTrustPolicy.swift
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

/// Policy that always considers server trust as valid.
///
/// Instead of using trust all policy, it's a better idea to configure systems to
/// properly trust test certificates, as outlined in
/// [this Apple tech note](https://developer.apple.com/library/archive/qa/qa1948/_index.html).
///
/// - Important: Don't use this policy in production.
public final class TrustAllServerTrustPolicy: ServerTrustPolicy {
   // MARK: - Init

   /// Creates and returns an instance of `TrustAllServerTrustPolicy`.
   public init() { }

   // MARK: - ServerTrustPolicy

   public func evaluate(_ serverTrust: SecTrust, for host: String) -> Bool { true }
}
