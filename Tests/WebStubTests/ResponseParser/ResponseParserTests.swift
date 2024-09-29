//
//  ResponseParserTests.swift
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

import Foundation
import Testing

@Suite("Response parser")
struct ResponseParserTests {
   private let expectedHeaders = [
      "Content-Type": "application/json; charset=utf-8",
      "Content-Lang": "en"
   ]
   private let expectedBodyString = "hello\nworld\n"

   // MARK: - Tests

   @Test("Returns response when all fields exist")
   func fullResponse() throws {
      let parser = try makeParser(responseName: "Full")
      let response = try parser.parse()

      #expect(response.statusCode == 200)
      #expect(response.headers == expectedHeaders)

      let bodyString = try #require(String(data: response.body, encoding: .utf8))
      #expect(bodyString == expectedBodyString)
   }

   @Test("Returns response when body is empty")
   func emptyBody() throws {
      let parser = try makeParser(responseName: "EmptyBody")
      let response = try parser.parse()

      #expect(response.statusCode == 200)
      #expect(response.headers == expectedHeaders)
      #expect(response.body.isEmpty)
   }

   @Test("Returns response if no headers")
   func noHeaders() throws {
      let parser = try makeParser(responseName: "NoHeaders")
      let response = try parser.parse()

      #expect(response.statusCode == 200)
      #expect(response.headers.isEmpty)

      let bodyString = try #require(String(data: response.body, encoding: .utf8))
      #expect(bodyString == expectedBodyString)
   }

   @Test("Returns response when just status code")
   func justStatusCode() throws {
      let parser = try makeParser(responseName: "JustStatusCode")
      let response = try parser.parse()

      #expect(response.statusCode == 404)
      #expect(response.headers.isEmpty)
      #expect(response.body.isEmpty)
   }

   @Test("Parses headers as body when empty line between status code and headers")
   func test_responseParser_parsesHeadersAsBody_ifEmptyLineBetweenStatusCodeAndHeaders() throws {
      let parser = try makeParser(responseName: "HeadersAsBody")
      let response = try parser.parse()

      #expect(response.statusCode == 200)
      #expect(response.headers.isEmpty)

      let bodyString = try #require(String(data: response.body, encoding: .utf8))
      let expectedBodyString =
         "Content-Type: application/json; charset=utf-8\nContent-Lang: en\n\n" +
         self.expectedBodyString
      #expect(bodyString == expectedBodyString)
   }

   @Test("Throws error if status code missed")
   func noStatusCode() throws {
      let parser = try makeParser(responseName: "NoStatusCode")
      #expect(throws: ResponseParserError.incorrectStatusCodeData) {
         _ = try parser.parse()
      }
   }

   @Test("Throws error if incorrect header")
   func incorrectHeader() throws {
      let parser = try makeParser(responseName: "IncorrectHeader")
      #expect(throws: ResponseParserError.incorrectHeader("SomeHeader")) {
         _ = try parser.parse()
      }
   }

   @Test("Throws error if incorrect status code")
   func incorrectStatusCode() throws {
      let parser = try makeParser(responseName: "IncorrectStatusCode")
      #expect(throws: ResponseParserError.incorrectStatusCodeData) {
         _ = try parser.parse()
      }
   }
}

// MARK: -

private func makeParser(responseName: String) throws -> ResponseParser {
   let bundle: Bundle = .module
   let responseURL = try #require(bundle.url(forResource: responseName, withExtension: "response"))
   let request = try URLRequest(url: #require(URL(string: "https://api.myserice.com")))
   return try #require(ResponseParser(request: request, responseURL: responseURL))
}
