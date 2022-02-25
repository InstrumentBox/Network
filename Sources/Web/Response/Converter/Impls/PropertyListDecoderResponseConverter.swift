//
//  PropertyListDecoderResponseConverter.swift
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

/// A response converter that uses `PropertyListDecoder` to convert response body to some
/// `Decodable` object.
public struct PropertyListDecoderResponseConverter<ConvertedResponse: Decodable>: ResponseConverter {
   private let decoder: PropertyListDecoder

   // MARK: - Init

   /// Creates and returns an instance of `PropertyListDecoderResponseConverter` with a given
   /// decoder.
   ///
   /// - Parameters:
   ///   -  decoder: `PropertyListDecoder` that is used to convert response body to some object.
   ///               Defaults to `PropertyListDecoder()`.
   public init(decoder: PropertyListDecoder = PropertyListDecoder()) {
      self.decoder = decoder
   }

   // MARK: - ResponseConverter

   public func convert(_ response: Response) throws -> ConvertedResponse {
      try decoder.decode(ConvertedResponse.self, from: response.body)
   }
}
