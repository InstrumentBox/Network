//
//  ResponseBuilderTests.swift
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

import Foundation
import Testing

@Suite("Response builder")
struct ResponseBuilderTests {
   @Test("Returns response")
   func returnResponse() throws {
      let request = try URLRequest(url: #require(URL(string: "https://api.myservice.com/")))
      let builder = ResponseBuilder(request: request)
      builder.setStatusCode(200)
      let response = try builder.response

      #expect(response.request == request)
      #expect(response.statusCode == 200)
      #expect(response.headers.isEmpty)
      #expect(response.body.isEmpty)
   }

   @Test("Throws error if no status code set")
   func buildWithNoStatusCode() throws {
      let request = try URLRequest(url: #require(URL(string: "https://api.myservice.com/")))
      let builder = ResponseBuilder(request: request)

      #expect(throws: ResponseParserError.statusCodeMissed) {
         try builder.response
      }
   }
}
