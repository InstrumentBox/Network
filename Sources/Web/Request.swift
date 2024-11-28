//
//  Request.swift
//
//  Copyright © 2022 Aleksei Zaikin.
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

/// A protocol that describes every request sent by a `WebClient`.
public protocol Request<SuccessObject>: Sendable {
   /// A type of object that is expected in case of successful request execution.
   associatedtype SuccessObject: Sendable

   /// A type of object that is expected in case of invalid server response, e.g. some API error.
   /// Designed to be thrown by ``WebClient``.
   associatedtype ErrorObject: Error

   /// A response converter that is used to convert server response in case when response
   /// validator tells that response is successful (e.g *Content-Type* and *Accept* headers match
   /// and status code is 2xx).
   var successObjectResponseConverter: any ResponseConverter<SuccessObject> { get }

   /// A response converter that is used to convert server response in case when response
   /// validator tells that response is not successful (e.g *Content-Type* and *Accept* headers
   /// match and status code is not 2xx).
   var errorObjectResponseConverter: any ResponseConverter<ErrorObject> { get }

   /// A validator that check incoming response for a validity and gives disposition what way a
   /// `WebClient` should use to complete response processing.
   ///
   /// Response validator is an object that tells if `WebClient` should either complete with
   /// validation error, or parse response and return object, or parse response and throw API error.
   var responseValidator: any ResponseValidator { get }

   /// The point where you need to create and return an instance of `URLRequest` with appropriate
   /// URL, method, headers, and body.
   ///
   /// - Parameters:
   ///   - baseURL: A base URL from a configuration of a `WebClient`.
   /// - Returns: An instance of `URLRequest`.
   /// - Throws: An error occurred during `URLRequest` instantiation process.
   func toURLRequest(with baseURL: URL?) throws -> URLRequest
}

extension Request {
   /// Returns ``StatusCodeContentTypeResponseValidator``.
   public var responseValidator: any ResponseValidator {
      StatusCodeContentTypeResponseValidator()
   }
}
