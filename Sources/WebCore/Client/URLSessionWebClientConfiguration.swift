//
//  URLSessionWebClientConfiguration.swift
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

/// A configuration object used to create `URLSessionWebClient`.
///
/// Configuration encapsulates configuration of underlying URL session and contains properties
/// `URSessionWebClient` uses to do its work.
///
/// - Note: As `WebClient` is *NOT* intended to work with background URLSessions, it's not possible
///         to create a background configuration.
public class URLSessionWebClientConfiguration: @unchecked Sendable {
   /// Base URL that is used by web client.
   ///
   /// If you use `URL(path:baseURL) throws` initializer provided by this library and your base
   /// URL contains path, you probably should end it with `/` as this initializer uses relative URL
   /// mechanism.
   ///
   /// Example
   ///
   /// ```swift
   /// configuration.baseURL = URL(string: "https://api.myservice.com/v1/")
   /// ```
   public var baseURL: URL?

   /// An object that will be used to authorize each request sent by a web client.
   public var requestAuthorizer: (any RequestAuthorizer)?
   
   /// A set of handlers to process URL authentication challenge. The first handler that can handle
   /// challenge will be used.
   public var urlAuthenticationHandlers: [any URLAuthenticationHandler]?

   /// Handler that will be used to receive 2FA challenges.
   public var twoFactorAuthenticationHandler: (any TwoFactorAuthenticationHandler)?

   /// Configuration of underlying `URLSession` object.
   public let sessionConfiguration: URLSessionConfiguration

   // MARK: - Init

   private init(sessionConfiguration: URLSessionConfiguration) {
      self.sessionConfiguration = sessionConfiguration
   }

   // MARK: - Predefined

   /// A configuration that uses default URL session configuration.
   public static var `default`: URLSessionWebClientConfiguration {
      URLSessionWebClientConfiguration(sessionConfiguration: .default)
   }

   /// A configuration that uses ephemeral URL session configuration.
   public static var ephemeral: URLSessionWebClientConfiguration {
      URLSessionWebClientConfiguration(sessionConfiguration: .ephemeral)
   }
}
