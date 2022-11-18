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
import Web

/// An error that is thrown when challenge authentication is failed.
public enum TwoFactorAuthenticationChallengeError: Error {
   /// Thrown when challenge is cancelled.
   case cancelled
}

/// An object that is used to manage 2FA challenge.
///
/// It is intended to handle challenges when you need to send the same request to send a new
/// one-time code to a user and authenticate challenge by sending the same request with some HTTP
/// header.
public class TwoFactorAuthenticationChallenge {
   private var continuation: UnsafeContinuation<Response, Error>?

   private var response: Response
   private let handler: TwoFactorAuthenticationHandler
   private let session: URLSession

   // MARK: - Init

   init(response: Response, handler: TwoFactorAuthenticationHandler, session: URLSession) {
      self.response = response
      self.handler = handler
      self.session = session
   }

   // MARK: - Response Interaction

   /// Status code of current `Response` of authentication challenge.
   public var responseStatusCode: Int {
      response.statusCode
   }

   /// Returns converted current `Response` of authentication challenge. You are responsible to
   /// handle error if thrown.
   ///
   /// - Returns: Converter that will be used to convert response.
   /// - Throws: An underlying converter's error.
   public func convertedResponse<ResponseConverter: Web.ResponseConverter>(
      using converter: ResponseConverter
   ) throws -> ResponseConverter.ConvertedResponse {
      try converter.convert(response)
   }

   // MARK: - Challenge Disposition

   /// Cancels authentication challenge.
   /// `TwoFactorAuthenticationChallengeError.cancelled` error will be thrown by a web client.
   public func cancel() {
      let error: TwoFactorAuthenticationChallengeError = .cancelled
      continuation?.resume(throwing: error)
      continuation = nil
   }

   /// Refreshes authentication challenge and updates current `Response`. Authentication challenge
   /// uses original request, response to that caused this challenge. You are responsible to handle
   /// error if thrown.
   ///
   /// - Throws: An error that was occurred during refreshing challenge. Usually `URLError`.
   public func refresh() async throws {
      response = try await session.data(for: response.request)
   }

   /// Authenticates challenge with passed header name and value. Authentication challenge adds
   /// passed header to the original request response to that caused this challenge. You are
   /// responsible to handle error if thrown.
   ///
   /// - Parameters:
   ///   - headerName: A name of header that will be used to authenticate challenge.
   ///   - headerValue: A value of header that will be used to authenticate challenge.
   /// - Throws: An error that was occurred during authenticating challenge. Usually `URLError`.
   public func authenticate(headerName: String, headerValue: String) async throws {
      var request = response.request
      request.addValue(headerValue, forHTTPHeaderField: headerName)
      response = try await session.data(for: request)
   }

   /// Completes authentication challenge by either returning current `Response` or throwing
   /// passed error. You can complete challenge with error occurred when converting, refreshing,
   /// authenticating challenge, or any other error.
   ///
   /// - Parameters:
   ///   - error: An error that will be thrown by a web client.
   public func complete(with error: Error? = nil) {
      if let error {
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
