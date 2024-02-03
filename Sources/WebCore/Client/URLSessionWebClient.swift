//
//  URLSessionWebClient.swift
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
import Web

/// An implementation of a `WebClient` based on `URLSession`.
///
/// ``URLSessionWebClient`` also provides `Request`s authorization, server trust evaluation, and
/// 2FA challenges handling.
public class URLSessionWebClient: WebClient {
   private let configuration: URLSessionWebClientConfiguration
   private let session: URLSession

   // MARK: - Init

   /// Creates and returns an instance of `URLSessionWebClient` with a given configuration.
   ///
   /// - Parameters:
   ///   - configuration: Configuration that will be used to create a web client.
   public init(configuration: URLSessionWebClientConfiguration) {
      self.configuration = configuration
      let delegate = WebURLSessionDelegate(configuration: configuration)
      session = URLSession(
         configuration: configuration.sessionConfiguration,
         delegate: delegate,
         delegateQueue: nil
      )
   }

   deinit {
      session.invalidateAndCancel()
   }

   // MARK: - WebClient

   @URLSessionWebClientActor
   public func execute<SuccessObject>(
      _ request: some Request<SuccessObject>
   ) async throws -> SuccessObject {
      let task = Task {
         let urlRequest = try await makeURLRequest(request: request)
         var response = try await session.data(for: urlRequest)
         response = try await handleTwoFactorAuthenticationChallengeIfNeeded(response)
         let object = try processResponse(response, for: request)
         return object
      }
      return try await task.value
   }

   private func makeURLRequest(request: some Request) async throws -> URLRequest {
      var urlRequest = try request.toURLRequest(with: configuration.baseURL)
      if request is NonAuthorizableRequest {
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

   private func processResponse<SuccessObject>(
      _ response: Response,
      for request: some Request<SuccessObject>
   ) throws -> SuccessObject {
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
