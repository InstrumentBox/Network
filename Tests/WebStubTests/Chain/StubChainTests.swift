//
//  StubChainTests.swift
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

import NetworkTestUtils
import Testing
import Web
import WebCore

@Suite("Stub chain")
struct StubChainTests {
   @Test("Returns execution")
   func returnsExecution() async throws {
      let chain = makeStubChain()
      try await chain.registerFallbackResponse()
      #expect(await chain.dequeueNextExecution() != nil)
   }

   @Test("Returns nil if no records registered")
   func noRecordsRegistered() async {
      let chain = StubChain(configuration: StubbedWebClientConfiguration())
      let execution = await chain.dequeueNextExecution()
      #expect(execution == nil)
   }

   @Test("Throws registration error if no fallback client")
   func noFallbackWebClient() async throws {
      let chain = StubChain(configuration: StubbedWebClientConfiguration())

      await #expect(throws: StubChainError.cannotRegisterFallbackExecution) {
         try await chain.registerFallbackResponse()
      }
   }

   @Test("Returns last execution despite it's exhausted")
   func returnLastExecution() async throws {
      let chain = makeStubChain()
      try await chain.registerFallbackResponse()
      let execution1 = await chain.dequeueNextExecution()
      let execution2 = await chain.dequeueNextExecution()
      #expect(execution1 === execution2)
   }

   @Test("Drops execution if exhausted")
   func test_stubChain_dropsExecution_ifExhausted() async throws {
      let chain = makeStubChain()
      try await chain.registerResponse(at: #require(Responses.testObject))
      try await chain.registerFallbackResponse()

      let execution1 = await chain.dequeueNextExecution()
      let execution2 = await chain.dequeueNextExecution()

      #expect(execution1 is FilenameRequestExecution)
      #expect(execution2 is FallbackRequestExecution)
   }

   @Test("Drops execution only if usage count exceeded")
   func dropWhenUsageCountExceeded() async throws {
      let chain = makeStubChain()
      try await chain.registerResponse(at: #require(Responses.testObject), usageCount: 2)
      try await chain.registerFallbackResponse()

      let execution1 = await chain.dequeueNextExecution()
      let execution2 = await chain.dequeueNextExecution()
      let execution3 = await chain.dequeueNextExecution()

      #expect(execution1 is FilenameRequestExecution)
      #expect(execution2 is FilenameRequestExecution)
      #expect(execution1 === execution2)
      #expect(execution3 is FallbackRequestExecution)
   }

   @Test("Resets records")
   func resetRecords() async throws {
      let chain = makeStubChain()
      try await chain.registerFallbackResponse()
      var execution = await chain.dequeueNextExecution()
      #expect(execution != nil)
      await chain.reset()
      execution = await chain.dequeueNextExecution()
      #expect(execution == nil)
   }
}

// MARK: -

private func makeStubChain() -> StubChain {
   let fallbackWebClientConfiguration: URLSessionWebClientConfiguration = .ephemeral
   fallbackWebClientConfiguration.sessionConfiguration.protocolClasses = [TestObjectWebTestsURLProtocol.self]
   let fallbackWebClient = URLSessionWebClient(configuration: fallbackWebClientConfiguration)
   let stubbedWebClientConfiguration = StubbedWebClientConfiguration()
   stubbedWebClientConfiguration.fallbackWebClient = fallbackWebClient
   return StubChain(configuration: stubbedWebClientConfiguration)
}
