//
//  BodyMacroTestCase.swift
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
import WebMacros
import XCTest

private let testMacros: [String: Macro.Type] = [
   "Body": BodyMacro.self
]

class BodyMacroTestCase: XCTestCase {
   func test_bodyMacro_isExpanded_ifAttachedToVariable() {
      let declarations = [
         """
         var body: TestObject
         """,
         """
         let body: TestObject
         """
      ]

      for declaration in declarations {
         assertMacroExpansion(
            """
            @Body
            \(declaration)
            """,
            expandedSource: declaration,
            macros: testMacros)
      }
   }

   func test_bodyMacro_isExpanded_ifHasOneGenericArgument() {
      assertMacroExpansion(
         """
         @Body<Converter>
         let body: TestObject
         """,
         expandedSource:
         """
         let body: TestObject
         """,
         macros: testMacros
      )
   }

   func test_bodyMacro_showsError_ifAttachedToNotVariable() {
      let declarations = [
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
      ]

      for declaration in declarations {
         assertMacroExpansion(
            """
            @Body
            \(declaration)
            """,
            expandedSource: declaration,
            diagnostics: [
               DiagnosticSpec(message: "@Body is only applicable to property", line: 1, column: 1)
            ],
            macros: testMacros
         )
      }
   }

   func test_bodyMacro_showsError_ifAttachedToStaticProperty() {
      let declarations = [
         """
         static var body: TestObject
         """,
         """
         class var body: TestObject
         """,
         """
         static let body: TestObject
         """
      ]

      for declaration in declarations {
         assertMacroExpansion(
            """
            @Body
            \(declaration)
            """,
            expandedSource: declaration,
            diagnostics: [
               DiagnosticSpec(message: "@Body is only applicable to instance property", line: 1, column: 1)
            ],
            macros: testMacros
         )
      }
   }

   func test_bodyMacro_showsError_ifAttachedToOptionalProperty() {
      let declarations = [
         """
         var body: TestObject?
         """,
         """
         let body: TestObject?
         """
      ]

      for declaration in declarations {
         assertMacroExpansion(
            """
            @Body
            \(declaration)
            """,
            expandedSource: declaration,
            diagnostics: [
               DiagnosticSpec(message: "@Body parameter should not be optional", line: 1, column: 1)
            ],
            macros: testMacros
         )
      }
   }
}

#endif
