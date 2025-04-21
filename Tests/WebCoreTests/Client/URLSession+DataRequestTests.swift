//
//  URLSession+DataRequestTests.swift
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
import WebCore

import Foundation
import NetworkTestUtils
import Testing

@Suite("URLSession data request extensions")
struct URLSessionDataRequestTests {
   // MARK: - Test

   @Test("Returns response using common function")
   func useCommonFunction() async throws {
      let session = makeSession(protocolClass: WebTestsURLProtocol.self)
      let request = try makeURLRequest()
      let response = try await session.data(for: request)
      #expect(response.request == request)
      #expect(response.statusCode == 200)
      #expect(response.headers == ["Content-Type": "application/octet-stream; charset=utf8"])
      #expect(response.body == Data([0x01, 0x02, 0x03]))
   }

   @Test("Returns response using new API")
   @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
   func useNewAPI() async throws {
      let session = makeSession(protocolClass: WebTestsURLProtocol.self)
      let request = try makeURLRequest()
      let response = try await session.newData(for: request)
      #expect(response.request == request)
      #expect(response.statusCode == 200)
      #expect(response.headers == ["Content-Type": "application/octet-stream; charset=utf8"])
      #expect(response.body == Data([0x01, 0x02, 0x03]))
   }

   @Test("Returns response using prev API", .disabled("unexpectedly not responding"))
   func usePrevAPI() async throws {
      let session = makeSession(protocolClass: WebTestsURLProtocol.self)
      let request = try makeURLRequest()
      let response = try await session.prevData(for: request)
      #expect(response.request == request)
      #expect(response.statusCode == 200)
      #expect(response.headers == ["Content-Type": "application/octet-stream; charset=utf8"])
      #expect(response.body == Data([0x01, 0x02, 0x03]))
   }

   @Test("Throws bad server response error using new API")
   @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
   func badServerResponseUsingNewAPI() async throws {
      let session = makeSession(protocolClass: NotHTTPResponseWebTestsURLProtocol.self)
      let request = try makeURLRequest()

      await #expect(throws: URLError(.badServerResponse)) {
         _ = try await session.newData(for: request)
      }
   }

   @Test("Throws bad server response error using prev API", .disabled("unexpectedly not responding"))
   func badServerResponseUsingPrevAPI() async throws {
      let session = makeSession(protocolClass: NotHTTPResponseWebTestsURLProtocol.self)
      let request = try makeURLRequest()

      await #expect(throws: URLError(.badServerResponse)) {
         _ = try await session.prevData(for: request)
      }
   }

   @Test("Throws URL system error using prev API", .disabled("unexpectedly not responding"))
   func urlSystemErrorUsingPrevAPI() async throws {
      let session = makeSession(protocolClass: NotHTTPResponseWebTestsURLProtocol.self)
      let request = try makeURLRequest()

      await #expect(throws: URLError(.cancelled)) {
         _ = try await session.prevData(for: request)
      }
   }
}

// MARK: -

private func makeSession(protocolClass: URLProtocol.Type) -> URLSession {
   let configuration: URLSessionConfiguration = .ephemeral
   configuration.protocolClasses = [protocolClass]
   return URLSession(configuration: configuration)
}

private func makeURLRequest() throws -> URLRequest {
   let url = try #require(URL(string: "https://service.com"))
   let request = URLRequest(url: url)
   return request
}
