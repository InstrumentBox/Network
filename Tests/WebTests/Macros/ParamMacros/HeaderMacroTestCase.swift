//
//  HeaderMacroTestCase.swift
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
   "Header": HeaderMacro.self
]

class HeaderMacroTestCase: XCTestCase {
   func test_headerMacro_isExpanded_ifAttachedToVariable() {
      let declarations = [
         """
         var header: String
         """,
         """
         let header: String
         """
      ]

      for declaration in declarations {
         assertMacroExpansion(
            """
            @Header
            \(declaration)
            """,
            expandedSource: declaration,
            macros: testMacros
         )
      }

      for declaration in declarations {
         assertMacroExpansion(
            """
            @Header("X-Header-Name")
            \(declaration)
            """,
            expandedSource: declaration,
            macros: testMacros
         )
      }
   }

   func test_headerMacro_showsError_ifAttachedToNotVariable() {
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
            @Header
            \(declaration)
            """,
            expandedSource: declaration,
            diagnostics: [
               DiagnosticSpec(message: "@Header is only applicable to property", line: 1, column: 1)
            ],
            macros: testMacros
         )
      }
   }

   func test_headerMacro_showsError_ifAttachedToStaticProperty() {
      let declarations = [
         """
         static var header: String
         """,
         """
         class var header: String
         """,
         """
         static let header: String
         """
      ]

      for declaration in declarations {
         assertMacroExpansion(
            """
            @Header
            \(declaration)
            """,
            expandedSource: declaration,
            diagnostics: [
               DiagnosticSpec(message: "@Header is only applicable to instance property", line: 1, column: 1)
            ],
            macros: testMacros
         )
      }
   }

   func test_headerMacro_showsError_ifAttachedToComputedProperty() {
      let declaration =
         """
         var header: String {
            "value"
         }
         """
      assertMacroExpansion(
         """
         @Header
         \(declaration)
         """,
         expandedSource: declaration,
         diagnostics: [
            DiagnosticSpec(message: "Move header to request type declaration using @Headers attribute", line: 1, column: 1)
         ],
         macros: testMacros
      )
   }

   func test_headerMacro_showsError_ifAttachedToInitializedProperty() {
      let declaration = #"let header = "value""#
      assertMacroExpansion(
         """
         @Header
         \(declaration)
         """,
         expandedSource: declaration,
         diagnostics: [
            DiagnosticSpec(message: "Move header to request type declaration using @Headers attribute", line: 1, column: 1)
         ],
         macros: testMacros
      )
   }

   func test_headerMacro_showsError_ifAttachedToNotStringProperty() {
      let declaration = "let header: Int"
      assertMacroExpansion(
         """
         @Header
         \(declaration)
         """,
         expandedSource: declaration,
         diagnostics: [
            DiagnosticSpec(message: "@Header should have 'String' type", line: 1, column: 1)
         ],
         macros: testMacros
      )
   }
}

#endif
