//
//  WebClient.swift
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

/// A protocol that describes a web client that sends requests and processes responses to requests
/// by validating them and returns either resulting objects or API errors.
///
/// A web client also provides `Request`s authorization, server trust evaluation,
/// 2FA challenges handling.
///
/// - Note: A web client is *NOT* intended to work with a background URL session.
public protocol WebClient: AnyObject {
   /// Executes `Request` asynchronously.
   ///
   /// - Parameters:
   ///   - request: `Request` that needs to sent to a server and response to which should be
   ///              processed.
   /// - Returns: An object received from a server.
   /// - Throws: An error that occurred during request. It may be API error in case of 4xx or 5xx,
   ///           `URLError`, response converter error, or any other error.
   func execute<Request: Web.Request>(
      _ request: Request
   ) async throws -> Request.ObjectResponseConverter.ConvertedResponse
}
