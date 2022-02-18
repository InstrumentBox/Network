//
//  URLEncoder.swift
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

public enum URLEncoderError: Error {
   case cannotPercentEncode(String)
}

public final class URLEncoder {
   public static var arrayKeyEncoding: ArrayKeyEncoding = .brackets
   public static var boolEncoding: BoolEncoding = .literal

   public static let allowedCharacterSet: CharacterSet = {
      let delimiters = ":#[]@"
      let subDelimiters = "!$&'()*+,;="
      let encodableCharacterSet = CharacterSet(charactersIn: delimiters + subDelimiters)
      return CharacterSet.urlQueryAllowed.subtracting(encodableCharacterSet)
   }()

   private let arrayKeyEncoding: ArrayKeyEncoding
   private let boolEncoding: BoolEncoding

   // MARK: - Init

   public init(
      arrayKeyEncoding: ArrayKeyEncoding = URLEncoder.arrayKeyEncoding,
      boolEncoding: BoolEncoding = URLEncoder.boolEncoding
   ) {
      self.arrayKeyEncoding = arrayKeyEncoding
      self.boolEncoding = boolEncoding
   }

   // MARK: - Encoding

   public func encode(_ dict: [String: Any]) throws -> String {
      try dict.flatMap(encode).joined(separator: "&")
   }

   private func encode(key: String, value: Any) throws -> [String] {
      var components: [String] = []

      switch value {
         case let parameters as [String: Any]:
            for (nestedKey, value) in parameters {
               components += try encode(key: "\(key)[\(nestedKey)]", value: value)
            }
         case let values as [Any]:
            for value in values {
               components += try encode(key: arrayKeyEncoding.encode(key), value: value)
            }
         case let value as NSNumber where CFGetTypeID(value) == CFBooleanGetTypeID():
            let encoded = "\(try encode(key))=\(boolEncoding.encode(value.boolValue))"
            components.append(encoded)
         case let value as Bool:
            let encoded = "\(try encode(key))=\(boolEncoding.encode(value))"
            components.append(encoded)
         default:
            let encoded = "\(try encode(key))=\(try encode("\(value)"))"
            components.append(encoded)
      }

      return components
   }

   private func encode(_ string: String) throws -> String {
      guard let encoded = string.addingPercentEncoding(
         withAllowedCharacters: URLEncoder.allowedCharacterSet
      ) else {
         throw URLEncoderError.cannotPercentEncode(string)
      }

      return encoded
   }
}
