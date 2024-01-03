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

public enum StubChainError: Error, Equatable {
   case cannotRegisterFallbackExecution
}

public class StubChain {
   private var records: [StubChain.Record] = []

   private let configuration: StubbedWebClientConfiguration

   // MARK: - Init

   init(configuration: StubbedWebClientConfiguration) {
      self.configuration = configuration
   }

   // MARK: - Registrations

   public func registerResponse(at responseURL: URL, usageCount: Int = 1) {
      let execution = FilenameRequestExecution(responseURL: responseURL, latency: configuration.latency)
      let record = StubChain.Record(execution: execution, usageCount: usageCount)
      records.append(record)
   }

   public func registerFallbackResponse(usageCount: Int = 1) throws {
      guard let fallbackWebClient = configuration.fallbackWebClient else {
         throw StubChainError.cannotRegisterFallbackExecution
      }

      let execution = FallbackRequestExecution(webClient: fallbackWebClient)
      let record = StubChain.Record(execution: execution, usageCount: usageCount)
      records.append(record)
   }

   public func reset() {
      records = []
   }

   // MARK: - Access

   func dequeueNextExecution() -> (any RequestExecution)? {
      var record = records.first
      if record?.isExhausted ?? false {
         if records.count > 1 {
            records = Array(records.dropFirst())
            record = records.first
         }
      }

      record?.currentUsageCount += 1
      return record?.execution
   }
}
