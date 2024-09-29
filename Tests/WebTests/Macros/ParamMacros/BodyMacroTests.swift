//
//  BodyMacroTests.swift
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

#if canImport(WebMacros)

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing
import WebMacros

private let testMacros: [String: Macro.Type] = [
   "Body": BodyMacro.self
]

@Suite("@Body")
struct BodyMacroTests {
   @Test("Expanded if attached to variable", arguments: [
      """
      var body: TestObject
      """,
      """
      let body: TestObject
      """
   ], ["", "<Converter>"])
   func expandByAttachingToVariable(code: String, genericArg: String) {
      assertMacroExpansion(
         """
         @Body\(genericArg)
         \(code)
         """,
         expandedSource: code,
         macros: testMacros
      )
   }

   @Test("Shows error if attached to any other than variable", arguments: [
      """
      actor TestObjectRequest {
      }
      """,
      """
      class TestObjectRequest {
      }
      """,
      """
      struct TestObjectRequest {
      }
      """,
      """
      enum TestObjectRequest {
      }
      """,
      """
      protocol TestObjectRequest {
      }
      """,
      """
      typealias MyRequest = TestObjectRequest
      """,
      """
      func someFunc() {
      }
      """,
      """
      init() {
      }
      """,
      """
      deinit {
      }
      """
   ])
   func expandByAttachingToNotVariable(code: String) {
      assertMacroExpansion(
         """
         @Body
         \(code)
         """,
         expandedSource: code,
         diagnostics: [
            DiagnosticSpec(message: "@Body is only applicable to property", line: 1, column: 1)
         ],
         macros: testMacros
      )
   }

   @Test("Shows error if attached to static property", arguments: [
      """
      static var body: TestObject
      """,
      """
      class var body: TestObject
      """,
      """
      static let body: TestObject
      """
   ])
   func expandByAttachingToStaticProperty(code: String) {
      assertMacroExpansion(
         """
         @Body
         \(code)
         """,
         expandedSource: code,
         diagnostics: [
            DiagnosticSpec(message: "@Body is only applicable to instance property", line: 1, column: 1)
         ],
         macros: testMacros
      )
   }

   @Test("Shows error if attached to optional property", arguments: [
      """
      var body: TestObject?
      """,
      """
      let body: TestObject?
      """
   ])
   func expandByAttachingToOptionalVariable(code: String) {
      assertMacroExpansion(
         """
         @Body
         \(code)
         """,
         expandedSource: code,
         diagnostics: [
            DiagnosticSpec(message: "@Body parameter should not be optional", line: 1, column: 1)
         ],
         macros: testMacros
      )
   }
}

#endif
