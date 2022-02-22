//
//  TwoFactorAuthenticationChallenge.swift
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

public enum TwoFactorAuthenticationChallengeError: Error {
   case cancelled
}

public final class TwoFactorAuthenticationChallenge {
   private var continuation: UnsafeContinuation<Response, Error>?

   private var response: Response
   private let handler: TwoFactorAuthenticationChallengeHandler
   private let session: URLSession

   // MARK: - Init

   init(response: Response, handler: TwoFactorAuthenticationChallengeHandler, session: URLSession) {
      self.response = response
      self.handler = handler
      self.session = session
   }

   // MARK: - Response Interaction

   public var responseStatusCode: Int {
      response.statusCode
   }

   public func convertedResponse<ResponseConverter: Web.ResponseConverter>(
      using converter: ResponseConverter
   ) throws -> ResponseConverter.ConvertedResponse {
      try converter.convert(response)
   }

   // MARK: - Challenge Disposition

   public func cancel() {
      let error: TwoFactorAuthenticationChallengeError = .cancelled
      continuation?.resume(throwing: error)
      continuation = nil
   }

   @WebClientActor
   public func refresh() async throws {
      response = try await session.data(for: response.request)
   }

   @WebClientActor
   public func authenticate(with header: TwoFactorAuthenticationHeader) async throws {
      var request = response.request
      request.addValue(header.value, forHTTPHeaderField: header.name)
      response = try await session.data(for: request)
   }

   public func complete(with error: Error? = nil) {
      if let error = error {
         continuation?.resume(throwing: error)
      } else {
         continuation?.resume(returning: response)
      }
      continuation = nil
   }

   // MARK: - Handling

   func handleIfNeeded() async throws -> Response {
      guard handler.responseRequiresTwoFactorAuthentication(response) else {
         return response
      }

      return try await withUnsafeThrowingContinuation { continuation in
         self.continuation = continuation
         handler.handle(self)
      }
   }
}
