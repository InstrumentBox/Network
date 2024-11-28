//
//  MultipartBodyConverter.swift
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

extension MultipartBodyConverter {
   /// Kind of multipart content on which resulting *Content-Type* depends.
   public enum ContentTypeKind: Sendable {
      /// Content type kind that is intended to be used for e-mails. *Content-Type* is
      /// *multipart/alternative*.
      case alternative

      /// Content type kind that is intended to be used for web-forms. *Content-Type* is
      /// *multipart/form-data*.
      case formData

      /// Content type kind that is intended to be used for e-mails. *Content-Type* is
      /// *multipart/mixed*.
      case mixed

      /// Content type kind that is intended to be used for e-mails. *Content-Type* is
      /// *multipart/related*.
      case related
   }
}

/// A body converter that takes an array of `BodyPart` and converts it a body data. The MIME type
/// of a result depends on `ContentTypeKind`.
public struct MultipartBodyConverter: BodyConverter {
   private let contentTypeKind: ContentTypeKind
   private let boundary: String
   private let preamble: String?
   private let epilogue: String?

   // MARK: - Init

   /// Creates and returns an instance of `MultipartBodyConverter` with a given parameters.
   ///
   /// Preamble and epilogue parameters may be useful with `mixed`, `alternative` or `related`
   /// content types.
   ///
   /// - Parameters:
   ///   - contentTypeKind: The kind of content. Defaults to `.formData`.
   ///   - preamble: A string to be added before the first boundary. Defaults to `"\r\n"`.
   ///   - epilogue: A string to be added after the last boundary. Defaults to `"\r\n"`.
   public init(
      contentTypeKind: ContentTypeKind = .formData,
      preamble: String? = "\r\n",
      epilogue: String? = "\r\n"
   ) {
      self.init(
         contentTypeKind: contentTypeKind,
         boundary: UUID().uuidString,
         preamble: preamble,
         epilogue: epilogue
      )
   }

   init(
      contentTypeKind: ContentTypeKind,
      boundary: String,
      preamble: String? = "\r\n",
      epilogue: String? = "\r\n"
   ) {
      self.contentTypeKind = contentTypeKind
      self.boundary = boundary
      self.preamble = preamble
      self.epilogue = epilogue
   }

   // MARK: - BodyConverter

   public var contentType: String {
      switch contentTypeKind {
         case .alternative:
            return "multipart/alternative; boundary=\(boundary)"
         case .formData:
            return "multipart/form-data; boundary=\(boundary)"
         case .mixed:
            return "multipart/mixed; boundary=\(boundary)"
         case .related:
            return "multipart/related; boundary=\(boundary)"
      }
   }

   public func convert(_ body: [any BodyPart]) throws -> Data {
      var bodyData = Data()

      if let preamble {
         bodyData.append(preamble)
      }

      for bodyPart in body {
         bodyData.append("--\(boundary)\r\n")
         let bodyPartData = try bodyPart.toBodyPartData()
         bodyData.append(bodyPartData)
         bodyData.append("\r\n")
      }

      bodyData.append("--\(boundary)--")

      if let epilogue {
         bodyData.append(epilogue)
      }

      return bodyData
   }
}
