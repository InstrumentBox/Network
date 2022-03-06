//
//  TwoFactorAuthenticationChallengeTestCase.swift
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

final class TwoFactorAuthenticationChallengeTestCase: XCTestCase {
   // MARK: - Test Cases

   func test_challenge_doesNotDelegateWorkToHandler() async throws {
      var isHandled = false
      try await makeChallengeAndRun(statusCode: 200) { c in
         isHandled = true
         c.complete()
      }
      XCTAssertFalse(isHandled)
   }

   func test_challenge_delegatesWorkToHandler_ifNeeded() async throws {
      var isHandled = false
      try await makeChallengeAndRun { c in
         isHandled = true
         c.complete()
      }
      XCTAssertTrue(isHandled)
   }

   func test_challenge_returnsCorrectStatusCode() async throws {
      var statusCode: Int?
      try await makeChallengeAndRun { c in
         statusCode = c.responseStatusCode
         c.complete()
      }
      XCTAssertEqual(statusCode, 600)
   }

   func test_challenge_returnsConvertedObject() async throws {
      var object: User?
      try await makeChallengeAndRun { c in
         object = try? c.convertedResponse(using: JSONDecoderResponseConverter<User>())
         c.complete()
      }
      XCTAssertEqual(object, .johnAppleseed)
   }

   func test_challenge_throwsCancelledError_ifCancelled() async throws {
      do {
         try await makeChallengeAndRun { c in
            c.cancel()
         }
      } catch let error as TwoFactorAuthenticationChallengeError {
         XCTAssertEqual(error, .cancelled)
      } catch {
         XCTFail("Unexpected error thrown: \(error)")
      }
   }

   func test_challenge_throwsCompletionError_ifCompletedWithError() async throws {
      let expectedError = NSError(domain: "web.tests.domain", code: 600, userInfo: nil)
      do {
         try await makeChallengeAndRun { c in
            c.complete(with: expectedError)
         }
      } catch let error as NSError {
         XCTAssertTrue(error == expectedError)
      } catch {
         XCTFail("Unexpected error thrown: \(error)")
      }
   }

   func test_challenge_returnsActualResponse_ifAuthenticatedAndCompleted() async throws {
      var request = try URLRequest(url: XCTUnwrap(URL(string: "https://service.com")))
      request.addValue("1234", forHTTPHeaderField: "X-2FA")
      let expectedResponse = Response(
         request: request,
         statusCode: 200,
         headers: ["Content-Type": "application/json; charset=utf8"],
         body: User.johnAppleseed.toJSONData()
      )

      let response = try await makeChallengeAndRun { c in
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

      XCTAssertEqual(response, expectedResponse)
   }

   func test_challenge_returnsTheSameResponse_ifRefreshed() async throws {
      let expectedResponse = try Response(
         request: URLRequest(url: XCTUnwrap(URL(string: "https://service.com"))),
         statusCode: 600,
         headers: ["Content-Type": "application/json; charset=utf8"],
         body: User.johnAppleseed.toJSONData()
      )

      let response = try await makeChallengeAndRun { c in
         Task {
            do {
               try await c.refresh()
               c.complete()
            } catch {
               c.complete(with: error)
            }
         }
      }

      XCTAssertEqual(response, expectedResponse)
   }

   // MARK: - Factory

   @discardableResult
   private func makeChallengeAndRun(
      statusCode: Int = 600,
      handle: @escaping (TwoFactorAuthenticationChallenge) -> Void
   ) async throws -> Response {
      let url = try XCTUnwrap(URL(string: "https://service.com"))
      let request = URLRequest(url: url)
      let response = Response(
         request: request,
         statusCode: statusCode,
         headers: ["Content-Type": "application/json; charset=utf8"],
         body: User.johnAppleseed.toJSONData()
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
}
