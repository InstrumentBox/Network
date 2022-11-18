//
//  ImageResponseConverter.swift
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

/// An error that is thrown when `ImageResponseConverter` failed.
@available(iOS 13.0, tvOS 13.0, macCatalyst 13.1, watchOS 6.0, *)
public enum ImageResponseConverterError: Error {
   /// Thrown if response body can't be converted to an image.
   case cannotConvertToImage
}

/// A response converter that takes response body and converts it to an image.
/// - Note: This converter is only available on platforms that support `UIKit`.
@available(iOS 13.0, tvOS 13.0, macCatalyst 13.1, watchOS 6.0, *)
public struct ImageResponseConverter: ResponseConverter {
   private let scale: CGFloat

   // MARK: - Init

   /// Creates and returns an instance of `ImageResponseConverter` with a given parameter.
   ///
   /// - Parameters:
   ///   -  scale: The scale factor to assume when interpreting the image data. Applying a scale
   ///             factor of 1.0 results in an image whose size matches the pixel-based dimensions
   ///             of the image. Applying a different scale factor changes the size of the image
   ///             as reported by the `size` property.
   public init(scale: CGFloat = 1.0) {
      self.scale = scale
   }
   
   // MARK: - ResponseConverter

   public func convert(_ response: Response) throws -> UIImage {
      guard let image = UIImage(data: response.body, scale: scale) else {
         throw ImageResponseConverterError.cannotConvertToImage
      }

      return image
   }
}

#endif
