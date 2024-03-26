//
//  StubbedWebClientTestCase.swift
//
//  Copyright © 2023 Aleksei Zaikin.
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

import NetworkTestUtils
import WebCore
import WebStub
import XCTest

class StubbedWebClientTestCase: XCTestCase {
   func test_stubbedWebClient_registersStubbedResponse_andReturnsResult() async throws {
      let client = StubbedWebClient()
      let chain = client.stubChain(for: TestObjectRequest.self)
      try chain.registerResponse(at: XCTUnwrap(Responses.testObject))

      let object = try await client.execute(TestObjectRequest())
      XCTAssertEqual(object, .some)
   }

   func test_stubbedWebClient_registersStubbedResponsesInTheSameChain_andReturnsResults() async throws {
      let client = StubbedWebClient()
      try client
         .stubChain(for: TestObjectRequest.self)
         .registerResponse(at: XCTUnwrap(Responses.testObject))
      try client
         .stubChain(for: TestObjectRequest.self)
         .registerResponse(at: XCTUnwrap(Responses.apiError))

      let object = try await client.execute(TestObjectRequest())
      XCTAssertEqual(object, .some)

      do {
         _ = try await client.execute(TestObjectRequest())
         XCTFail("Unexpected object returned")
      } catch let error as APIError {
         XCTAssertEqual(error, .testObjectNotFound)
      } catch {
         XCTFail("Unexpected error thrown")
      }
   }

   func test_stubbedWebClient_usesFallbackWebClient() async throws {
      let client = makeStubbedWebClientWithFallbackWebClient()
      try client.stubChain(for: TestObjectRequest.self).registerFallbackResponse()
      let object = try await client.execute(TestObjectRequest())
      XCTAssertEqual(object, .some)
   }

   func test_stubbedWebClient_throwsError_ifCannotFindChain() async throws {
      let client = StubbedWebClient()
      do {
         _ = try await client.execute(TestObjectRequest())
         XCTFail("Unexpected object returned")
      } catch let error as StubbedWebClientError {
         XCTAssertEqual(error, .cannotFindResponseChain("\(TestObjectRequest.self)"))
      } catch {
         XCTFail("Unexpected error thrown")
      }
   }

   func test_stubbedWebClient_throwsError_ifResponseNotRegistered() async throws {
      let client = StubbedWebClient()
      _ = client.stubChain(for: TestObjectRequest.self)
      do {
         _ = try await client.execute(TestObjectRequest())
         XCTFail("Unexpected object returned")
      } catch let error as StubbedWebClientError {
         XCTAssertEqual(error, .cannotFindRequestExecution("\(TestObjectRequest.self)"))
      } catch {
         XCTFail("Unexpected error thrown")
      }
   }

   func test_stubbedWebClient_usesFallbackWebClient_ifCannotFindChain() async throws {
      let client = makeStubbedWebClientWithFallbackWebClient()
      let object = try await client.execute(TestObjectRequest())
      XCTAssertEqual(object, .some)
   }

   func test_stubbedWebClient_usesFallbackWebClient_ifResponseNotRegistered() async throws {
      let client = makeStubbedWebClientWithFallbackWebClient()
      _ = client.stubChain(for: TestObjectRequest.self)
      let object = try await client.execute(TestObjectRequest())
      XCTAssertEqual(object, .some)
   }
}

// MARK: -

private func makeStubbedWebClientWithFallbackWebClient() -> StubbedWebClient {
   let fallbackWebClientConfiguration: URLSessionWebClientConfiguration = .ephemeral
   fallbackWebClientConfiguration.sessionConfiguration.protocolClasses = [TestObjectWebTestsURLProtocol.self]
   let fallbackWebClient = URLSessionWebClient(configuration: fallbackWebClientConfiguration)
   let configuration = StubbedWebClientConfiguration()
   configuration.fallbackWebClient = fallbackWebClient
   configuration.fallbackRequestsIfNoResponsesRegistered = true
   return StubbedWebClient(configuration: configuration)
}
