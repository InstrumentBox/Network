//
//  ResponseTestCase.swift
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

class ResponseTestCase: XCTestCase {
   // MARK: - Test Cases

   func test_response_isInitedFromHTTPURLResponseCorrectly() throws {
      let body = Data([0x01, 0x02, 0x03])
      let url = try XCTUnwrap(URL(string: "https://serivce.com"))
      let statusCode = 200
      let request = URLRequest(url: url)
      let headers: [String: String] = ["Content-Type": "application/json"]
      let httpURLResponse = try XCTUnwrap(HTTPURLResponse(
         url: url,
         statusCode: statusCode,
         httpVersion: nil,
         headerFields: headers
      ))

      let response = Response(request: request, httpURLResponse: httpURLResponse, body: body)
      XCTAssertEqual(response.request, request)
      XCTAssertEqual(response.statusCode, statusCode)
      XCTAssertEqual(response.headers, headers)
      XCTAssertEqual(response.body, body)
   }

   func test_response_returnsNilMIME_ifNoContentType() throws {
      let response = try makeResponse(contentType: nil)
      let mime = response.contentTypeMIME()
      XCTAssertNil(mime)
   }

   func test_response_returnsMIME_ifContentType() throws {
      let expectedMIME = MIME(type: "application", subtype: "json")
      let response = try makeResponse(contentType: "application/json")
      let mime = response.contentTypeMIME()
      XCTAssertEqual(mime, expectedMIME)
   }

   func test_response_returnsMIME_ifContentType_withCharset() throws {
      let expectedMIME = MIME(type: "application", subtype: "json")
      let response = try makeResponse(contentType: "application/json; charset=utf8")
      let mime = response.contentTypeMIME()
      XCTAssertEqual(mime, expectedMIME)
   }

   // MARK: - Factory

   private func makeResponse(contentType: String?) throws -> Response {
      let url = try XCTUnwrap(URL(string: "https://service.com"))
      let request = URLRequest(url: url)
      return Response(
         request: request,
         statusCode: 200,
         headers: contentType.map { contentType in
            ["Content-Type": contentType]
         } ?? [:],
         body: Data()
      )
   }
}
