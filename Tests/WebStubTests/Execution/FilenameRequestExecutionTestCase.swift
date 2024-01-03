//
//  FilenameRequestExecutionTestCase.swift
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
import NetworkTestUtils

@testable
import WebStub

import Web
import XCTest

class FilenameRequestExecutionTestCase: XCTestCase {
   func test_filenameRequestExecution_returnsSuccessObject() async throws {
      let execution = try FilenameRequestExecution(responseURL: XCTUnwrap(Responses.testObject), latency: nil)
      let object = try await execution.execute(TestObjectRequest())
      XCTAssertEqual(object, .some)
   }

   func test_filenameRequestExecution_throwsAPIError() async throws {
      let execution = try FilenameRequestExecution(responseURL: XCTUnwrap(Responses.apiError), latency: nil)
      do {
         _ = try await execution.execute(TestObjectRequest())
         XCTFail("Unexpected success object returned")
      } catch let error as APIError {
         XCTAssertEqual(error, .testObjectNotFound)
      } catch {
         XCTFail("Unexpected error thrown \(error)")
      }
   }

   func test_filenameRequestExecution_throwsResponseValidationError() async throws {
      let execution = try FilenameRequestExecution(responseURL: XCTUnwrap(Responses.xml), latency: nil)
      do {
         _ = try await execution.execute(TestObjectRequest())
         XCTFail("Unexpected success object returned")
      } catch let error as StatusCodeContentTypeResponseValidatorError {
         XCTAssertEqual(error, .unacceptableContentType(expected: "application/json", received: "text/xml"))
      } catch {
         XCTFail("Unexpected error thrown \(error)")
      }
   }

   func test_filenameRequestExecution_returnsResponseNotEarlierThanLatency() async throws {
      let latencyValue: TimeInterval = 1.0
      let execution = try FilenameRequestExecution(
         responseURL: XCTUnwrap(Responses.testObject),
         latency: ExactLatency(value: latencyValue)
      )

      let start = CFAbsoluteTimeGetCurrent()
      _ = try await execution.execute(TestObjectRequest())
      let duration = CFAbsoluteTimeGetCurrent() - start

      XCTAssertTrue(
         duration >= latencyValue,
         "Total duration of request execution (\(duration) is less than latency \(latencyValue)"
      )
   }
}
