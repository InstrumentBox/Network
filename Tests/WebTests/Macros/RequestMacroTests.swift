//
//  RequestMacroTests.swift
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
   "CONNECT": RequestMacro.self,
   "DELETE": RequestMacro.self,
   "GET": RequestMacro.self,
   "HEAD": RequestMacro.self,
   "OPTIONS": RequestMacro.self,
   "PATCH": RequestMacro.self,
   "POST": RequestMacro.self,
   "PUT": RequestMacro.self,
   "TRACE": RequestMacro.self
]

@Suite("@GET/@POST/etc")
struct RequestMacroTests {
   @Test("Expanded with correct HTTP method", arguments: testMacros.keys)
   func expandWithAllHTTPMethods(method: String) {
      assertMacroExpansion(
         """
         @\(method)<TestObject, APIError>("path/to/resource")
         class TestObjectRequest {
         }
         """,
         expandedSource:
         """
         class TestObjectRequest {
         }

         extension TestObjectRequest: Request {
             typealias SuccessObject = TestObject
             typealias ErrorObject = APIError
             var successObjectResponseConverter: any ResponseConverter<TestObject> {
                 JSONDecoderResponseConverter()
             }
             var errorObjectResponseConverter: any ResponseConverter<APIError> {
                 JSONDecoderResponseConverter()
             }
             func toURLRequest(with baseURL: URL?) throws -> URLRequest {
                 let method = Method("\(method)")
                 let path = "path/to/resource"
                 let query: [String: Any] = [:]
                 let url = try URL(path: path, baseURL: baseURL, query: query)
                 let headers: [String: String] = [:]
                 let request = URLRequest(url: url, method: method, headers: headers)
                 return request
             }
         }
         """,
         macros: testMacros
      )
   }

   @Test("Expanded with no generated converters if converters are defined by a developer")
   func expandWithDefinedConverters() {
      assertMacroExpansion(
         """
         @GET<TestObject, APIError>("path/to/some/object")
         struct TestObjectRequest {
             var successObjectResponseConverter: any ResponseConverter<TestObject> {
                 JSONDecoderResponseConverter()
             }

             var errorObjectResponseConverter: any ResponseConverter<APIError> {
                 JSONDecoderResponseConverter()
             }
         }
         """,
         expandedSource:
         """
         struct TestObjectRequest {
             var successObjectResponseConverter: any ResponseConverter<TestObject> {
                 JSONDecoderResponseConverter()
             }

             var errorObjectResponseConverter: any ResponseConverter<APIError> {
                 JSONDecoderResponseConverter()
             }
         }

         extension TestObjectRequest: Request {
             typealias SuccessObject = TestObject
             typealias ErrorObject = APIError
             func toURLRequest(with baseURL: URL?) throws -> URLRequest {
                 let method = Method("GET")
                 let path = "path/to/some/object"
                 let query: [String: Any] = [:]
                 let url = try URL(path: path, baseURL: baseURL, query: query)
                 let headers: [String: String] = [:]
                 let request = URLRequest(url: url, method: method, headers: headers)
                 return request
             }
         }
         """,
         macros: testMacros
      )
   }

   @Test("Expanded with path substitutions")
   func expandWithPathSubstitutions() {
      assertMacroExpansion(
         """
         @POST<TestObject, APIError>("path/:to/some/:resource")
         struct TestObjectRequest {
             @Path
             let to: String

             @Path("resource")
             let r: String
         }
         """,
         expandedSource:
         """
         struct TestObjectRequest {
             @Path
             let to: String

             @Path("resource")
             let r: String
         }

         extension TestObjectRequest: Request {
             typealias SuccessObject = TestObject
             typealias ErrorObject = APIError
             var successObjectResponseConverter: any ResponseConverter<TestObject> {
                 JSONDecoderResponseConverter()
             }
             var errorObjectResponseConverter: any ResponseConverter<APIError> {
                 JSONDecoderResponseConverter()
             }
             func toURLRequest(with baseURL: URL?) throws -> URLRequest {
                 let method = Method("POST")
                 let path = "path/\\(to)/some/\\(r)"
                 let query: [String: Any] = [:]
                 let url = try URL(path: path, baseURL: baseURL, query: query)
                 let headers: [String: String] = [:]
                 let request = URLRequest(url: url, method: method, headers: headers)
                 return request
             }
         }
         """,
         macros: testMacros
      )
   }

   @Test("Shows error if path segments duplication")
   func expandWithPathSegmentDuplication() {
      assertMacroExpansion(
         """
         @POST<TestObject, APIError>("path/:to/some/:resource/:resource")
         struct TestObjectRequest {
         }
         """,
         expandedSource:
         """
         struct TestObjectRequest {
         }
         """,
         diagnostics: [
            DiagnosticSpec(message: "Duplication of substitutable path segment name 'resource'", line: 1, column: 1)
         ],
         macros: testMacros
      )
   }

   @Test("Shows error if path parameter not found")
   func expandWithPathParameterNotFound() {
      assertMacroExpansion(
         """
         @POST<TestObject, APIError>("path/:to/some/:resource")
         struct TestObjectRequest {
             @Path
             let to: String
         }
         """,
         expandedSource:
         """
         struct TestObjectRequest {
             @Path
             let to: String
         }

         """,
         diagnostics: [
            DiagnosticSpec(message: "Couldn't find substitution parameter for path segment :resource", line: 1, column: 1)
         ],
         macros: testMacros
      )
   }

   @Test("Shows error if path parameter duplication")
   func expandWithPathParameterDuplication() {
      assertMacroExpansion(
         """
         @POST<TestObject, APIError>("path/:to/some/:resource")
         struct TestObjectRequest {
             @Path
             let to: String

             @Path("resource")
             let r: String

             @Path
             let resource: String
         }
         """,
         expandedSource:
         """
         struct TestObjectRequest {
             @Path
             let to: String

             @Path("resource")
             let r: String

             @Path
             let resource: String
         }
         """,
         diagnostics: [
            DiagnosticSpec(message: "Invalid redeclaration of path parameter with name 'resource'", line: 1, column: 1)
         ],
         macros: testMacros
      )
   }

   @Test("Expanded with query parameters")
   func expandWithQueryParameters() {
      assertMacroExpansion(
         """
         @POST<TestObject, APIError>("path/to/resource")
         struct TestObjectRequest {
             @Query
             let firstItem: String

             @Query("second_item")
             let secondItem: String?
         }
         """,
         expandedSource:
         """
         struct TestObjectRequest {
             @Query
             let firstItem: String

             @Query("second_item")
             let secondItem: String?
         }

         extension TestObjectRequest: Request {
             typealias SuccessObject = TestObject
             typealias ErrorObject = APIError
             var successObjectResponseConverter: any ResponseConverter<TestObject> {
                 JSONDecoderResponseConverter()
             }
             var errorObjectResponseConverter: any ResponseConverter<APIError> {
                 JSONDecoderResponseConverter()
             }
             func toURLRequest(with baseURL: URL?) throws -> URLRequest {
                 let method = Method("POST")
                 let path = "path/to/resource"
                 var query: [String: Any] = [:]
                 query["firstItem"] = firstItem
                 if let secondItem {
                     query["second_item"] = secondItem
                 }
                 let url = try URL(path: path, baseURL: baseURL, query: query)
                 let headers: [String: String] = [:]
                 let request = URLRequest(url: url, method: method, headers: headers)
                 return request
             }
         }
         """,
         macros: testMacros
      )
   }

   @Test("Shows error if query item duplication")
   func expandWithQueryItemDuplication() {
      assertMacroExpansion(
         """
         @POST<TestObject, APIError>("path/to/resource")
         struct TestObjectRequest {
             @Query
             let queryItem: String

             @Query("queryItem")
             let q: String

             @Query
             let otherQueryItem: String
         }
         """,
         expandedSource:
         """
         struct TestObjectRequest {
             @Query
             let queryItem: String

             @Query("queryItem")
             let q: String

             @Query
             let otherQueryItem: String
         }
         """,
         diagnostics: [
            DiagnosticSpec(message: "Invalid redeclaration of query item with name 'queryItem'", line: 1, column: 1)
         ],
         macros: testMacros
      )
   }

   @Test("Expanded with header parameters")
   func expandWithHeaderParameters() {
      assertMacroExpansion(
         """
         @POST<TestObject, APIError>("path/to/resource")
         @Headers([
             "first_header": "first_header_value",
             "second_header": "second_header_value"
         ])
         struct TestObjectRequest {
             @Header
             let thirdHeader: String

             @Header("fourth_header")
             let fourthHeader: String?
         }
         """,
         expandedSource:
         """
         @Headers([
             "first_header": "first_header_value",
             "second_header": "second_header_value"
         ])
         struct TestObjectRequest {
             @Header
             let thirdHeader: String

             @Header("fourth_header")
             let fourthHeader: String?
         }

         extension TestObjectRequest: Request {
             typealias SuccessObject = TestObject
             typealias ErrorObject = APIError
             var successObjectResponseConverter: any ResponseConverter<TestObject> {
                 JSONDecoderResponseConverter()
             }
             var errorObjectResponseConverter: any ResponseConverter<APIError> {
                 JSONDecoderResponseConverter()
             }
             func toURLRequest(with baseURL: URL?) throws -> URLRequest {
                 let method = Method("POST")
                 let path = "path/to/resource"
                 let query: [String: Any] = [:]
                 let url = try URL(path: path, baseURL: baseURL, query: query)
                 var headers: [String: String] = [
                     "first_header": "first_header_value",
                     "second_header": "second_header_value"
                 ]
                 headers["thirdHeader"] = thirdHeader
                 if let fourthHeader {
                     headers["fourth_header"] = fourthHeader
                 }
                 let request = URLRequest(url: url, method: method, headers: headers)
                 return request
             }
         }
         """,
         macros: testMacros
      )
   }

   @Test("Shows error if header duplication")
   func expandWithHeaderDuplication() {
      assertMacroExpansion(
         """
         @POST<TestObject, APIError>("path/to/resource")
         struct TestObjectRequest {
             @Header
             let firstHeader: String

             @Header("second_header")
             let secondHeader: String

             @Header("second_header")
             let s: String
         }
         """,
         expandedSource:
         """
         struct TestObjectRequest {
             @Header
             let firstHeader: String

             @Header("second_header")
             let secondHeader: String

             @Header("second_header")
             let s: String
         }
         """,
         diagnostics: [
            DiagnosticSpec(message: "Invalid redeclaration of header with name 'second_header'", line: 1, column: 1)
         ],
         macros: testMacros
      )
   }

   @Test("Expanded with body parameter")
   func expandWithBody() {
      assertMacroExpansion(
         """
         @POST<TestObject, APIError>("path/to/resource")
         struct TestObjectRequest {
             @Body
             let object: TestObject
         }
         """,
         expandedSource:
         """
         struct TestObjectRequest {
             @Body
             let object: TestObject
         }

         extension TestObjectRequest: Request {
             typealias SuccessObject = TestObject
             typealias ErrorObject = APIError
             var successObjectResponseConverter: any ResponseConverter<TestObject> {
                 JSONDecoderResponseConverter()
             }
             var errorObjectResponseConverter: any ResponseConverter<APIError> {
                 JSONDecoderResponseConverter()
             }
             func toURLRequest(with baseURL: URL?) throws -> URLRequest {
                 let method = Method("POST")
                 let path = "path/to/resource"
                 let query: [String: Any] = [:]
                 let url = try URL(path: path, baseURL: baseURL, query: query)
                 let headers: [String: String] = [:]
                 let body = object
                 let bodyConverter = JSONEncoderBodyConverter<TestObject>()
                 let request = try URLRequest(url: url, method: method, headers: headers, body: body, converter: bodyConverter)
                 return request
             }
         }
         """,
         macros: testMacros
      )
   }

   @Test("Expanded with body converter given by a developer")
   func expandWithDefinedBodyConverter() {
      assertMacroExpansion(
         """
         @POST<TestObject, APIError>("path/to/resource")
         struct TestObjectRequest {
             @Body(JSONEncoderBodyConverter<TestObject>(encoder: {
                 let encoder = JSONEncoder()
                 encoder.dateEncodingStrategy = .iso8601
                 return encoder
             }()))
             let object: TestObject
         }
         """,
         expandedSource:
         """
         struct TestObjectRequest {
             @Body(JSONEncoderBodyConverter<TestObject>(encoder: {
                 let encoder = JSONEncoder()
                 encoder.dateEncodingStrategy = .iso8601
                 return encoder
             }()))
             let object: TestObject
         }

         extension TestObjectRequest: Request {
             typealias SuccessObject = TestObject
             typealias ErrorObject = APIError
             var successObjectResponseConverter: any ResponseConverter<TestObject> {
                 JSONDecoderResponseConverter()
             }
             var errorObjectResponseConverter: any ResponseConverter<APIError> {
                 JSONDecoderResponseConverter()
             }
             func toURLRequest(with baseURL: URL?) throws -> URLRequest {
                 let method = Method("POST")
                 let path = "path/to/resource"
                 let query: [String: Any] = [:]
                 let url = try URL(path: path, baseURL: baseURL, query: query)
                 let headers: [String: String] = [:]
                 let body = object
                 let bodyConverter = JSONEncoderBodyConverter<TestObject>(encoder: {
                         let encoder = JSONEncoder()
                         encoder.dateEncodingStrategy = .iso8601
                         return encoder
                     }())
                 let request = try URLRequest(url: url, method: method, headers: headers, body: body, converter: bodyConverter)
                 return request
             }
         }
         """,
         macros: testMacros
      )
   }

   @Test("Shows error if more than one @Body")
   func expandWithMoreThanOneBody() {
      assertMacroExpansion(
         """
         @POST<TestObject, APIError>("path/to/resource")
         struct TestObjectRequest {
             @Body
             let object: TestObject

             @Body
             let anotherObject: TestObject
         }
         """,
         expandedSource:
         """
         struct TestObjectRequest {
             @Body
             let object: TestObject

             @Body
             let anotherObject: TestObject
         }
         """,
         diagnostics: [
            DiagnosticSpec(message: "Request should have at most one @Body parameter", line: 1, column: 1)
         ],
         macros: testMacros
      )
   }

   @Test("Shows error if can't infer body converter type")
   func expandWithUnknownBodyConverter() {
      assertMacroExpansion(
         """
         @POST<TestObject, APIError>("path/to/resource")
         struct TestObjectRequest {
             @Body
             let object = TestObject()
         }
         """,
         expandedSource:
         """
         struct TestObjectRequest {
             @Body
             let object = TestObject()
         }
         """,
         diagnostics: [
            DiagnosticSpec(
               message: "Couldn't infer converter type for body. Please specify converter type, e.g. @Body(MyOwnBodyConverter())",
               line: 1,
               column: 1
            )
         ],
         macros: testMacros
      )
   }

   @Test("Expanded with correct response converter depending on type", arguments: [
      ("Response", "AsIsResponseConverter"),
      ("Data", "DataResponseConverter"),
      ("Void", "EmptyResponseConverter"),
      ("String", "StringResponseConverter"),
      ("UIImage", "ImageResponseConverter"),
      ("[TestObject]", "JSONDecoderResponseConverter"),
      ("AnyOther", "JSONDecoderResponseConverter")
   ])
   func expandWithGeneratedResponseConverter(type: String, converterType: String) {
      assertMacroExpansion(
         """
         @GET<\(type), \(type)>("path/to/resource")
         struct TestObjectRequest {
         }
         """,
         expandedSource:
         """
         struct TestObjectRequest {
         }

         extension TestObjectRequest: Request {
             typealias SuccessObject = \(type)
             typealias ErrorObject = \(type)
             var successObjectResponseConverter: any ResponseConverter<\(type)> {
                 \(converterType)()
             }
             var errorObjectResponseConverter: any ResponseConverter<\(type)> {
                 \(converterType)()
             }
             func toURLRequest(with baseURL: URL?) throws -> URLRequest {
                 let method = Method("GET")
                 let path = "path/to/resource"
                 let query: [String: Any] = [:]
                 let url = try URL(path: path, baseURL: baseURL, query: query)
                 let headers: [String: String] = [:]
                 let request = URLRequest(url: url, method: method, headers: headers)
                 return request
             }
         }
         """,
         macros: testMacros
      )
   }

   @Test("Expanded with correct body converter depending on type", arguments: [
      ("String", "StringBodyConverter"),
      ("AnyOther", "JSONEncoderBodyConverter<AnyOther>")
   ])
   func expandWithGeneratedBodyConverter(type: String, converterType: String) {
      assertMacroExpansion(
         """
         @POST<TestObject, APIError>("path/to/resource")
         struct TestObjectRequest {
             @Body
             let object: \(type)
         }
         """,
         expandedSource:
         """
         struct TestObjectRequest {
             @Body
             let object: \(type)
         }

         extension TestObjectRequest: Request {
             typealias SuccessObject = TestObject
             typealias ErrorObject = APIError
             var successObjectResponseConverter: any ResponseConverter<TestObject> {
                 JSONDecoderResponseConverter()
             }
             var errorObjectResponseConverter: any ResponseConverter<APIError> {
                 JSONDecoderResponseConverter()
             }
             func toURLRequest(with baseURL: URL?) throws -> URLRequest {
                 let method = Method("POST")
                 let path = "path/to/resource"
                 let query: [String: Any] = [:]
                 let url = try URL(path: path, baseURL: baseURL, query: query)
                 let headers: [String: String] = [:]
                 let body = object
                 let bodyConverter = \(converterType)()
                 let request = try URLRequest(url: url, method: method, headers: headers, body: body, converter: bodyConverter)
                 return request
             }
         }
         """,
         macros: testMacros
      )
   }

   @Test("Expanded with correct access modifier", arguments: [
      ("open ", "open "),
      ("public ", "public "),
      ("package ", "package "),
      ("internal ", ""),
      ("fileprivate ", ""),
      ("private ", ""),
      ("", "")
   ])
   func expandWithAccessModifier(accessModifier: String, expectedAccessModifier: String) {
      assertMacroExpansion(
         """
         @GET<TestObject, APIError>("path/to/resource")
         \(accessModifier)class TestObjectRequest {
         }
         """,
         expandedSource:
         """
         \(accessModifier)class TestObjectRequest {
         }

         extension TestObjectRequest: Request {
             \(expectedAccessModifier)typealias SuccessObject = TestObject
             \(expectedAccessModifier)typealias ErrorObject = APIError
             \(expectedAccessModifier)var successObjectResponseConverter: any ResponseConverter<TestObject> {
                 JSONDecoderResponseConverter()
             }
             \(expectedAccessModifier)var errorObjectResponseConverter: any ResponseConverter<APIError> {
                 JSONDecoderResponseConverter()
             }
             \(expectedAccessModifier)func toURLRequest(with baseURL: URL?) throws -> URLRequest {
                 let method = Method("GET")
                 let path = "path/to/resource"
                 let query: [String: Any] = [:]
                 let url = try URL(path: path, baseURL: baseURL, query: query)
                 let headers: [String: String] = [:]
                 let request = URLRequest(url: url, method: method, headers: headers)
                 return request
             }
         }
         """,
         macros: testMacros
      )
   }
}

#endif
