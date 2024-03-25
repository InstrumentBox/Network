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

/// An error that is thrown when URL encoding is failed.
public enum URLEncoderError: Error {
   /// Thrown when can't encode string using percent encoding.
   case cannotPercentEncode(String)
}

/// An object that encodes instances of `[String: Any]` into URL-encoded query strings.
public class URLEncoder {
   /// Global setting for array key encoding. Defaults to ``BracketsArrayKeyEncoding``.
   public static var arrayKeyEncoding: ArrayKeyEncoding = BracketsArrayKeyEncoding()

   /// Global setting for bool encoding. Defaults to ``LiteralBoolEncoding``.
   public static var boolEncoding: BoolEncoding = LiteralBoolEncoding()

   /// A character set of allowed (non-escaped) characters.
   public static let allowedCharacterSet: CharacterSet = {
      let delimiters = ":#[]@"
      let subDelimiters = "!$&'()*+,;="
      let encodableCharacterSet = CharacterSet(charactersIn: delimiters + subDelimiters)
      return CharacterSet.urlQueryAllowed.subtracting(encodableCharacterSet)
   }()

   private let arrayKeyEncoding: ArrayKeyEncoding
   private let boolEncoding: BoolEncoding

   // MARK: - Init

   /// Creates and returns an instance of `URLEncoder` with given parameters.
   ///
   /// - Parameters:
   ///   - arrayKeyEncoding: Encoding to apply to array keys. Defaults to
   ///                       `URLEncoder.arrayKeyEncoding`.
   ///   - boolEncoding: Encoding to apply to boolean values. Defaults to `URLEncoder.boolEncoding`.
   public init(
      arrayKeyEncoding: ArrayKeyEncoding = URLEncoder.arrayKeyEncoding,
      boolEncoding: BoolEncoding = URLEncoder.boolEncoding
   ) {
      self.arrayKeyEncoding = arrayKeyEncoding
      self.boolEncoding = boolEncoding
   }

   // MARK: - Encoding

   /// Encodes the a given dict of `[String: Any]` as a URL-encoded string.
   ///
   /// - Parameters:
   ///   -  dict: A dictionary that will be encoded.
   /// - Returns: A URL-encoded string.
   /// - Throws:  `URLEncoderError` if encoding failed.
   public func encode(_ dict: [String: Any]) throws -> String {
      let keys = dict.keys.sorted()
      var encoded: [String] = []
      for key in keys {
         if let value = dict[key] {
            try encoded.append(contentsOf: encode(key: key, value: value))
         }
      }

      return encoded.joined(separator: "&")
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
