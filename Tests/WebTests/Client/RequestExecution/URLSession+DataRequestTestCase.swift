//
//  URLSession+DataRequestTestCase.swift
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

class URLSessionDataRequestTestCase: XCTestCase {
   // MARK: - Test Cases

   func test_session_returnsResponse_usingCommonFunction() async throws {
      let session = makeSession(protocolClass: WebTestsURLProtocol.self)
      let request = try makeURLRequest()
      let response = try await session.data(for: request)
      XCTAssertEqual(response.request, request)
      XCTAssertEqual(response.statusCode, 200)
      XCTAssertEqual(response.headers, ["Content-Type": "application/octet-stream; charset=utf8"])
      XCTAssertEqual(response.body, Data([0x01, 0x02, 0x03]))
   }

   @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
   func test_session_returnsResponse_usingNewAPI() async throws {
      let session = makeSession(protocolClass: WebTestsURLProtocol.self)
      let request = try makeURLRequest()
      let response = try await session.newData(for: request)
      XCTAssertEqual(response.request, request)
      XCTAssertEqual(response.statusCode, 200)
      XCTAssertEqual(response.headers, ["Content-Type": "application/octet-stream; charset=utf8"])
      XCTAssertEqual(response.body, Data([0x01, 0x02, 0x03]))
   }

   func _test_session_returnsResponse_usingPrevAPI() async throws {
      let session = makeSession(protocolClass: WebTestsURLProtocol.self)
      let request = try makeURLRequest()
      let response = try await session.prevData(for: request)
      XCTAssertEqual(response.request, request)
      XCTAssertEqual(response.statusCode, 200)
      XCTAssertEqual(response.headers, ["Content-Type": "application/octet-stream; charset=utf8"])
      XCTAssertEqual(response.body, Data([0x01, 0x02, 0x03]))
   }

   @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
   func test_session_throwsBadServerResponseError_usingNewAPI() async {
      do {
         let session = makeSession(protocolClass: NotHTTPResponseWebTestsURLProtocol.self)
         let request = try makeURLRequest()
         _ = try await session.newData(for: request)
         XCTFail("Unexpected successful result")
      } catch let error as URLError {
         XCTAssertEqual(error.code, .badServerResponse)
      } catch {
         XCTFail("Unexpected error thrown: \(error)")
      }
   }

   func _test_session_throwsBadServerResponseError_usingPrevAPI() async {
      do {
         let session = makeSession(protocolClass: NotHTTPResponseWebTestsURLProtocol.self)
         let request = try makeURLRequest()
         _ = try await session.prevData(for: request)
         XCTFail("Unexpected successful result")
      } catch let error as URLError {
         XCTAssertEqual(error.code, .badServerResponse)
      } catch {
         XCTFail("Unexpected error thrown: \(error)")
      }
   }

   func _test_session_throwsURLSystemError_usingPrevAPI() async {
      do {
         let session = makeSession(protocolClass: ErrorWebTestsURLProtocol.self)
         let request = try makeURLRequest()
         _ = try await session.prevData(for: request)
         XCTFail("Unexpected successful result")
      } catch let error as URLError {
         XCTAssertEqual(error.code, .cancelled)
      } catch {
         XCTFail("Unexpected error thrown: \(error)")
      }
   }

   // MARK: - Factory

   private func makeSession(protocolClass: URLProtocol.Type) -> URLSession {
      let configuration: URLSessionConfiguration = .ephemeral
      configuration.protocolClasses = [protocolClass]
      return URLSession(configuration: configuration)
   }

   private func makeURLRequest() throws -> URLRequest {
      let url = try XCTUnwrap(URL(string: "https://service.com"))
      let request = URLRequest(url: url)
      return request
   }
}
