//
//  StatusCodeContentTypeResponseValidatorTestCase.swift
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

@testable
import Web

import XCTest

class StatusCodeContentTypeResponseValidatorTestCase: XCTestCase {
   private let validator = StatusCodeContentTypeResponseValidator()

   // MARK: - Test Cases

   func test_validator_disposesToUseObjectConverter_ifSuccessStatusCode_andHeadersMatches() throws {
      let response = try makeResponse(
         statusCode: 200,
         accept: "application/json",
         contentType: "application/json"
      )
      let disposition = validator.validate(response)
      XCTAssertEqual(disposition, .useSuccessObjectResponseConverter)
   }

   func test_validator_disposesToUseErrorConverter_ifFailureStatusCode_andHeadersMatches() throws {
      let response = try makeResponse(
         statusCode: 404,
         accept: "application/json",
         contentType: "application/json"
      )
      let disposition = validator.validate(response)
      XCTAssertEqual(disposition, .useErrorObjectResponseConverter)
   }

   func test_validator_disposesToUseObjectConverter_ifSuccessStatusCode_andNoAcceptHeader() throws {
      let response = try makeResponse(statusCode: 200, accept: nil, contentType: "application/json")
      let disposition = validator.validate(response)
      XCTAssertEqual(disposition, .useSuccessObjectResponseConverter)
   }

   func test_validator_disposesToUseObjectConverter_ifSuccessStatusCode_andNoContentTypeHeader() throws {
      let response = try makeResponse(statusCode: 200, accept: "application/json", contentType: nil)
      let disposition = validator.validate(response)
      XCTAssertEqual(disposition, .useSuccessObjectResponseConverter)
   }

   func test_validator_disposesToUseErrorConverter_ifFailureStatusCode_andNoAcceptHeader() throws {
      let response = try makeResponse(statusCode: 404, accept: nil, contentType: "application/json")
      let disposition = validator.validate(response)
      XCTAssertEqual(disposition, .useErrorObjectResponseConverter)
   }

   func test_validator_disposesToUseErrorConverter_ifFailureStatusCode_andNoContentTypeHeader() throws {
      let response = try makeResponse(statusCode: 404, accept: "application/json", contentType: nil)
      let disposition = validator.validate(response)
      XCTAssertEqual(disposition, .useErrorObjectResponseConverter)
   }

   func test_validator_disposesToUseObjectConverter_ifSuccessStatusCode_andNoHeaders() throws {
      let response = try makeResponse(statusCode: 200, accept: nil, contentType: nil)
      let disposition = validator.validate(response)
      XCTAssertEqual(disposition, .useSuccessObjectResponseConverter)
   }

   func test_validator_disposesToUseErrorConverter_ifFailureStatusCode_andNoHeaders() throws {
      let response = try makeResponse(statusCode: 404, accept: nil, contentType: nil)
      let disposition = validator.validate(response)
      XCTAssertEqual(disposition, .useErrorObjectResponseConverter)
   }

   func test_validator_disposesToCompleteWithErrorRegardlessStatusCode_ifMIMEsNotMatches() throws {
      let accept = "application/json"
      let contentType = "application/x-plist"
      let response = try makeResponse(
         statusCode: 200,
         accept: accept,
         contentType: contentType
      )
      let disposition = validator.validate(response)
      switch disposition {
      case let .completeWithError(
         StatusCodeContentTypeResponseValidatorError.unacceptableContentType(expected, received)
      ):
         XCTAssertEqual(expected, accept)
         XCTAssertEqual(received, contentType)
      default:
         XCTFail("Unexpected dispositions returned: \(disposition)")
      }
   }

   // MARK: - Factory

   private func makeResponse(
      statusCode: Int,
      accept: String?,
      contentType: String?
   ) throws -> Response {
      let url = try XCTUnwrap(URL(string: "https://service.com"))
      var request = URLRequest(url: url)
      request.allHTTPHeaderFields = accept.map { accept in
         ["Accept": accept]
      }

      return Response(
         request: request,
         statusCode: statusCode,
         headers: contentType.map { contentType in
            ["Content-Type": contentType]
         } ?? [:],
         body: Data()
      )
   }
}

extension ResponseValidationDisposition: Equatable {
   public static func ==(
      lhs: ResponseValidationDisposition,
      rhs: ResponseValidationDisposition
   ) -> Bool {
      switch (lhs, rhs) {
         case (.useSuccessObjectResponseConverter, .useSuccessObjectResponseConverter),
              (.useErrorObjectResponseConverter, .useErrorObjectResponseConverter),
              (.completeWithError, .completeWithError):
            return true
         default:
            return false
      }
   }
}
