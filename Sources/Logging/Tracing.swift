//
//  Tracing.swift
//
//  Copyright © 2025 Aleksei Zaikin.
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

import OSLog
import Web

package func webCoreTraceRequest(_ request: some Request, convertedTo urlRequest: URLRequest) {
   let logger = Loggers.logger(forSubsystem: .webCore, category: .request)
   traceRequest(request, convertedTo: urlRequest, using: logger)
}

package func webCoreTraceRequestCURL( _ request: some Request, convertedTo urlRequest: URLRequest) {
   let logger = Loggers.logger(forSubsystem: .webCore, category: .requestCURL)
   traceRequestCURL(request, convertedTo: urlRequest, using: logger)
}

package func webCoreTraceResponse(_ response: Response, for request: some Request) {
   let logger = Loggers.logger(forSubsystem: .webCore, category: .response)
   traceResponse(response, for: request, using: logger)
}

package func webStubTraceRequest(_ request: some Request, convertedTo urlRequest: URLRequest) {
   let logger = Loggers.logger(forSubsystem: .webStub, category: .request)
   traceRequest(request, convertedTo: urlRequest, using: logger)
}

package func webStubTraceRequestCURL( _ request: some Request, convertedTo urlRequest: URLRequest) {
   let logger = Loggers.logger(forSubsystem: .webStub, category: .requestCURL)
   traceRequestCURL(request, convertedTo: urlRequest, using: logger)
}

package func webStubTraceResponse(_ response: Response, for request: some Request) {
   let logger = Loggers.logger(forSubsystem: .webStub, category: .response)
   traceResponse(response, for: request, using: logger)
}

// MARK: - Logging

private func traceRequest(
   _ request: some Request,
   convertedTo urlRequest: URLRequest,
   using l: Logger
) {
   guard let method = urlRequest.httpMethod, let url = urlRequest.url?.absoluteString else {
      l.warning("Couldn't build description for \(type(of: request)). Either HTTP method or URL missed.")
      return
   }

   var description = ""
   description += "\(method) \(url)"
   description += "\n"

   for (headerName, headerValue) in urlRequest.allHTTPHeaderFields ?? [:] {
      description += "\(headerName): \(headerValue)"
      description += "\n"
   }

   if let body = urlRequest.httpBody, !body.isEmpty {
      description += "\n"
      description += "<Body: \(ByteCountFormatter.kB.string(fromByteCount: body.count))>"
      description += "\n"
   }

   l.trace("Executing \(type(of: request))\n\n\(description)")
}

private func traceRequestCURL(
   _ request: some Request,
   convertedTo urlRequest: URLRequest,
   using l: Logger
) {
   guard let method = urlRequest.httpMethod, let url = urlRequest.url?.absoluteString else {
      l.warning("Couldn't build cURL command for \(type(of: request)). Either HTTP method or URL missed.")
      return
   }

   var cURL = ""
   cURL += "curl \(url) \\"
   cURL += "\n"
   cURL += "-X \(method) \\"
   cURL += "\n"

   for (headerName, headerValue) in urlRequest.allHTTPHeaderFields ?? [:] {
      cURL += #"-H "\#(headerName): \#(headerValue)" \"#
      cURL += "\n"
   }

   if let body = urlRequest.httpBody, !body.isEmpty {
      cURL += "--data-binary @-"
      cURL += "\n"

      cURL = "echo -e '\(body.byteString)' | \\\n\(cURL)"
   }

   l.trace("Executing request \(type(of: request))\n\n\(cURL)")
}

private func traceResponse(_ response: Response, for request: some Request, using l: Logger) {
   var description = ""

   let statusCode = response.statusCode
   let statusDescription = HTTPURLResponse.localizedString(forStatusCode: statusCode).uppercased()
   description += "\(statusCode) \(statusDescription)"
   description += "\n"

   for (headerName, headerValue) in response.headers {
      description += "\(headerName): \(headerValue)"
      description += "\n"
   }

   if !response.body.isEmpty {
      description += "\n"
      description += "<Body: \(ByteCountFormatter.kB.string(fromByteCount: response.body.count))>"
      description += "\n"
   }

   l.trace("Received response for \(type(of: request))\n\n\(description)")
}
