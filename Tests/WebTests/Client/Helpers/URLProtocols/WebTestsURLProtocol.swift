//
//  WebTestsURLProtocol.swift
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

class WebTestsURLProtocol: URLProtocol {
   private var timer: Timer?

   // MARK: - URLProtocol

   override final class func canInit(with request: URLRequest) -> Bool { true }

   override final class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

   override final func startLoading() {
      let timer = Timer(timeInterval: 0.1, repeats: false) { [weak self] _ in
         self?.startFetching()
      }
      RunLoop.current.add(timer, forMode: .common)
      self.timer = timer
   }

   override final func stopLoading() {
      timer?.invalidate()
      timer = nil
      stopFetching()
   }

   // MARK: - Fetching

   func startFetching() {
      if returnsError {
         client?.urlProtocol(self, didFailWithError: error)
      } else {
         let response = makeURLResponse()
         let body = makeBody()
         client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
         client?.urlProtocol(self, didLoad: body)
      }
      client?.urlProtocolDidFinishLoading(self)
   }

   func stopFetching() { }

   // MARK: - Response Construction

   var returnsError: Bool { false }

   var error: Error {
      URLError(.cancelled)
   }

   var statusCode: Int { 200 }

   var headers: [String: String] {
      ["Content-Type": "application/octet-stream; charset=utf8"]
   }

   func makeURLResponse() -> URLResponse {
      HTTPURLResponse(
         url: request.url!,
         statusCode: statusCode,
         httpVersion: "2.0",
         headerFields: headers
      )!
   }

   func makeBody() -> Data {
      Data([0x01, 0x02, 0x03])
   }
}
