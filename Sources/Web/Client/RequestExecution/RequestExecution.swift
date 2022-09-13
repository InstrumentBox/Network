//
//  RequestExecution.swift
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

import Foundation

class RequestExecution<Request: Web.Request> {
   private let request: Request
   private let session: URLSession
   private let configuration: URLSessionWebClientConfiguration

   // MARK: - Init

   init(request: Request, session: URLSession, configuration: URLSessionWebClientConfiguration) {
      self.request = request
      self.session = session
      self.configuration = configuration
   }

   // MARK: - Execution

   @WebClientActor
   func execute() async throws -> Request.SuccessObject {
      let urlRequest = try await makeURLRequest(request: request)
      var response = try await session.data(for: urlRequest)
      response = try await handleTwoFactorAuthenticationChallengeIfNeeded(response)
      let object = try processResponse(response)
      return object
   }

   private func makeURLRequest(request: Request) async throws -> URLRequest {
      var urlRequest = try request.toURLRequest(with: configuration.baseURL)
      if request is WithoutAuthorizationRequest {
         return urlRequest
      }

      if let authorizer = configuration.requestAuthorizer {
         let header = try await authorizer.authorizationHeader(for: request)
         urlRequest.addValue(header.value, forHTTPHeaderField: header.name)
      }

      return urlRequest
   }

   private func handleTwoFactorAuthenticationChallengeIfNeeded(
      _ response: Response
   ) async throws -> Response {
      guard let handler = configuration.twoFactorAuthenticationHandler else {
         return response
      }

      let challenge = TwoFactorAuthenticationChallenge(
         response: response,
         handler: handler,
         session: session
      )
      return try await challenge.handleIfNeeded()
   }

   private func processResponse(
      _ response: Response
   ) throws -> Request.SuccessObject {
      let disposition = request.responseValidator.validate(response)
      switch disposition {
         case .useSuccessObjectResponseConverter:
            let object = try request.successObjectResponseConverter.convert(response)
            return object
         case .useErrorObjectResponseConverter:
            let error = try request.errorObjectResponseConverter.convert(response)
            throw error
         case let .completeWithError(error):
            throw error
      }
   }
}
