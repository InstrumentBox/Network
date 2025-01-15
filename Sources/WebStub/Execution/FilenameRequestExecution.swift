//
//  FilenameRequestExecution.swift
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
import Logging
import Web

public enum FilenameRequestExecutionError: Error, Equatable {
   case cannotCreateResponseParser(URL)
}

actor FilenameRequestExecution: RequestExecution {
   private var cachedResponse: Response?

   private let responseURL: URL
   private let latency: (any Latency)?

   // MARK: - Init

   init(responseURL: URL, latency: (any Latency)?) {
      self.responseURL = responseURL
      self.latency = latency
   }

   // MARK: - ResponseRecord

   func execute<SuccessObject: Sendable>(
      _ request: some Request<SuccessObject>
   ) async throws -> SuccessObject {
      let response = try await response(for: request)

      if let latency {
         let value = UInt64(latency.value(for: request) * 1_000_000_000.0)
         try await Task.sleep(nanoseconds: value)
      }

      webStubTraceResponse(response, for: request)

      let disposition = request.responseValidator.validate(response)
      return try disposition.processResponse(response, for: request)
   }

   private func response(for request: some Request) async throws -> Response {
      let urlRequest = try request.toURLRequest(with: nil)

      webStubTraceRequest(request, convertedTo: urlRequest)
      webStubTraceRequestCURL(request, convertedTo: urlRequest)

      if let cachedResponse {
         return cachedResponse
      }

      guard let parser = ResponseParser(request: urlRequest, responseURL: responseURL) else {
         throw FilenameRequestExecutionError.cannotCreateResponseParser(responseURL)
      }

      let response = try parser.parse()
      cachedResponse = response
      return response
   }
}
