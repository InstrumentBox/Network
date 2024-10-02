//
//  StubChain.RecordTests.swift
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

@testable
import WebStub

import NetworkTestUtils
import Testing

@Suite("Stub chain")
struct StubChainRecordTests {
   @Test("Exhausted if current usage count greater than or equals to usage count", arguments: [1, 2])
   func exhausted(currentUsageCount: Int) async throws {
      let execution = try FilenameRequestExecution(responseURL: #require(Responses.testObject), latency: nil)
      let record = StubChain.Record(execution: execution, usageCount: 1)
      record.currentUsageCount = currentUsageCount
      #expect(record.isExhausted)
   }

   @Test("Not exhausted if current usage count less than usage count")
   func notExhausted() async throws {
      let execution = try FilenameRequestExecution(responseURL: #require(Responses.testObject), latency: nil)
      let record = StubChain.Record(execution: execution, usageCount: 1)
      #expect(!record.isExhausted)
   }
}