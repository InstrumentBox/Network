//
//  Header.swift
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

/// An authorization header.
public struct AuthorizationHeader: Sendable {
   /// Name of authorization header.
   public let name: String

   /// Value of authorization header.
   public let value: String

   // MARK: - Init

   /// Creates and returns new header with given name and value.
   ///
   /// - Parameters:
   ///   - name: Name of authorization header field.
   ///   - value: Value of authorization header field.
   public init(name: String, value: String) {
      self.name = name
      self.value = value
   }

   // MARK: - Predefined

   /// Creates and returns the following header: `Authorization: Bearer <token>`.
   /// - Parameters:
   ///   - token: Token to be set as header value.
   /// - Returns: Authorization header.
   public static func bearerAuthorization(_ token: String) -> AuthorizationHeader {
      AuthorizationHeader(name: "Authorization", value: "Bearer \(token)")
   }

   /// Creates and returns the following header: `Authorization: Basic <base64 login + password>`.
   /// - Parameters:
   ///   - base64: Base 64 encoded username and password.
   /// - Returns: Authorization header.
   public static func basicAuthorization(_ base64: String) -> AuthorizationHeader {
      AuthorizationHeader(name: "Authorization", value: "Basic \(base64)")
   }
}
