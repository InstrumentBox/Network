//
//  StatusCodeContentTypeResponseValidatorTests.swift
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

import Foundation
import NetworkTestUtils
import Testing

@Suite("Status code and content type response validator")
struct StatusCodeContentTypeResponseValidatorTests {
   private let validator = StatusCodeContentTypeResponseValidator()

   // MARK: - Tests

   @Test("Disposes to use object response converter", arguments: [
      ("application/json", "application/json"),
      (nil, "application/json"),
      ("application/json", nil),
      (nil, nil)
   ])
   func validateSuccessfulResponse(accept: String?, contentType: String?) throws {
      let response = try makeResponse(statusCode: 200, accept: accept, contentType: contentType)
      let disposition = validator.validate(response)
      #expect(disposition is SuccessObjectResponseValidationDisposition)
   }

   @Test("Disposes to use error response converter", arguments: [
      ("application/json", "application/json"),
      (nil, "application/json"),
      ("application/json", nil),
      (nil, nil)
   ])
   func validateResponseWithAPIError(accept: String?, contentType: String?) throws {
      let response = try makeResponse(statusCode: 404, accept: accept, contentType: contentType)
      let disposition = validator.validate(response)
      #expect(disposition is ErrorObjectResponseValidationDisposition)
   }

   @Test("Throws error regardless status code if MIMEs don't match")
   func validateResponseWithNotMatchedContentType() throws {
      let accept = "application/json"
      let contentType = "application/x-plist"
      let response = try makeResponse(
         statusCode: 200,
         accept: accept,
         contentType: contentType
      )
      let disposition = try #require(validator.validate(response) as? ValidationErrorResponseValidationDisposition)
      #expect(throws: StatusCodeContentTypeResponseValidatorError.unacceptableContentType(
         expected: accept,
         received: contentType
      )) {
         try disposition.processResponse(response, for: TestObjectRequest())
      }
   }
}

// MARK: -

private func makeResponse(
   statusCode: Int,
   accept: String?,
   contentType: String?
) throws -> Response {
   let url = try #require(URL(string: "https://service.com"))
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
