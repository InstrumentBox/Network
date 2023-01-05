//
//  ResponseBuilder.swift
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
import Web

class ResponseBuilder {
   private var statusCode: Int?
   private var headers: [String: String] = [:]
   private var body = Data()

   private let request: URLRequest

   // MARK: - Init

   init(request: URLRequest) {
      self.request = request
   }

   // MARK: - Result

   var response: Response {
      get throws {
         guard let statusCode else {
            throw ResponseParserError.statusCodeMissed
         }

         return Response(request: request, statusCode: statusCode, headers: headers, body: body)
      }
   }

   // MARK: - Configuration

   func setStatusCode(_ statusCode: Int) {
      self.statusCode = statusCode
   }

   func setHeaderValue(_ headerValue: String, forHeaderName headerName: String) {
      headers[headerName] = headerValue
   }

   func appendBodyDataChunk(_ chunk: Data) {
      body.append(chunk)
   }
}
