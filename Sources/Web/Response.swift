//
//  Response.swift
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

/// An object that represent an HTTP response.
public final class Response: Equatable, Sendable {
   /// The request that was sent in order to receive a response.
   public let request: URLRequest

   /// Status code a response.
   public let statusCode: Int

   /// Header fields of a response.
   public let headers: [String: String]

   /// The data that represents body of response.
   public let body: Data

   // MARK: - Init

   /// Creates and returns an instance of `Response` with give values.
   ///
   /// - Parameters:
   ///   - request: The request that was sent in order to receive a response.
   ///   - statusCode: Status code a response.
   ///   - headers: Header fields of a response.
   ///   - body: The data that represents body of response.
   public init(request: URLRequest, statusCode: Int, headers: [String: String], body: Data) {
      self.request = request
      self.statusCode = statusCode
      self.headers = headers
      self.body = body
   }

   // MARK: - Equatable

   /// Compares two instances of a `Response`.
   ///
   /// It uses `statusCode`, `headers`, `body`, and `request.url` properties to compare responses.
   ///
   /// - Parameters:
   ///   - lhs: The first instance of a `Response` to compare.
   ///   - rhs: The second instance of a `Response` to compare.
   /// - Returns: `true` if instances are equal, otherwise `false`.
   public static func ==(lhs: Response, rhs: Response) -> Bool {
      lhs.request.url == rhs.request.url &&
      lhs.statusCode == rhs.statusCode &&
      lhs.headers == rhs.headers &&
      lhs.body == rhs.body
   }

   // MARK: - Header Accessors

   func contentTypeMIME() -> MIME? {
      guard let contentType = headers["Content-Type"] else {
         return nil
      }

      let mimeString = contentType.components(separatedBy: ";")[0]
      return .parseMIMEString(mimeString)
   }
}
