//
//  URLEncoderBodyConverter.swift
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

/// A body converter that takes a dictionary of [String: Any] and uses `URLEncoder` to convert
/// dictionary to a string, then convert string to a body data by using `StringBodyConverter`. The
/// MIME type of a result is *application/x-www-form-urlencoded*.
public struct URLEncoderBodyConverter: BodyConverter {
   private let encoder: URLEncoder
   private let encoding: String.Encoding
   private let allowLossyConversion: Bool

   // MARK: - Init

   /// Creates and returns an instance of `URLEncoderBodyConverter` with given parameters.
   /// - Parameters:
   ///   - encoder: `URLEncoder` that is used to convert body dictionary to a string.
   ///   - encoding: A string encoding to be used by `StringBodyConverter`. For possible values,
   ///               see `String.Encoding`
   ///   - allowLossyConversion: If `true`, then allows characters to be removed or altered in
   ///                           conversion. Used by underlying `StringBodyConverter`.
   public init(
      encoder: URLEncoder = URLEncoder(),
      encoding: String.Encoding = .utf8,
      allowLossyConversion: Bool = false
   ) {
      self.encoder = encoder
      self.encoding = encoding
      self.allowLossyConversion = allowLossyConversion
   }

   // MARK: - BodyConverter

   public var contentType: String {
      "application/x-www-form-urlencoded"
   }

   public func convert(_ body: [String: any Sendable]) throws -> Data {
      let encoded = try encoder.encode(body)
      let converter = StringBodyConverter(
         encoding: encoding,
         allowLossyConversion: allowLossyConversion
      )
      return try converter.convert(encoded)
   }
}
