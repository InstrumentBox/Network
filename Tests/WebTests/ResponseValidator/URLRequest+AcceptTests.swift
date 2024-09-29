//
//  URLRequest+AcceptTests.swift
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

@Suite("URLRequest accept header extensions")
struct URLRequestAcceptTests {
   @Test("Returns empty array if no header")
   func extractWhenNotPresented() throws {
      let request = try makeRequest(accept: nil)
      let mimes = request.acceptMIMEs()
      #expect(mimes.isEmpty)
   }

   @Test("Returns array with the only MIME")
   func extractWhenTheOnlyMIME() throws {
      let expectedMIMEs = [MIME(type: "application", subtype: "json")]
      let request = try makeRequest(accept: "application/json")
      let mimes = request.acceptMIMEs()
      #expect(mimes == expectedMIMEs)
   }

   @Test("Returns all MIMEs from accept header")
   func extractWhenMultipleMIMEs() throws {
      let expectedMIMEs = [
         MIME(type: "application", subtype: "json"),
         MIME(type: "application", subtype: "x-plist"),
         MIME(type: "*", subtype: "*")
      ]
      let request = try makeRequest(
         accept: "application/json; q=1.0, application/x-plist; q=0.9, */*; q=0.7"
      )
      let mimes = request.acceptMIMEs()
      #expect(mimes == expectedMIMEs)
   }
}

// MARK: -

private func makeRequest(accept: String?) throws -> URLRequest {
   let url = try #require(URL(string: "https://service.com"))
   var request = URLRequest(url: url)
   request.allHTTPHeaderFields = accept.map { accept in
      ["Accept": accept]
   }
   return request
}
