//
//  PropertyListEncoderBodyConverter.swift
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

/// A body converter that takes `Encodable` object and uses `PropertyListEncoder` to convert an
/// object to a body data. The MIME type of a result depends on encoder's `outputFormat` property
/// and can be either *application/xml* or *application/x-plist*.
public struct PropertyListEncoderBodyConverter<Body: Encodable & Sendable>: BodyConverter {
   private let encoder: PropertyListEncoder

   // MARK: - Init

   /// Creates and returns an instance of `PropertyListEncoderBodyConverter` with a given encoder.
   ///
   /// - Parameters:
   ///   -  encoder: `PropertyListEncoder` that is used to convert body object to body data.
   ///               Defaults to `PropertyListEncoder()`.
   public init(encoder: PropertyListEncoder = PropertyListEncoder()) {
      self.encoder = encoder
   }

   // MARK: - BodyConverter

   public var contentType: String {
      switch encoder.outputFormat {
         case .xml:
            return "application/xml"
         default:
            return "application/x-plist"
      }
   }

   public func convert(_ body: Body) throws -> Data {
      try encoder.encode(body)
   }
}
