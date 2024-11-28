//
//  TwoFactorAuthenticationChallengeTests.swift
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
import Web

@Suite("2FA")
struct TwoFactorAuthenticationChallengeTests {
   @Test("Doesn't delegate work to handler")
   func successfulStatusCode() async throws {
      var isHandled = false
      try await makeChallengeAndRun(statusCode: 200) { c in
         isHandled = true
         await c.complete()
      }
      #expect(!isHandled)
   }

   @Test("Delegates work to handler")
   func twoFactorAuthStatusCode() async throws {
      var isHandled = false
      try await makeChallengeAndRun { c in
         isHandled = true
         await c.complete()
      }
      #expect(isHandled)
   }

   @Test("Challenge returns correct status code")
   func statusCodeFromChallenge() async throws {
      var statusCode: Int?
      try await makeChallengeAndRun { c in
         statusCode = await c.responseStatusCode
         await c.complete()
      }
      #expect(statusCode == 600)
   }

   @Test("Challenge returns converted object")
   func convertedObjectFromChallenge() async throws {
      var object: TestObject?
      try await makeChallengeAndRun { c in
         object = try? await c.convertedResponse(using: JSONDecoderResponseConverter<TestObject>())
         await c.complete()
      }
      #expect(object == .some)
   }

   @Test("Throws cancelled error if cancelled")
   func cancelChallenge() async throws {
      await #expect(throws: TwoFactorAuthenticationChallengeError.cancelled) {
         try await makeChallengeAndRun { c in
            await c.cancel()
         }
      }
   }

   @Test("Throws completion error if completed with error")
   func completeWithCustomError() async throws {
      let expectedError = NSError(domain: "web.tests.domain", code: 600, userInfo: nil)
      await #expect(throws: expectedError) {
         try await makeChallengeAndRun { c in
            await c.complete(with: expectedError)
         }
      }
   }

   @Test("Returns actual response if authenticated and completed")
   func authenticateAndComplete() async throws {
      var request = try URLRequest(url: #require(URL(string: "https://service.com")))
      request.addValue("1234", forHTTPHeaderField: "X-2FA")
      let expectedResponse = Response(
         request: request,
         statusCode: 200,
         headers: ["Content-Type": "application/json; charset=utf8"],
         body: TestObject.some.toJSONData()
      )

      let response = try await makeChallengeAndRun { c in
         Task {
            do {
               try await c.authenticate(headerName: "X-2FA", headerValue: "1234")
               await c.complete()
            } catch {
               await c.complete(with: error)
            }
         }
      }

      #expect(response == expectedResponse)
   }

   @Test("Return the same response if refreshed")
   func refreshChallenge() async throws {
      let expectedResponse = try Response(
         request: URLRequest(url: #require(URL(string: "https://service.com"))),
         statusCode: 600,
         headers: ["Content-Type": "application/json; charset=utf8"],
         body: TestObject.some.toJSONData()
      )

      let response = try await makeChallengeAndRun { c in
         Task {
            do {
               try await c.refresh()
               await c.complete()
            } catch {
               await c.complete(with: error)
            }
         }
      }

      #expect(response == expectedResponse)
   }
}

// MARK: -

@discardableResult
private func makeChallengeAndRun(
   statusCode: Int = 600,
   handle: @escaping (TwoFactorAuthenticationChallenge) async -> Void
) async throws -> Response {
   let url = try #require(URL(string: "https://service.com"))
   let request = URLRequest(url: url)
   let response = Response(
      request: request,
      statusCode: statusCode,
      headers: ["Content-Type": "application/json; charset=utf8"],
      body: TestObject.some.toJSONData()
   )

   let handler = WebTests2FAChallengeHandler()

   let configuration: URLSessionConfiguration = .default
   configuration.protocolClasses = [TwoFactorAuthenticationWebTestsURLProtocol.self]
   let session = URLSession(configuration: configuration)

   let challenge = TwoFactorAuthenticationChallenge(
      response: response,
      handler: handler,
      session: session
   )

   handler.handleStub = handle

   return try await challenge.handleIfNeeded()
}
