//
//  BodyMacro.swift
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

import SwiftSyntax
import SwiftSyntaxMacros

public struct BodyMacro: PeerMacro {
   public static func expansion(
      of node: AttributeSyntax,
      providingPeersOf declaration: some DeclSyntaxProtocol,
      in context: some MacroExpansionContext
   ) throws -> [DeclSyntax] {
      guard let attributeName = node.attributeName.as(IdentifierTypeSyntax.self) else {
         context.diagnose(.unexpectedError(for: node))
         return []
      }

      let macroName = "\(attributeName.name)"
      let diagnostics = Diagnostics(macroName: macroName)
      
      guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
         context.diagnose(diagnostics.propertyOnly(for: declaration))
         return []
      }

      if variableDecl.modifiers.contains(where: { modifier in
         modifier.name.text == "static" || modifier.name.text == "class"
      }) {
         context.diagnose(diagnostics.nonStaticOnly(for: declaration))
         return []
      }

      if let type = variableDecl.bindings.first?.typeAnnotation?.type, type.is(OptionalTypeSyntax.self) {
         context.diagnose(diagnostics.nonOptionalOnly(for: declaration))
         return []
      }

      return []
   }
}
