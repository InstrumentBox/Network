//
//  URLSessionWebClientTestCase.swift
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

@testable
import NetworkTestUtils

import Web
import XCTest

class URLSessionWebClientTestCase: XCTestCase {
   // MARK: - Test Cases

   func test_webClient_returnsObject() async throws {
      let webClient = makeWebClient(protocolClass: TestObjectWebTestsURLProtocol.self)
      let object = try await webClient.execute(TestObjectRequest())
      XCTAssertEqual(object, .some)
   }

   func test_webClient_returnsObject_ifRequestAuthorized() async throws {
      let webClient = makeWebClient(
         protocolClass: AuthorizedWebTestsURLProtocol.self,
         requestAuthorizer: WebTestsRequestAuthorizer()
      )
      let object = try await webClient.execute(TestObjectRequest())
      XCTAssertEqual(object, .some)
   }

   func test_webClient_skipsAuthorization_ifRequestMarkedToNotToBeAuthorized() async throws {
      class NotAuthorizedTestObjectRequest: TestObjectRequest, WithoutAuthorizationRequest { }
      let webClient = makeWebClient(
         protocolClass: AuthorizedWebTestsURLProtocol.self,
         requestAuthorizer: WebTestsRequestAuthorizer()
      )

      do {
         _ = try await webClient.execute(NotAuthorizedTestObjectRequest())
         XCTFail("Unexpected successful result")
      } catch let error as APIError {
         XCTAssertEqual(error, .notAuthorized)
      } catch {
         XCTFail("Unexpected error thrown: \(error)")
      }
   }

   func test_webClient_throwsAPIError_ifRequestNotAuthorized() async throws {
      let webClient = makeWebClient(protocolClass: AuthorizedWebTestsURLProtocol.self)
      do {
         _ = try await webClient.execute(TestObjectRequest())
         XCTFail("Unexpected successful result")
      } catch let error as APIError {
         XCTAssertEqual(error, .notAuthorized)
      } catch {
         XCTFail("Unexpected error thrown: \(error)")
      }
   }

   func test_webClient_throwsAPIError() async throws {
      let webClient = makeWebClient(protocolClass: APIErrorWebTestsURLProtocol.self)
      do {
         _ = try await webClient.execute(TestObjectRequest())
         XCTFail("Unexpected successful result")
      } catch let error as APIError {
         XCTAssertEqual(error, .testObjectNotFound)
      } catch {
         XCTFail("Unexpected error thrown: \(error)")
      }
   }

   func test_webClient_throwsResponseValidatorError_ifResponseNotValid() async throws {
      let webClient = makeWebClient(protocolClass: WebTestsURLProtocol.self)
      do {
         _ = try await webClient.execute(TestObjectRequest())
         XCTFail("Unexpected successful result")
      } catch let StatusCodeContentTypeResponseValidatorError.unacceptableContentType(
         expected,
         received
      ) {
         XCTAssertEqual(expected, "application/json")
         XCTAssertEqual(received, "application/octet-stream")
      } catch {
         XCTFail("Unexpected error thrown: \(error)")
      }
   }

   func test_webClient_returnsObject_if2FA() async throws {
      let webClient = makeWebClient(
         protocolClass: TwoFactorAuthenticationWebTestsURLProtocol.self
      ) { c in
         Task {
            do {
               try await c.authenticate(headerName: "X-2FA", headerValue: "1234")
               c.complete()
            } catch {
               c.complete(with: error)
            }
         }
      }

      let object = try await webClient.execute(TestObjectRequest())
      XCTAssertEqual(object, .some)
   }

   func test_webClient_returns2FACancelledError_if2FACancelled() async throws {
      let webClient = makeWebClient(
         protocolClass: TwoFactorAuthenticationWebTestsURLProtocol.self
      ) { c in
         Task {
            c.cancel()
         }
      }

      do {
         _ = try await webClient.execute(TestObjectRequest())
         XCTFail("Unexpected successful result")
      } catch let error as TwoFactorAuthenticationChallengeError {
         XCTAssertEqual(error, .cancelled)
      } catch {
         XCTFail("Unexpected error thrown: \(error)")
      }
   }

   func test_webClient_returnsError_if2FACompletedWithError() async throws {
      let webClient = makeWebClient(
         protocolClass: TwoFactorAuthenticationWebTestsURLProtocol.self
      ) { c in
         Task {
            c.complete(with: APIError.twoFactorAuthChallengeFailed)
         }
      }

      do {
         _ = try await webClient.execute(TestObjectRequest())
         XCTFail("Unexpected successful result")
      } catch let error as APIError {
         XCTAssertEqual(error, .twoFactorAuthChallengeFailed)
      } catch {
         XCTFail("Unexpected error thrown: \(error)")
      }
   }

   // MARK: - Factory

   private func makeWebClient(
      protocolClass: URLProtocol.Type,
      requestAuthorizer: RequestAuthorizer? = nil,
      request: TestObjectRequest? = nil,
      handle2FA: ((TwoFactorAuthenticationChallenge) -> Void)? = nil
   ) -> URLSessionWebClient {
      let configuration: URLSessionWebClientConfiguration = .ephemeral
      configuration.sessionConfiguration.protocolClasses = [protocolClass]
      configuration.requestAuthorizer = requestAuthorizer
      configuration.twoFactorAuthenticationHandler = handle2FA.map { handle in
         let handler = WebTests2FAChallengeHandler()
         handler.handleStub = handle
         return handler
      }
      return URLSessionWebClient(configuration: configuration)
   }
}
