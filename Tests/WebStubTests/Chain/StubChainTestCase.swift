//
//  StubChainTestCase.swift
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
import Web
import WebCore
import XCTest

class StubChainTestCase: XCTestCase {
   func test_stubChain_returnsExecution() async throws {
      let chain = makeStubChain()
      try chain.registerFallbackResponse()
      XCTAssertNotNil(chain.dequeueNextExecution())
   }

   func test_stubChain_returnsNil_ifNoRecordsRegistered() async throws {
      let chain = StubChain(configuration: StubbedWebClientConfiguration())
      let execution = chain.dequeueNextExecution()
      XCTAssertNil(execution)
   }

   func test_stubChain_throwsFallbackRegistrationError_ifNoFallbackWebClient() async throws {
      let chain = StubChain(configuration: StubbedWebClientConfiguration())
      do {
         try chain.registerFallbackResponse()
         XCTFail("Unexpected successful registration")
      } catch let error as StubChainError {
         XCTAssertEqual(error, .cannotRegisterFallbackExecution)
      } catch {
         XCTFail("Unexpected error thrown \(error)")
      }
   }

   func test_stubChain_returnsLastExecution_despiteItIsExhausted() async throws {
      let chain = makeStubChain()
      try chain.registerFallbackResponse()
      let execution1 = chain.dequeueNextExecution()
      let execution2 = chain.dequeueNextExecution()
      XCTAssertTrue(execution1 === execution2)
   }

   func test_stubChain_dropsExecution_ifExhausted() async throws {
      let chain = makeStubChain()
      try chain.registerResponse(at: XCTUnwrap(Responses.testObject))
      try chain.registerFallbackResponse()

      let execution1 = chain.dequeueNextExecution()
      let execution2 = chain.dequeueNextExecution()

      XCTAssertTrue(execution1 is FilenameRequestExecution)
      XCTAssertTrue(execution2 is FallbackRequestExecution)
   }

   func test_stubChain_dropsExecution_onlyWhenUsageCountExceeded() async throws {
      let chain = makeStubChain()
      try chain.registerResponse(at: XCTUnwrap(Responses.testObject), usageCount: 2)
      try chain.registerFallbackResponse()

      let execution1 = chain.dequeueNextExecution()
      let execution2 = chain.dequeueNextExecution()
      let execution3 = chain.dequeueNextExecution()

      XCTAssertTrue(execution1 is FilenameRequestExecution)
      XCTAssertTrue(execution2 is FilenameRequestExecution)
      XCTAssertTrue(execution1 === execution2)
      XCTAssertTrue(execution3 is FallbackRequestExecution)
   }

   func test_stubChain_resetsRecords() async throws {
      let chain = makeStubChain()
      try chain.registerFallbackResponse()
      var execution = chain.dequeueNextExecution()
      XCTAssertNotNil(execution)
      chain.reset()
      execution = chain.dequeueNextExecution()
      XCTAssertNil(execution)
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
