//
//  ResponseTests.swift
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
import Testing

@Suite("Response")
struct ResponseTests {
   @Test("Returns Content-Type MIME", arguments: [
      (nil, nil),
      ("application/json", MIME(type: "application", subtype: "json")),
      ("application/json; charset=utf8", MIME(type: "application", subtype: "json")),
   ])
   func extractContentType(contentType: String?, expectedMIME: MIME?) throws {
      let response = try Response(
         request: URLRequest(url: #require(URL(string: "https://service.com"))),
         statusCode: 200,
         headers: contentType.map { contentType in
            ["Content-Type": contentType]
         } ?? [:],
         body: Data()
      )
      let mime = response.contentTypeMIME()
      #expect(mime == expectedMIME)
   }
}
