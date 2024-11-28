//
//  StubbedWebClient.swift
//
//  Copyright © 2023 Aleksei Zaikin.
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

import Web

/// An implementation of `WebClient` that returns stubbed responses or falls requests back to other
/// given web client.
public actor StubbedWebClient: WebClient {
   private var stubChainRegistry: [String: StubChain] = [:]

   private let configuration: StubbedWebClientConfiguration

   // MARK: - Init
   
   /// Returns a newly created instance of `StubbedWebClient` with given configuration.
   ///
   /// - Parameters:
   ///   - configuration: Configuration that will be used to create web client. Configuration with
   ///                    default values by default.
   public init(configuration: StubbedWebClientConfiguration = StubbedWebClientConfiguration()) {
      self.configuration = configuration
   }

   // MARK: - Registry
   
   /// Creates and returns a chain for a given request type to be used to record responses for
   /// requests of this type. It creates a new chain at first call and then returns it every time
   /// this method called.
   ///
   /// - Parameters:
   ///   - request: A request type for which chain should be created.
   /// - Returns: A newly created or existing chain for a given request type.
   public func stubChain(for request: (some Request).Type) -> StubChain {
      let key = key(for: request)
      if let chain = stubChainRegistry[key] {
         return chain
      }

      let chain = StubChain(configuration: configuration)
      stubChainRegistry[key] = chain
      return chain
   }

   private func key(for request: (some Request).Type) -> String {
      return String(reflecting: request)
   }

   // MARK: - WebClient

   public func execute<SuccessObject: Sendable>(
      _ request: some Request<SuccessObject>
   ) async throws -> SuccessObject {
      let requestType = type(of: request)
      let key = key(for: requestType)
      guard let chain = stubChainRegistry[key] else {
         return try await fallbackRequestOrThrowError(
            request,
            possibleError: StubbedWebClientError.cannotFindResponseChain("\(requestType)")
         )
      }

      guard let execution = await chain.dequeueNextExecution() else {
         return try await fallbackRequestOrThrowError(
            request,
            possibleError: StubbedWebClientError.cannotFindRequestExecution("\(requestType)")
         )
      }

      return try await execution.execute(request)
   }

   private func fallbackRequestOrThrowError<SuccessObject: Sendable>(
      _ request: some Request<SuccessObject>,
      possibleError: Error
   ) async throws -> SuccessObject {
      if configuration.fallbackRequestsIfNoResponsesRegistered, let client = configuration.fallbackWebClient {
         return try await client.execute(request)
      } else {
         throw possibleError
      }
   }
}
