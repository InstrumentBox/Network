//
//  ResponseParser.swift
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
import Web

class ResponseParser {
   lazy var state: any ResponseParserState = ReceivingStatusCodeResponseParserState(
      parser: self,
      builder: builder
   )

   private let builder: ResponseBuilder
   private let reader: LineByLineReader

   // MARK: - Init

   init?(request: URLRequest, responseURL: URL) {
      guard let reader = LineByLineReader(fileURL: responseURL) else {
         return nil
      }

      self.reader = reader
      builder = ResponseBuilder(request: request)
   }

   // MARK: - Parsing

   func parse() throws -> Response {
      while let responseChunk = reader.readLine() {
         try state.process(responseChunk)
      }

      return try builder.response
   }
}
