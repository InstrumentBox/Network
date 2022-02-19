//
//  URLSession+DataRequest.swift
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

extension URLSession {
   func data(for request: URLRequest) async throws -> Response {
      if #available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *) {
         return try await newData(for: request)
      } else {
         return try await prevData(for: request)
      }
   }

   @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
   func newData(for request: URLRequest) async throws -> Response {
      let (body, urlResponse) = try await data(for: request)
      guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
         throw URLError(.badServerResponse)
      }

      return Response(request: request, httpURLResponse: httpURLResponse, body: body)
   }

   func prevData(for request: URLRequest) async throws -> Response {
      try await withUnsafeThrowingContinuation { continuation in
         dataTask(with: request) { body, urlResponse, error in
            if let error = error {
               continuation.resume(throwing: error)
               return
            }

            guard let httpURLResponse = urlResponse as? HTTPURLResponse, let body = body else {
               let error = URLError(.badServerResponse)
               continuation.resume(throwing: error)
               return
            }

            let response = Response(request: request, httpURLResponse: httpURLResponse, body: body)
            continuation.resume(returning: response)
         }
      }
   }
}
