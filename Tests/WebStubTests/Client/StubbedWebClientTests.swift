//
//  StubbedWebClientTests.swift
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
import Testing
import WebCore
import WebStub

@Suite("Stubbed web client")
struct StubbedWebClientTests {
   private let client = StubbedWebClient()

   // MARK: - Tests

   @Test("Registers stubbed response and returns result")
   func registerStubAndReturnObject() async throws {
      let chain = await client.stubChain(for: TestObjectRequest.self)
      try await chain.registerResponse(at: #require(Responses.testObject))

      let object = try await client.execute(TestObjectRequest())
      #expect(object == .some)
   }

   @Test("Registers stubbed response in the same chain and return result")
   func registerInTheSameChainAndReturnObject() async throws {
      try await client
         .stubChain(for: TestObjectRequest.self)
         .registerResponse(at: #require(Responses.testObject))
      try await client
         .stubChain(for: TestObjectRequest.self)
         .registerResponse(at: #require(Responses.apiError))

      let object = try await client.execute(TestObjectRequest())
      #expect(object == .some)

      await #expect(throws: APIError.testObjectNotFound) {
         _ = try await client.execute(TestObjectRequest())
      }
   }

   @Test("Uses fallback web client")
   func test_stubbedWebClient_usesFallbackWebClient() async throws {
      let client = makeStubbedWebClientWithFallbackWebClient(fallbackWhenNoResponses: false)
      try await client.stubChain(for: TestObjectRequest.self).registerFallbackResponse()
      let object = try await client.execute(TestObjectRequest())
      #expect(object == .some)
   }

   @Test("Throws error if couldn't find chain")
   func chainNotFound() async throws {
      await #expect(throws: StubbedWebClientError.cannotFindResponseChain("\(TestObjectRequest.self)")) {
         _ = try await client.execute(TestObjectRequest())
      }
   }

   @Test("Throws error if response not registered")
   func responseNotRegistered() async throws {
      _ = await client.stubChain(for: TestObjectRequest.self)
      await #expect(throws: StubbedWebClientError.cannotFindRequestExecution("\(TestObjectRequest.self)")) {
         _ = try await client.execute(TestObjectRequest())
      }
   }

   @Test("Uses fallback web client if couldn't find chain")
   func fallbackWhenNoChain() async throws {
      let client = makeStubbedWebClientWithFallbackWebClient(fallbackWhenNoResponses: true)
      let object = try await client.execute(TestObjectRequest())
      #expect(object == .some)
   }

   @Test("Uses fallback web client if response no registered")
   func fallbackWhenNoResponse() async throws {
      let client = makeStubbedWebClientWithFallbackWebClient(fallbackWhenNoResponses: true)
      _ = await client.stubChain(for: TestObjectRequest.self)
      let object = try await client.execute(TestObjectRequest())
      #expect(object == .some)
   }
}

// MARK: -

private func makeStubbedWebClientWithFallbackWebClient(fallbackWhenNoResponses: Bool) -> StubbedWebClient {
   let fallbackWebClientConfiguration: URLSessionWebClient.Configuration = .ephemeral
   fallbackWebClientConfiguration.sessionConfiguration.protocolClasses = [TestObjectWebTestsURLProtocol.self]
   let fallbackWebClient = URLSessionWebClient(configuration: fallbackWebClientConfiguration)
   let configuration = StubbedWebClientConfiguration()
   configuration.fallbackWebClient = fallbackWebClient
   configuration.fallbackRequestsIfNoResponsesRegistered = fallbackWhenNoResponses
   return StubbedWebClient(configuration: configuration)
}
