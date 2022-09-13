//
//  RequestExecutionTestCase.swift
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

class RequestExecutionTestCase: XCTestCase {
   // MARK: - Test Cases

   func test_requestExecution_returnsObject() async throws {
      let execution = makeExecution(protocolClass: UserWebTestsURLProtocol.self)
      let user = try await execution.execute()
      XCTAssertEqual(user, .johnAppleseed)
   }

   func test_requestExecution_returnsObject_ifRequestAuthorized() async throws {
      let execution = makeExecution(
         protocolClass: AuthorizedWebTestsURLProtocol.self,
         requestAuthorizer: WebTestsRequestAuthorizer()
      )
      let user = try await execution.execute()
      XCTAssertEqual(user, .johnAppleseed)
   }

   func test_requestExecution_skipsAuthorization_ifRequestMarkedToNotToBeAuthorized() async throws {
      class NotAuthorizedUserRequest: UserRequest, WithoutAuthorizationRequest { }
      let execution = makeExecution(
         protocolClass: AuthorizedWebTestsURLProtocol.self,
         requestAuthorizer: WebTestsRequestAuthorizer(),
         request: NotAuthorizedUserRequest()
      )

      do {
         _ = try await execution.execute()
         XCTFail("Unexpected successful result")
      } catch let error as APIError {
         XCTAssertEqual(error, .notAuthorized)
      } catch {
         XCTFail("Unexpected error thrown: \(error)")
      }
   }

   func test_requestExecution_throwsAPIError_ifRequestNotAuthorized() async throws {
      let execution = makeExecution(protocolClass: AuthorizedWebTestsURLProtocol.self)
      do {
         _ = try await execution.execute()
         XCTFail("Unexpected successful result")
      } catch let error as APIError {
         XCTAssertEqual(error, .notAuthorized)
      } catch {
         XCTFail("Unexpected error thrown: \(error)")
      }
   }

   func test_requestExecution_throwsAPIError() async throws {
      let execution = makeExecution(protocolClass: APIErrorWebTestsURLProtocol.self)
      do {
         _ = try await execution.execute()
         XCTFail("Unexpected successful result")
      } catch let error as APIError {
         XCTAssertEqual(error, .userNotFound)
      } catch {
         XCTFail("Unexpected error thrown: \(error)")
      }
   }

   func test_requestExecution_throwsResponseValidatorError_ifResponseNotValid() async throws {
      let execution = makeExecution(protocolClass: WebTestsURLProtocol.self)
      do {
         _ = try await execution.execute()
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

   func test_requestExecution_returnsObject_if2FA() async throws {
      let execution = makeExecution(
         protocolClass: TwoFactorAuthenticationWebTestsURLProtocol.self
      ) { c in
         Task {
            do {
               let header = Header(name: "X-2FA", value: "1234")
               try await c.authenticate(with: header)
               c.complete()
            } catch {
               c.complete(with: error)
            }
         }
      }

      let object = try await execution.execute()
      XCTAssertEqual(object, .johnAppleseed)
   }

   // MARK: - Factory

   private func makeExecution(
      protocolClass: URLProtocol.Type,
      requestAuthorizer: RequestAuthorizer? = nil,
      request: UserRequest? = nil,
      handle2FA: ((TwoFactorAuthenticationChallenge) -> Void)? = nil
   ) -> RequestExecution<UserRequest> {
      let configuration: URLSessionWebClientConfiguration = .ephemeral
      configuration.sessionConfiguration.protocolClasses = [protocolClass]
      configuration.requestAuthorizer = requestAuthorizer
      configuration.twoFactorAuthenticationHandler = handle2FA.map { handle in
         let handler = WebTests2FAChallengeHandler()
         handler.handleStub = handle
         return handler
      }
      let session = URLSession(configuration: configuration.sessionConfiguration)
      let request = request ?? UserRequest()
      return RequestExecution(request: request, session: session, configuration: configuration)
   }
}
