//
//  StubChain.swift
//
//  Copyright © 2024 Aleksei Zaikin.
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

/// An error that is thrown when ``StubChain`` fails.
public enum StubChainError: Error, Equatable {
   /// Thrown when trying to register fallback response when fallback web client is not provided
   /// in ``StubbedWebClientConfiguration``.
   case cannotRegisterFallbackExecution
}

/// A chain response records that will be used in a response to a concrete request. It uses
/// responses in FIFO order and then continuously uses last record in the chain.
public actor StubChain {
   private var records: [StubChain.Record] = []

   private let configuration: StubbedWebClientConfiguration

   // MARK: - Init

   init(configuration: StubbedWebClientConfiguration) {
      self.configuration = configuration
   }

   // MARK: - Registrations
   
   /// Adds a response record that returns object or throws error from `.response` file at given URL.
   ///
   /// - Parameters:
   ///   - responseURL: URL of file with a response.
   ///   - usageCount: Number of consecutive usages of the same record before going to next one.
   ///                 Defaults to 1.
   public func registerResponse(at responseURL: URL, usageCount: Int = 1) {
      let execution = FilenameRequestExecution(responseURL: responseURL, latency: configuration.latency)
      let record = StubChain.Record(execution: execution, usageCount: usageCount)
      records.append(record)
   }
   
   /// Add a response record that uses fallback web client provided by
   /// ``StubbedWebClientConfiguration``. If fallback web client is not provided, error will be
   /// thrown.
   ///
   /// - Parameters:
   ///   - usageCount: Number of consecutive usages of the same record before going to next one.
   ///                 Defaults to 1.
   /// - Throws: A ``StubChainError`` if fallback web client is not provided.
   public func registerFallbackResponse(usageCount: Int = 1) throws {
      guard let fallbackWebClient = configuration.fallbackWebClient else {
         throw StubChainError.cannotRegisterFallbackExecution
      }

      let execution = FallbackRequestExecution(webClient: fallbackWebClient)
      let record = StubChain.Record(execution: execution, usageCount: usageCount)
      records.append(record)
   }
   
   /// Clears chain of response records.
   public func reset() {
      records = []
   }

   // MARK: - Access

   func dequeueNextExecution() async -> (any RequestExecution)? {
      var record = records.first
      if await record?.isExhausted ?? false {
         if records.count > 1 {
            records = Array(records.dropFirst())
            record = records.first
         }
      }

      await record?.increaseUsageCount()
      return record?.execution
   }
}
