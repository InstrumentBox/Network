//
//  StatusCodeContentTypeResponseValidator.swift
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

public enum StatusCodeContentTypeResponseValidatorError: Error {
   case unacceptableContentType(expected: String, received: String)
}

public struct StatusCodeContentTypeResponseValidator: ResponseValidator {
   private let acceptableStatusCodes: Set<Int>

   // MARK: - Init

   public init<S: Sequence>(acceptableStatusCodes: S) where S.Element == Int {
      self.acceptableStatusCodes = Set(acceptableStatusCodes)
   }

   public init() {
      self.init(acceptableStatusCodes: 200...299)
   }

   // MARK: - ResponseValidator

   public func validate(_ response: Response) -> ResponseValidationDisposition {
      let statusCodeDisposition: ResponseValidationDisposition
      if acceptableStatusCodes.contains(response.statusCode) {
         statusCodeDisposition = .useObjectResponseConverter
      } else {
         statusCodeDisposition = .useErrorResponseConverter
      }

      let requestMIMEs = response.request.acceptMIMEs()
      guard let responseMIME = response.contentTypeMIME(), !requestMIMEs.isEmpty else {
         return statusCodeDisposition
      }

      guard requestMIMEs.contains(where: { requestMIME in
         responseMIME.matches(requestMIME)
      }) else {
         let error: StatusCodeContentTypeResponseValidatorError = .unacceptableContentType(
            expected: requestMIMEs.map(\.description).joined(separator: ", "),
            received: responseMIME.description
         )
         return .completeWithError(error)
      }

      return statusCodeDisposition
   }
}
