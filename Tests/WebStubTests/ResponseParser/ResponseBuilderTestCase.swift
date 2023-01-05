//
//  ResponseBuilderTestCase.swift
//
//  Copyright © 2024 Aleksei Zaikin.
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
import WebStub

import XCTest

class ResponseBuilderTestCase: XCTestCase {
   func test_responseBuilder_returnsResponse() throws {
      let request = try URLRequest(url: XCTUnwrap(URL(string: "https://api.myservice.com/")))
      let builder = ResponseBuilder(request: request)
      builder.setStatusCode(200)
      let response = try builder.response

      XCTAssertEqual(response.request, request)
      XCTAssertEqual(response.statusCode, 200)
      XCTAssertTrue(response.headers.isEmpty)
      XCTAssertTrue(response.body.isEmpty)
   }

   func test_responseBuilder_throwsError_ifNoStatusCodeSet() throws {
      let request = try URLRequest(url: XCTUnwrap(URL(string: "https://api.myservice.com/")))
      let builder = ResponseBuilder(request: request)
      do {
         _ = try builder.response
         XCTFail("Unexpected response returned")
      } catch let error as ResponseParserError {
         XCTAssertEqual(error, .statusCodeMissed)
      } catch {
         XCTFail("Unexpected error thrown")
      }
   }
}
