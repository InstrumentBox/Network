//
//  FormData.swift
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

/// An object that represents body part with content-disposition equals to form data.
///
/// The body part data will be converted using the following format:
/// ```
/// Content-Disposition: form-data; name=#{...}; filename=#{...}
/// Content-Type: #{mimeType}
///
/// Encoded data
/// ```
/// Where filename value is optional.
public struct FormData: BodyPart {
   /// Name of body part. Used as value of *name* in *Content-Disposition*.
   public let name: String

   /// Name of file to upload. Used as value of *filename* in *Content-Disposition*.
   public let fileName: String?

   /// Additional headers of body part.
   public let headers: [String: String]?

   /// Body part data.
   public let body: Data

   /// MIME type of body part data.
   public let contentType: String

   // MARK: - Init

   /// Creates and returns an instance of `FormData` with given parameters.
   ///
   /// - Parameters:
   ///   - name: Name of body part.
   ///   - fileName: Name of file to upload. Defaults to `nil`.
   ///   - headers: Additional headers of body part. Defaults to `nil`.
   ///   - body: An object to be used as a data of body part.
   ///   - converter: A ``BodyConverter`` to convert body object and set *Content-Type* of body part.
   /// - Throws: An error occurred during body object conversion.
   public init<Body>(
      name: String,
      fileName: String? = nil,
      headers: [String: String]? = nil,
      body: Body,
      converter: some BodyConverter<Body>
   ) throws {
      self.name = name
      self.fileName = fileName
      self.headers = headers
      self.body = try converter.convert(body)
      self.contentType = converter.contentType
   }

   // MARK: - BodyPart

   public func toBodyPartData(with boundary: String) throws -> Data {
      var formData = Data()

      formData.append("--\(boundary)\r\n")

      var contentDisposition = #"Content-Disposition: form-data; name="\#(name)""#
      if let fileName {
         contentDisposition += #"; filename="\#(fileName)""#
      }
      contentDisposition += "\r\n"
      formData.append(contentDisposition)

      let contentType = "Content-Type: \(contentType)\r\n"
      formData.append(contentType)

      if let headers {
         for (key, value) in headers.sorted(by: { lhs, rhs in lhs.key < rhs.key }) {
            let headerString = "\(key): \(value)\r\n"
            formData.append(headerString)
         }
      }

      formData.append("\r\n")
      formData.append(body)
      formData.append("\r\n")

      return formData
   }
}
