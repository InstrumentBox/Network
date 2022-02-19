//
//  StringBodyConverter.swift
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

public enum StringBodyConverterError: Error {
   case cannotConvertToData(String)
}

public struct StringBodyConverter: BodyConverter {
   private let encoding: String.Encoding
   private let allowLossyConversion: Bool

   // MARK: - Init

   public init(encoding: String.Encoding = .utf8, allowLossyConversion: Bool = false) {
      self.encoding = encoding
      self.allowLossyConversion = allowLossyConversion
   }

   // MARK: - BodyConverter

   public var contentType: String {
      "text/plain"
   }

   public func convert(_ body: String) throws -> Data {
      guard let data = body.data(using: encoding, allowLossyConversion: allowLossyConversion) else {
         throw StringBodyConverterError.cannotConvertToData(body)
      }

      return data
   }
}
