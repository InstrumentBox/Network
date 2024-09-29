//
//  PathMacroTests.swift
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
   "Path": PathMacro.self
]

@Suite("@Path")
struct PathMacroTests {
   @Test("Expanded if attached to variable", arguments: [
      """
      var segmentValue: Int
      """,
      """
      let segmentValue: Int
      """
   ], ["", #"("segment_name")"#])
   func expandByAttachingToVariable(code: String, explicitName: String) {
      assertMacroExpansion(
         """
         @Path\(explicitName)
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
         @Path
         \(code)
         """,
         expandedSource: code,
         diagnostics: [
            DiagnosticSpec(message: "@Path is only applicable to property", line: 1, column: 1)
         ],
         macros: testMacros
      )
   }

   @Test("Shows error if attached to static property", arguments: [
      """
      static var segmentValue: Int
      """,
      """
      class var segmentValue: Int
      """,
      """
      static let segmentValue: Int
      """
   ])
   func expandByAttachingToStaticProperty(code: String) {
      assertMacroExpansion(
         """
         @Path
         \(code)
         """,
         expandedSource: code,
         diagnostics: [
            DiagnosticSpec(message: "@Path is only applicable to instance property", line: 1, column: 1)
         ],
         macros: testMacros
      )
   }

   @Test("Shows error if attached to optional property", arguments: [
      """
      var segmentValue: Int?
      """,
      """
      let segmentValue: Int?
      """
   ])
   func expandByAttachingToOptionalProperty(code: String) {
      assertMacroExpansion(
         """
         @Path
         \(code)
         """,
         expandedSource: code,
         diagnostics: [
            DiagnosticSpec(message: "@Path parameter should not be optional", line: 1, column: 1)
         ],
         macros: testMacros
      )
   }
}

#endif
