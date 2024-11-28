//
//  URLRequest+Construction.swift
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

extension URLRequest {
   /// Creates and returns URL request that consists of URL, method, and headers.
   ///
   /// - Parameters:
   ///   - url: A URL that will be used to send request to.
   ///   - method: An HTTP method to use for request
   ///   - headers: HTTP headers to add to a request.
   public init(url: URL, method: Method, headers: [String: String]? = nil) {
      self.init(url: url)

      httpMethod = method.raw
      if let headers {
         for (field, value) in headers {
            addValue(value, forHTTPHeaderField: field)
         }
      }
   }

   /// Creates and returns URL request that consists of URL, method, and headers. In addition, adds
   /// body and *Content-Type* header to a request using passed `BodyConverter`.
   ///
   /// - Parameters:
   ///   - url: A URL that will be used to send request to.
   ///   - method: An HTTP method to use for request
   ///   - headers: HTTP headers to add to a request.
   ///   - body: An object that will be converted to `Data` and set a body of a request.
   ///   - converter: A `BodyConverter` that is used to convert body and from which content type
   ///                value will be taken to set *Content-Type* header.
   public init<Body: Sendable>(
      url: URL,
      method: Method,
      headers: [String: String]? = nil,
      body: Body,
      converter: some BodyConverter<Body>
   ) throws {
      self.init(url: url, method: method, headers: headers)

      httpBody = try converter.convert(body)
      addValue(converter.contentType, forHTTPHeaderField: "Content-Type")
   }
}
