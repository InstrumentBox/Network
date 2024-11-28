//
//  URLSessionWebClientTests.swift
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

@Suite("Web client based on URL session")
struct URLSessionWebClientTests {
   @Test("Returns success object")
   func fetchSuccessObject() async throws {
      let webClient = makeWebClient(protocolClass: TestObjectWebTestsURLProtocol.self)
      let object = try await webClient.execute(TestObjectRequest())
      #expect(object == .some)
   }

   @Test("Returns success object if request authorized")
   func authorizeAndFetchSuccessObject() async throws {
      let webClient = makeWebClient(
         protocolClass: AuthorizedWebTestsURLProtocol.self,
         requestAuthorizer: WebTestsRequestAuthorizer(needsAuthorization: true)
      )
      let object = try await webClient.execute(TestObjectRequest())
      #expect(object == .some)
   }

   @Test("Skips authorization if request should not be authorized")
   func executeAndNotAuthorizeRequest() async throws {
      let webClient = makeWebClient(
         protocolClass: AuthorizedWebTestsURLProtocol.self,
         requestAuthorizer: WebTestsRequestAuthorizer(needsAuthorization: false)
      )

      await #expect(throws: APIError.notAuthorized) {
         _ = try await webClient.execute(TestObjectRequest())
      }
   }

   @Test("Throws APIError if request not authorized")
   func executeNonAuthorizedRequest() async throws {
      let webClient = makeWebClient(protocolClass: AuthorizedWebTestsURLProtocol.self)

      await #expect(throws: APIError.notAuthorized) {
         _ = try await webClient.execute(TestObjectRequest())
      }
   }

   @Test("Throws APIError")
   func receiveAPIError() async throws {
      let webClient = makeWebClient(protocolClass: APIErrorWebTestsURLProtocol.self)
      await #expect(throws: APIError.testObjectNotFound) {
         _ = try await webClient.execute(TestObjectRequest())
      }
   }

   @Test("Throws validator error if response not valid")
   func validationFailed() async throws {
      let webClient = makeWebClient(protocolClass: WebTestsURLProtocol.self)
      await #expect(throws: StatusCodeContentTypeResponseValidatorError.unacceptableContentType(
         expected: "application/json",
         received: "application/octet-stream"
      )) {
         _ = try await webClient.execute(TestObjectRequest())
      }
   }

   @Test("Returns object after 2FA")
   func fetchObjectAfter2FA() async throws {
      let webClient = makeWebClient(
         protocolClass: TwoFactorAuthenticationWebTestsURLProtocol.self
      ) { c in
         Task {
            do {
               try await c.authenticate(headerName: "X-2FA", headerValue: "1234")
               await c.complete()
            } catch {
               await c.complete(with: error)
            }
         }
      }

      let object = try await webClient.execute(TestObjectRequest())
      #expect(object == .some)
   }

   @Test("Throws 2FA cancelled error")
   func cancel2FA() async throws {
      let webClient = makeWebClient(
         protocolClass: TwoFactorAuthenticationWebTestsURLProtocol.self
      ) { c in
         Task {
            await c.cancel()
         }
      }

      await #expect(throws: TwoFactorAuthenticationChallengeError.cancelled) {
         _ = try await webClient.execute(TestObjectRequest())
      }
   }

   @Test("Throws 2FA completion error")
   func complete2FAWithError() async throws {
      let webClient = makeWebClient(
         protocolClass: TwoFactorAuthenticationWebTestsURLProtocol.self
      ) { c in
         Task {
            await c.complete(with: APIError.twoFactorAuthChallengeFailed)
         }
      }

      await #expect(throws: APIError.twoFactorAuthChallengeFailed) {
         _ = try await webClient.execute(TestObjectRequest())
      }
   }
}

// MARK: -

private func makeWebClient(
   protocolClass: URLProtocol.Type,
   requestAuthorizer: (any RequestAuthorizer)? = nil,
   request: TestObjectRequest? = nil,
   handle2FA: ((TwoFactorAuthenticationChallenge) -> Void)? = nil
) -> URLSessionWebClient {
   let configuration: URLSessionWebClient.Configuration = .ephemeral
   configuration.sessionConfiguration.protocolClasses = [protocolClass]
   configuration.requestAuthorizer = requestAuthorizer
   configuration.twoFactorAuthenticationHandler = handle2FA.map { handle in
      let handler = WebTests2FAChallengeHandler()
      handler.handleStub = handle
      return handler
   }
   return URLSessionWebClient(configuration: configuration)
}
