//
//  Diagnostics.swift
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

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

struct Diagnostics {
   private let macroName: String
   private let domain: String

   // MARK: - Init

   init(macroName: String, domain: String = #file) {
      self.macroName = macroName
      self.domain = domain.components(separatedBy: ".")[0]
   }

   // MARK: -

   private func diagnostic(
      for node: SyntaxProtocol,
      id: String = #function,
      message: String,
      severity: DiagnosticSeverity = .error,
      fixIts: [FixIt] = []
   ) -> Diagnostic {
      let id = id.components(separatedBy: "(")[0]
      let diagnosticID = MessageID(domain: domain, id: id)
      let message = DiagnosticMessage(
         diagnosticID: diagnosticID,
         message: message,
         severity: severity
      )
      return Diagnostic(node: node, message: message, fixIts: fixIts)
   }

   // MARK: -

   func classOrStructOnly(for node: SyntaxProtocol) -> Diagnostic {
      diagnostic(for: node, message: "@\(macroName) is only applicable to class or struct")
   }

   func propertyOnly(for node: SyntaxProtocol) -> Diagnostic {
      diagnostic(for: node, message: "@\(macroName) is only applicable to property")
   }

   func nonStaticOnly(for node: SyntaxProtocol) -> Diagnostic {
      diagnostic(for: node, message: "@\(macroName) is only applicable to instance property")
   }

   func nonOptionalOnly(for node: SyntaxProtocol) -> Diagnostic {
      diagnostic(for: node, message: "@\(macroName) parameter should not be optional")
   }

   func pathSegmentDuplication(for node: SyntaxProtocol, segmentName: String) -> Diagnostic {
      diagnostic(for: node, message: "Duplication of substitutable path segment name '\(segmentName)'")
   }

   func onePathParameterOnly(for node: SyntaxProtocol, pathParameter: String) -> Diagnostic {
      diagnostic(for: node, message: "Invalid redeclaration of path parameter with name '\(pathParameter)'")
   }

   func noPathParameter(for node: SyntaxProtocol, for pathSegment: String) -> Diagnostic {
      diagnostic(for: node, message: "Couldn't find substitution parameter for path segment :\(pathSegment)")
   }

   func moveQueryToPathString(for node: SyntaxProtocol) -> Diagnostic {
      diagnostic(
         for: node,
         message: #"Consider moving query item to path, e.g. @GET("path/to/resource?query=item")"#,
         severity: .remark
      )
   }

   func oneQueryItemOnly(for node: SyntaxProtocol, queryItemName: String) -> Diagnostic {
      diagnostic(for: node, message: "Invalid redeclaration of query item with name '\(queryItemName)'")
   }

   func moveHeaderToHeadersAttribute(for node: SyntaxProtocol) -> Diagnostic {
      diagnostic(
         for: node,
         message: #"Move header to request type declaration using @Headers attribute"#
      )
   }

   func nonStringHeader(for node: SyntaxProtocol) -> Diagnostic {
      diagnostic(for: node, message: "@\(macroName) should have 'String' type")
   }

   func oneHeaderOnly(for node: SyntaxProtocol, headerName: String) -> Diagnostic {
      diagnostic(for: node, message: "Invalid redeclaration of header with name '\(headerName)'")
   }

   func tooManyBodyParameters(for node: SyntaxProtocol) -> Diagnostic {
      diagnostic(for: node, message: "Request should have at most one @Body parameter")
   }

   func bodyTypeNotInferred(for node: SyntaxProtocol) -> Diagnostic {
      diagnostic(for: node, message: "Couldn't infer converter type for body. Please specify converter type, e.g. @Body(MyOwnBodyConverter())")
   }
}
