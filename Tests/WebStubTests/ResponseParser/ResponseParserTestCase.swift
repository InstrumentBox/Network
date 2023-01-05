//
//  ResponseParserTestCase.swift
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
import WebStub

import XCTest

class ResponseParserTestCase: XCTestCase {
   private let expectedHeaders = [
      "Content-Type": "application/json; charset=utf-8",
      "Content-Lang": "en"
   ]
   private let expectedBodyString = "hello\nworld\n"

   // MARK: - Test Cases

   func test_responseParser_returnsResponse_ifAllFieldsExists() throws {
      let parser = try makeParser(responseName: "Full")
      let response = try parser.parse()

      XCTAssertEqual(response.statusCode, 200)
      XCTAssertEqual(response.headers, expectedHeaders)

      let bodyString = try XCTUnwrap(String(data: response.body, encoding: .utf8))
      XCTAssertEqual(bodyString, expectedBodyString)
   }

   func test_responseParser_returnsResponse_ifEmptyBody() throws {
      let parser = try makeParser(responseName: "EmptyBody")
      let response = try parser.parse()

      XCTAssertEqual(response.statusCode, 200)
      XCTAssertEqual(response.headers, expectedHeaders)
      XCTAssertTrue(response.body.isEmpty)
   }

   func test_responseParser_returnsResponse_ifNoHeaders() throws {
      let parser = try makeParser(responseName: "NoHeaders")
      let response = try parser.parse()

      XCTAssertEqual(response.statusCode, 200)
      XCTAssertTrue(response.headers.isEmpty)

      let bodyString = try XCTUnwrap(String(data: response.body, encoding: .utf8))
      XCTAssertEqual(bodyString, expectedBodyString)
   }

   func test_responseParser_returnsResponse_ifJustStatusCode() throws {
      let parser = try makeParser(responseName: "JustStatusCode")
      let response = try parser.parse()

      XCTAssertEqual(response.statusCode, 404)
      XCTAssertTrue(response.headers.isEmpty)
      XCTAssertTrue(response.body.isEmpty)
   }

   func test_responseParser_parsesHeadersAsBody_ifEmptyLineBetweenStatusCodeAndHeaders() throws {
      let parser = try makeParser(responseName: "HeadersAsBody")
      let response = try parser.parse()

      XCTAssertEqual(response.statusCode, 200)
      XCTAssertTrue(response.headers.isEmpty)

      let bodyString = try XCTUnwrap(String(data: response.body, encoding: .utf8))
      let expectedBodyString =
         "Content-Type: application/json; charset=utf-8\nContent-Lang: en\n\n" +
         self.expectedBodyString
      XCTAssertEqual(bodyString, expectedBodyString)
   }

   func test_responseParser_throwsError_ifNoStatusCode() throws {
      let parser = try makeParser(responseName: "NoStatusCode")
      do {
         _ = try parser.parse()
         XCTFail("Unexpectedly parsed response")
      } catch let error as ResponseParserError {
         XCTAssertEqual(error, .incorrectStatusCodeData)
      } catch {
         XCTFail("Unexpected error \(error)")
      }
   }

   func test_responseParser_throwsError_ifIncorrectHeader() throws {
      let parser = try makeParser(responseName: "IncorrectHeader")
      do {
         _ = try parser.parse()
         XCTFail("Unexpectedly parsed response")
      } catch let error as ResponseParserError {
         XCTAssertEqual(error, .incorrectHeader("SomeHeader"))
      } catch {
         XCTFail("Unexpected error \(error)")
      }
   }
}

// MARK: -

private func makeParser(responseName: String) throws -> ResponseParser {
   let bundle: Bundle = .module
   let responseURL = try XCTUnwrap(bundle.url(forResource: responseName, withExtension: "response"))
   let request = try URLRequest(url: XCTUnwrap(URL(string: "https://api.myserice.com")))
   return try XCTUnwrap(ResponseParser(request: request, responseURL: responseURL))
}
