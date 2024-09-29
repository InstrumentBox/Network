//
//  URL+ConstructionTests.swift
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

@Suite("URL construction extensions")
struct URLConstructionTests {
   private let baseURL = URL(string: "https://api.service.com/v1/")

   // MARK: - Tests

   @Test("Constructed path and base URL")
   func makeWithPathAndBaseURL() throws {
      let expectedURL = URL(string: "https://api.service.com/v1/test/endpoint")
      let url = try URL(path: "test/endpoint", baseURL: baseURL)
      #expect(url.absoluteString == expectedURL?.absoluteString)
   }

   @Test("Constructed from path only if path is full URL")
   func makeWhenPathIsFullURL() throws {
      let expectedURL = URL(string: "https://api.other.service.com/v1/test/endpoint")
      let url = try URL(path: "https://api.other.service.com/v1/test/endpoint", baseURL: baseURL)
      #expect(url.absoluteString == expectedURL?.absoluteString)
   }

   @Test("Constructed with query")
   func makeWithQuery() throws {
      let expectedURL = URL(string: "https://api.service.com/v1/test/endpoint?params%5Bkey%5D=value")
      let url = try URL(path: "test/endpoint", baseURL: baseURL, query: ["params": ["key": "value"]])
      #expect(url.absoluteString == expectedURL?.absoluteString)
   }

   @Test("Constructed with empty query")
   func makeWithEmptyQuery() throws {
      let expectedURL = URL(string: "https://api.service.com/v1/test/endpoint")
      let url = try URL(path: "test/endpoint", baseURL: baseURL, query: [:])
      #expect(url.absoluteString == expectedURL?.absoluteString)
   }

   @Test("Constructed with query in path")
   func makeWithQueryInPath() throws {
      let expectedURL = URL(string: "https://api.service.com/v1/test/endpoint?params%5Bkey%5D=value")
      let url = try URL(path: "test/endpoint?params[key]=value", baseURL: baseURL)
      #expect(url.absoluteString == expectedURL?.absoluteString)
   }

   @Test("Constructed by merging query in path and query dictionary")
   func makeByMergingQuery() throws {
      let expectedURL = URL(string: "https://api.service.com/v1/test/endpoint?params%5Bkey%5D=value&params%5Bother_key%5D=other_value")
      let url = try URL(
         path: "test/endpoint?params[key]=value",
         baseURL: baseURL,
         query: ["params": ["other_key": "other_value"]]
      )
      #expect(url.absoluteString == expectedURL?.absoluteString)
   }

   @Test("Throws construction error")
   func throwConstructionError() throws {
      #expect(throws: URLConstructionError.cannotConstructURL(path: "https:// test endpoint", baseURL: baseURL)) {
         try URL(path: "https:// test endpoint", baseURL: baseURL)
      }
   }
}
