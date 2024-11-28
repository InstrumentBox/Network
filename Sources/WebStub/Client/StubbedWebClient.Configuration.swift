//
//  StubbedWebClient.Configuration.swift
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

import Web

extension StubbedWebClient {
   /// A configuration of ``StubbedWebClient``.
   public class Configuration: @unchecked Sendable {
      /// A `WebClient` to use to send requests that have no prepared local responses. Defaults to `nil`.
      public var fallbackWebClient: (any WebClient)?

      /// It provides value to simulate latency when returning response from a prepared `.response`
      /// file. Defaults to `nil`.
      public var latency: (any Latency)?

      /// Value that controls if requests should be sent to a fallback web client if no chain or
      /// records in the chain was found. Requires `fallbackWebClient` property to be set. `False` by
      /// default.
      public var fallbackRequestsIfNoResponsesRegistered = false

      // MARK: - Init

      /// Creates and returns a new instance of `StubbedWebClient.Configuration`.
      public init() { }
   }
}
