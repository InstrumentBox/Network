//
//  RequestMacro.swift
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
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct RequestMacro: ExtensionMacro {
   public static func expansion(
      of node: AttributeSyntax,
      attachedTo declaration: some DeclGroupSyntax,
      providingExtensionsOf type: some TypeSyntaxProtocol,
      conformingTo protocols: [TypeSyntax],
      in context: some MacroExpansionContext
   ) throws -> [ExtensionDeclSyntax] {
      guard let attributeName = node.attributeName.as(IdentifierTypeSyntax.self) else {
         context.diagnose(.unexpectedError(for: node))
         return []
      }

      let macroName = attributeName.name.text
      let diagnostics = Diagnostics(macroName: macroName)

      guard declaration.is(ClassDeclSyntax.self) || declaration.is(StructDeclSyntax.self) else {
         context.diagnose(diagnostics.classOrStructOnly(for: declaration))
         return []
      }

      guard let objectTypes = objectTypes(from: node) else {
         context.diagnose(.unexpectedError(for: declaration))
         return []
      }

      guard let path = path(from: node) else {
         context.diagnose(.unexpectedError(for: declaration))
         return []
      }

      guard let pathDecl = try pathDecl(
         byProcessing: declaration,
         path: path,
         in: context,
         diagnostics: diagnostics
      ) else {
         return []
      }

      guard let queryDecl = try queryDecl(
         byProcessing: declaration,
         in: context,
         diagnostics: diagnostics
      ) else {
         return []
      }

      guard let headersDecl = try headersDecl(
         byProcessing: declaration,
         in: context,
         diagnostics: diagnostics
      ) else {
         return []
      }

      guard let bodyDecl = try bodyDecl(
         byProcessing: declaration,
         in: context,
         diagnostics: diagnostics
      ) else {
         return []
      }

      let accessModifier = accessModifierKeyword(for: declaration)

      let extensionDecl = try ExtensionDeclSyntax("extension \(type): Request") {
         try TypeAliasDeclSyntax("\(raw: accessModifier)typealias SuccessObject = \(objectTypes.success)")
         try TypeAliasDeclSyntax("\(raw: accessModifier)typealias ErrorObject = \(objectTypes.error)")

         if let successObjectResponseConverterDecl = try responseConverterDecl(
            prefixedBy: "success",
            dependingOn: objectTypes.success,
            decl: declaration,
            accessModifier: accessModifier
         ) {
            successObjectResponseConverterDecl
         }

         if let errorObjectResponseConverterDecl = try responseConverterDecl(
            prefixedBy: "error",
            dependingOn: objectTypes.error,
            decl: declaration,
            accessModifier: accessModifier
         ) {
            errorObjectResponseConverterDecl
         }

         try FunctionDeclSyntax("\(raw: accessModifier)func toURLRequest(with baseURL: URL?) throws -> URLRequest") {
            try VariableDeclSyntax(#"let method = Method("\#(raw: macroName)")"#)
            pathDecl
            queryDecl
            try VariableDeclSyntax("let url = try URL(path: path, baseURL: baseURL, query: query)")
            headersDecl
            if bodyDecl.hasBody {
               bodyDecl.decl
               try VariableDeclSyntax("let request = try URLRequest(url: url, method: method, headers: headers, body: body, converter: bodyConverter)")
            } else {
               try VariableDeclSyntax("let request = URLRequest(url: url, method: method, headers: headers)")
            }
            StmtSyntax("return request")
         }
      }

      return [extensionDecl]
   }

   // MARK: -

   private static func accessModifierKeyword(for decl: some DeclGroupSyntax) -> String {
      let allowedModifiers: Set<String> = ["open", "public", "package"]
      var resultingModifier: String?
      for modifier in decl.modifiers {
         let modifierText = modifier.name.text
         if allowedModifiers.contains(modifierText) {
            resultingModifier = "\(modifierText) "
            break
         }
      }
      return resultingModifier ?? ""
   }

   private static func objectTypes(from attribute: AttributeSyntax) -> (success: TypeSyntax, error: TypeSyntax)? {
      guard
         let attributeName = attribute.attributeName.as(IdentifierTypeSyntax.self),
         let genericClause = attributeName.genericArgumentClause?.arguments,
         let successObjectType = genericClause.first?.argument,
         let errorObjectType = genericClause.last?.argument
      else {
         return nil
      }

      return (successObjectType, errorObjectType)
   }

   private static func hasVariableWithName(_ name: String, in decl: some DeclGroupSyntax) -> Bool {
      var has = false
      for member in decl.memberBlock.members {
         let variableName = member.decl.as(VariableDeclSyntax.self)?.bindings.first?.pattern
            .as(IdentifierPatternSyntax.self)?.identifier.text
         if variableName == name {
            has = true
            break
         }
      }
      return has
   }

   private static func responseConverterDecl(
      prefixedBy prefix: String,
      dependingOn type: TypeSyntax,
      decl: some DeclGroupSyntax,
      accessModifier: String
   ) throws -> VariableDeclSyntax? {
      let converterVariableName = "\(prefix)ObjectResponseConverter"
      if hasVariableWithName(converterVariableName, in: decl) {
         return nil
      }

      return try VariableDeclSyntax(
         "\(raw: accessModifier)var \(raw: converterVariableName): any ResponseConverter<\(type)>"
      ) {
         if type.is(ArrayTypeSyntax.self) {
            CodeBlockItemSyntax("JSONDecoderResponseConverter()")
         } else if let typeName = type.as(IdentifierTypeSyntax.self)?.name {
            if typeName.text == "Response" {
               CodeBlockItemSyntax("AsIsResponseConverter()")
            } else if typeName.text == "Data" {
               CodeBlockItemSyntax("DataResponseConverter()")
            } else if typeName.text == "Void" {
               CodeBlockItemSyntax("EmptyResponseConverter()")
            } else if typeName.text == "String" {
               CodeBlockItemSyntax("StringResponseConverter()")
            } else if typeName.text == "UIImage" {
               CodeBlockItemSyntax("ImageResponseConverter()")
            } else {
               CodeBlockItemSyntax("JSONDecoderResponseConverter()")
            }
         }
      }
   }

   private static func path(from node: AttributeSyntax) -> TokenSyntax? {
      guard
         let path = node.arguments?.as(LabeledExprListSyntax.self)?.first?
            .expression.as(StringLiteralExprSyntax.self)?
            .segments.first?.as(StringSegmentSyntax.self)?.content
      else {
         return nil
      }

      return path
   }

   private static func variableDecls(
      of declaration: some DeclGroupSyntax,
      attributedBy attributeName: String
   ) -> [VariableDeclSyntax] {
      var variables: [VariableDeclSyntax] = []
      for member in declaration.memberBlock.members {
         guard let variableDecl = member.decl.as(VariableDeclSyntax.self) else {
            continue
         }

         for attribute in variableDecl.attributes {
            guard attribute.as(AttributeSyntax.self)?
               .attributeName.as(IdentifierTypeSyntax.self)?
               .name.text == attributeName
            else {
               continue
            }

            variables.append(variableDecl)
         }
      }
      return variables
   }

   private static func substitution(
      from decl: VariableDeclSyntax,
      attributeName: String
   ) -> (substitutionName: String, variableName: TokenSyntax, isOptional: Bool)? {
      guard let index = decl.attributes.firstIndex(where: { attribute in
         attribute.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == attributeName
      }) else {
         return nil
      }

      guard let attribute = decl.attributes[index].as(AttributeSyntax.self) else {
         return nil
      }

      var substitutionName: String?
      if let segment = attribute
         .arguments?.as(LabeledExprListSyntax.self)?
         .first?.expression.as(StringLiteralExprSyntax.self)?.segments.first?.as(StringSegmentSyntax.self)
      {
         substitutionName = segment.content.text
      }

      guard let binding = decl.bindings.first else {
         return nil
      }

      guard let variableName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
         return nil
      }

      guard let typeAnnotation = binding.typeAnnotation else {
         return nil
      }

      return (substitutionName ?? variableName.text, variableName, typeAnnotation.type.is(OptionalTypeSyntax.self))
   }

   private static func pathDecl(
      byProcessing decl: some DeclGroupSyntax,
      path: TokenSyntax,
      in context: some MacroExpansionContext,
      diagnostics: Diagnostics
   ) throws -> VariableDeclSyntax? {
      let substitutionNames = path.text
         .components(separatedBy: CharacterSet(charactersIn: "/?#"))
         .filter { $0.hasPrefix(":") }
         .map { String($0[$0.index(after: $0.startIndex)...]) }

      var counts: Set<String> = []
      for substitutionName in substitutionNames {
         if counts.contains(substitutionName) {
            context.diagnose(diagnostics.pathSegmentDuplication(for: decl, segmentName: substitutionName))
            return nil
         }

         counts.insert(substitutionName)
      }

      let substitutions = variableDecls(of: decl, attributedBy: "Path").compactMap {
         substitution(from: $0, attributeName: "Path")
      }

      var path = path.text
      for substitutionName in substitutionNames {
         let count = substitutions.filter { $0.substitutionName == substitutionName }.count
         if count > 1 {
            context.diagnose(diagnostics.onePathParameterOnly(for: DeclSyntax(decl), pathParameter: substitutionName))
            return nil
         }

         guard let substitution = substitutions.first(where: { $0.substitutionName == substitutionName }) else {
            context.diagnose(diagnostics.noPathParameter(for: DeclSyntax(decl), for: substitutionName))
            return nil
         }

         path = path.replacingOccurrences(of: ":\(substitutionName)", with: #"\(\#(substitution.variableName))"#)
      }

      return try VariableDeclSyntax(#"let path = "\#(raw: path)""#)
   }

   private static func queryDecl(
      byProcessing decl: some DeclGroupSyntax,
      in context: some MacroExpansionContext,
      diagnostics: Diagnostics
   ) throws -> CodeBlockItemListSyntax? {
      let queryItems = variableDecls(of: decl, attributedBy: "Query").compactMap {
         substitution(from: $0, attributeName: "Query")
      }

      var counts: Set<String> = []
      for queryItem in queryItems {
         if counts.contains(queryItem.substitutionName) {
            context.diagnose(diagnostics.oneQueryItemOnly(for: decl, queryItemName: queryItem.substitutionName))
            return nil
         }

         counts.insert(queryItem.substitutionName)
      }

      return try CodeBlockItemListSyntax {

         if queryItems.isEmpty {
            try VariableDeclSyntax(#"let query: [String: any Sendable] = [:]"#)
         } else {
            try VariableDeclSyntax(#"var query: [String: any Sendable] = [:]"#)
         }
         for queryItem in queryItems {
            if queryItem.isOptional {
               try IfExprSyntax("if let \(queryItem.variableName)") {
                  CodeBlockItemSyntax(#"query["\#(raw: queryItem.substitutionName)"] = \#(queryItem.variableName)"#)
               }
            } else {
               CodeBlockItemSyntax(#"query["\#(raw: queryItem.substitutionName)"] = \#(queryItem.variableName)"#)
            }
         }
      }
   }

   private static func headersDecl(
      byProcessing decl: some DeclGroupSyntax,
      in context: some MacroExpansionContext,
      diagnostics: Diagnostics
   ) throws -> CodeBlockItemListSyntax? {
      let headers = variableDecls(of: decl, attributedBy: "Header").compactMap {
         substitution(from: $0, attributeName: "Header")
      }

      var counts: Set<String> = []
      for header in headers {
         if counts.contains(header.substitutionName) {
            context.diagnose(diagnostics.oneHeaderOnly(for: decl, headerName: header.substitutionName))
            return nil
         }

         counts.insert(header.substitutionName)
      }

      var headersDict: DictionaryExprSyntax?
      if
         let index = decl.attributes.firstIndex(where: { attribute in
            attribute.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "Headers"
         }),
         let dict = decl.attributes[index].as(AttributeSyntax.self)?.arguments?
            .as(LabeledExprListSyntax.self)?.first?.expression.as(DictionaryExprSyntax.self)
      {
         headersDict = dict
      }

      return try CodeBlockItemListSyntax {
         let modifier = headers.isEmpty ? "let" : "var"
         if let headersDict {
            try VariableDeclSyntax("\(raw: modifier) headers: [String: String] = \(headersDict)")
         } else {
            try VariableDeclSyntax("\(raw: modifier) headers: [String: String] = [:]")
         }

         for header in headers {
            if header.isOptional {
               try IfExprSyntax("if let \(header.variableName)") {
                  CodeBlockItemSyntax(#"headers["\#(raw: header.substitutionName)"] = \#(header.variableName)"#)
               }
            } else {
               CodeBlockItemSyntax(#"headers["\#(raw: header.substitutionName)"] = \#(header.variableName)"#)
            }
         }
      }
   }

   private static func bodyConverterDecl(dependingOn type: TokenSyntax) throws -> VariableDeclSyntax {
      let converterTypeNamePrefix: String
      if type.text == "String" {
         converterTypeNamePrefix = "StringBodyConverter"
      } else {
         converterTypeNamePrefix = "JSONEncoderBodyConverter<\(type)>"
      }

      return try VariableDeclSyntax("let bodyConverter = \(raw: converterTypeNamePrefix)()")
   }

   private static func bodyDecl(
      byProcessing decl: some DeclGroupSyntax,
      in context: some MacroExpansionContext,
      diagnostics: Diagnostics
   ) throws -> (hasBody: Bool, decl: CodeBlockItemListSyntax)? {
      let variableDecls = variableDecls(of: decl, attributedBy: "Body")
      guard variableDecls.count < 2 else {
         context.diagnose(diagnostics.tooManyBodyParameters(for: decl))
         return nil
      }

      guard let variableDecl = variableDecls.first else {
         return (false, CodeBlockItemListSyntax { })
      }

      guard let binding = variableDecl.bindings.first else {
         context.diagnose(.unexpectedError(for: decl))
         return nil
      }

      guard let variableName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
         context.diagnose(.unexpectedError(for: decl))
         return nil
      }

      guard 
         let index = variableDecl.attributes.firstIndex(where: { attribute in
            attribute.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "Body"
         }),
         let attribute = variableDecl.attributes[index].as(AttributeSyntax.self)
      else {
         context.diagnose(.unexpectedError(for: decl))
         return nil
      }

      if let argument = attribute.arguments?.as(LabeledExprListSyntax.self)?.first {
         return try (true, CodeBlockItemListSyntax {
            try VariableDeclSyntax("let body = \(variableName)")
            try VariableDeclSyntax("let bodyConverter = \(argument.expression)")
         })
      } else {
         guard let type = binding.typeAnnotation?.type.as(IdentifierTypeSyntax.self)?.name else {
            context.diagnose(diagnostics.bodyTypeNotInferred(for: decl))
            return nil
         }

         return try (true, CodeBlockItemListSyntax {
            try VariableDeclSyntax("let body = \(variableName)")
            try bodyConverterDecl(dependingOn: type)
         })
      }
   }
}
