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

/// An error that is thrown when response validation is failed.
public enum StatusCodeContentTypeResponseValidatorError: Error, Equatable {
   /// Thrown when MIME type of *Content-Type* header of a response doesn't match one of MIME of
   /// *Accept* header of request.
   ///
   /// - Parameters:
   ///   - expected: A string that consists of MIME types of a request separated by comma.
   ///   - received: A MIME type of content of a response.
   case unacceptableContentType(expected: String, received: String)

   // MARK: - Equatable

   public static func ==(
      lhs: StatusCodeContentTypeResponseValidatorError,
      rhs: StatusCodeContentTypeResponseValidatorError
   ) -> Bool {
      switch (lhs, rhs) {
         case let (.unacceptableContentType(lhsExpected, lhsReceived), .unacceptableContentType(rhsExpected, rhsReceived)):
            return lhsExpected == rhsExpected && lhsReceived == rhsReceived
      }
   }
}

/// A validator that does the most common validation of a response used by developers.
///
/// A response validator takes MIME type from *Content-Type* header of a response and all MIME types
/// from *Accept* header of a request, then looks that response MIME matches one of request's MIMEs.
/// If one of those headers has no value or both of them have no values, validator considers only
/// status code of a response. If MIMEs doesn't match, validator returns
/// ``ValidationErrorResponseValidationDisposition`` disposition with
/// `StatusCodeContentTypeResponseValidatorError.unacceptableContentType`error. If MIME of response
/// matches one of MIME types of request, validator considers status code of a response. If code has
/// value that `acceptableStatusCodes` contains, validator returns
/// ``SuccessObjectResponseValidationDisposition`` disposition, otherwise
/// ``ErrorObjectResponseValidationDisposition``.
public struct StatusCodeContentTypeResponseValidator: ResponseValidator {
   private let acceptableStatusCodes: Set<Int>

   // MARK: - Init

   /// Creates and returns an instance of a `StatusCodeContentTypeResponseValidator` with given
   /// values.
   ///
   /// - Parameters:
   ///   - acceptableStatusCodes: A sequence of status codes that validator should consider as
   ///                            successful and use ``SuccessObjectResponseValidationDisposition``
   ///                            disposition.
   public init<S: Sequence>(acceptableStatusCodes: S) where S.Element == Int {
      self.acceptableStatusCodes = Set(acceptableStatusCodes)
   }

   /// Creates and returns an instance of a `StatusCodeContentTypeResponseValidator` that
   /// should consider all numbers from 200 through 299 as successful status codes.
   public init() {
      self.init(acceptableStatusCodes: 200...299)
   }

   // MARK: - ResponseValidator

   public func validate(_ response: Response) -> ResponseValidationDisposition {
      let statusCodeDisposition: ResponseValidationDisposition
      if acceptableStatusCodes.contains(response.statusCode) {
         statusCodeDisposition = SuccessObjectResponseValidationDisposition()
      } else {
         statusCodeDisposition = ErrorObjectResponseValidationDisposition()
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
         return ValidationErrorResponseValidationDisposition(error: error)
      }

      return statusCodeDisposition
   }
}
