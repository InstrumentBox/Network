//
//  JPEGImageBodyConverter.swift
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

#if canImport(UIKit)

import UIKit

@available(iOS 13.0, tvOS 13.0, macCatalyst 13.1, watchOS 6.0, *)
public enum JPEGImageBodyConverterError: Error {
   case cannotConvertToData(UIImage)
}

@available(iOS 13.0, tvOS 13.0, macCatalyst 13.1, watchOS 6.0, *)
public struct JPEGImageBodyConverter: BodyConverter {
   private let compressionQuality: CGFloat

   // MARK: - Init

   public init(compressionQuality: CGFloat = 1.0) {
      self.compressionQuality = compressionQuality
   }

   // MARK: - BodyConverter

   public var contentType: String {
      "image/jpeg"
   }

   public func convert(_ body: UIImage) throws -> Data {
      guard let jpegData = body.jpegData(compressionQuality: compressionQuality) else {
         throw JPEGImageBodyConverterError.cannotConvertToData(body)
      }

      return jpegData
   }
}

#endif
