//
//  JSONSerializationResponseConverter.swift
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

/// An error that is thrown when `JSONSerializationResponseConverter` failed.
public enum JSONSerializationResponseConverterError: Error {
   /// Thrown if resulting object can't be casted to an expected type.
   case typeMismatch(expected: String, given: String)
}

/// A response converter that uses `JSONSerialization` to convert response body to some object.
///
/// If you use `.fragmentsAllowed` reading option, you can use this converter to parse numbers or
/// strings.
///
/// - Note: String in response must be double-quoted. If not, use `StringResponseConverter`.
public struct JSONSerializationResponseConverter<ConvertedResponse: Sendable>: ResponseConverter {
   private let options: JSONSerialization.ReadingOptions

   // MARK: - Init

   /// Creates and returns an instance of `JSONSerializationResponseConverter` with a given option.
   ///
   /// - Parameters:
   ///   -  options: Options for reading the JSON data and creating the Foundation objects. For
   ///               possible values, see `JSONSerialization.ReadingOptions`.
   ///               Defaults to `.fragmentsAllowed`.
   public init(options: JSONSerialization.ReadingOptions = [.fragmentsAllowed]) {
      self.options = options
   }

   // MARK: - ResponseConverter

   public func convert(_ response: Response) throws -> ConvertedResponse {
      let json = try JSONSerialization.jsonObject(with: response.body, options: options)
      guard let convertedResponse = json as? ConvertedResponse else {
         throw JSONSerializationResponseConverterError.typeMismatch(
            expected: "\(ConvertedResponse.self)",
            given: "\(type(of: json))"
         )
      }

      return convertedResponse
   }
}
