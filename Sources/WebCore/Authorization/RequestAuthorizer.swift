//
//  RequestAuthorizer.swift
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

import Web

/// A protocol you need to implement and set to `URLSessionWebClient.Configuration` to allow
/// `WebClient` to authorize all sent requests.
///
/// Request authorizer is a good place where you can ask your authorization token from a keychain
/// or pause requests and refresh an authorization token using a refresh token and store new token
/// in keychain.
///
/// - Note: Request authorizer is intended to be used if you authorize your requests with HTTP
///         header.
public protocol RequestAuthorizer: Sendable {
   /// Asks authorizer if request should be authorized by setting them authorization header.
   ///
   /// - Parameters:
   ///   - request: A request that's probably needed to by authorized.
   /// - Returns: A boolean value that tells if request should be authorized.
   func needsAuthorization(for request: some Request) -> Bool

   /// Asks authorizer for an authorization header.
   ///
   /// - Parameters:
   ///   - request: A request that is needed to be authorized.
   /// - Returns: A header that will be used to authorize request.
   func authorizationHeader(for request: some Request) async throws -> AuthorizationHeader
}

extension RequestAuthorizer {
   /// Asks authorizer if request should be authorized by setting them authorization header.
   ///
   /// - Parameters:
   ///   - request: A request that's probably needed to be authorized.
   /// - Returns: `true` if request doesn't conform to `NonAuthorizableRequest` protocol, otherwise
   ///            `false`.
   public func needsAuthorization(for request: some Request) -> Bool {
      !(request is any NonAuthorizableRequest)
   }
}
