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
   public enum ContentTypeKind {
      case formData
      case mixed
   }
}

public struct MultipartBodyConverter: BodyConverter {
   private let contentTypeKind: ContentTypeKind
   private let boundary: String

   // MARK: - Init

   public init(contentTypeKind: ContentTypeKind = .formData) {
      self.init(contentTypeKind: contentTypeKind, boundary: UUID().uuidString)
   }

   init(contentTypeKind: ContentTypeKind, boundary: String) {
      self.contentTypeKind = contentTypeKind
      self.boundary = boundary
   }

   // MARK: - BodyConverter

   public var contentType: String {
      switch contentTypeKind {
         case .formData:
            return "multipart/form-data; boundary=\(boundary)"
         case .mixed:
            return "multipart/mixed; boundary=\(boundary)"
      }
   }

   public func convert(_ body: [FormData]) throws -> Data {
      var bodyData = Data()

      if contentTypeKind == .formData {
         bodyData.append("\r\n")
      }

      for formData in body {
         let formDataBinary = try formData.makeFormData(boundary: boundary)
         bodyData.append(formDataBinary)
      }

      switch contentTypeKind {
         case .formData:
            bodyData.append("--\(boundary)--\r\n")
         case .mixed:
            bodyData.append("--\(boundary)--")
      }

      return bodyData
   }
}
