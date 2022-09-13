//
//  URL+ConstructionTestCase.swift
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

class URLConstructionTestCase: XCTestCase {
   private let baseURL = URL(string: "https://api.service.com/v1/")

   // MARK: - Test Cases

   func test_url_isConstructedFromPathAndBaseURL() throws {
      let expectedURL = URL(string: "https://api.service.com/v1/test/endpoint")
      let resultURL = try URL(path: "test/endpoint", baseURL: baseURL)
      XCTAssertEqual(resultURL.absoluteString, expectedURL?.absoluteString)
   }

   func test_url_isConstructedFromPathOnly_ifItContainsFullURL() throws {
      let expectedURL = URL(string: "https://api.other.service.com/v1/test/endpoint")
      let resultURL = try URL(path: "https://api.other.service.com/v1/test/endpoint", baseURL: baseURL)
      XCTAssertEqual(resultURL.absoluteString, expectedURL?.absoluteString)
   }

   func test_url_isConstructedWithQuery() throws {
      let expectedURL = URL(string: "https://api.service.com/v1/test/endpoint?params%5Bkey%5D=value")
      let url = try URL(path: "test/endpoint", baseURL: baseURL, query: ["params": ["key": "value"]])
      XCTAssertEqual(url.absoluteString, expectedURL?.absoluteString)
   }

   func test_urlInitializer_throwsError() {
      XCTAssertThrowsError(try URL(path: " test/endpoint", baseURL: baseURL)) { error in
         guard case URLConstructionError.cannotConstructURL(" test/endpoint", baseURL) = error else {
            XCTFail("URL successfully constructed unexpectedly")
            return
         }
      }
   }
}
