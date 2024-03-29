//
//  StringResponseConverter.swift
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

/// An error that is thrown when `StringResponseConverter` failed.
public enum StringResponseConverterError: Error {
   /// Thrown if response body can't be converted to a string.
   case cannotConvertToString
}

/// A response converter that takes response body and converts it to a string.
public struct StringResponseConverter: ResponseConverter {
   private let encoding: String.Encoding

   // MARK: - Init

   /// Creates and returns an instance of `StringResponseConverter` with a given parameter.
   ///
   /// - Parameters:
   ///   -  encoding: The encoding used by data. For possible values, see `String.Encoding`.
   public init(encoding: String.Encoding = .utf8) {
      self.encoding = encoding
   }

   // MARK: - ResponseConverter

   public func convert(_ response: Response) throws -> String {
      guard let string = String(data: response.body, encoding: encoding) else {
         throw StringResponseConverterError.cannotConvertToString
      }

      return string
   }
}
