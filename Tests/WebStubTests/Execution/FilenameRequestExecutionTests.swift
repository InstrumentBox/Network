//
//  FilenameRequestExecutionTests.swift
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

import Foundation
import NetworkTestUtils
import Testing
import Web

@Suite("Filename request execution")
struct FilenameRequestExecutionTests {
   @Test("Returns success object")
   func fetchSuccessObject() async throws {
      let execution = try FilenameRequestExecution(responseURL: #require(Responses.testObject), latency: nil)
      let object = try await execution.execute(TestObjectRequest())
      #expect(object == .some)
   }

   @Test("Throws API Error")
   func fetchAPIError() async throws {
      let execution = try FilenameRequestExecution(responseURL: #require(Responses.apiError), latency: nil)

      await #expect(throws: APIError.testObjectNotFound) {
         _ = try await execution.execute(TestObjectRequest())
      }
   }

   @Test("Throws response validation error")
   func responseValidation() async throws {
      let execution = try FilenameRequestExecution(responseURL: #require(Responses.xml), latency: nil)

      await #expect(throws: StatusCodeContentTypeResponseValidatorError.unacceptableContentType(
         expected: "application/json",
         received: "text/xml"
      )) {
         _ = try await execution.execute(TestObjectRequest())
      }
   }

   @Test("Returns object not earlier than latency")
   func fetchObjectWithLatency() async throws {
      let latencyValue: TimeInterval = 1.0
      let execution = try FilenameRequestExecution(
         responseURL: #require(Responses.testObject),
         latency: ExactLatency(value: latencyValue)
      )

      let start = CFAbsoluteTimeGetCurrent()
      _ = try await execution.execute(TestObjectRequest())
      let duration = CFAbsoluteTimeGetCurrent() - start

      #expect(
         duration >= latencyValue,
         "Total duration of request execution (\(duration) is less than latency \(latencyValue)"
      )
   }
}
