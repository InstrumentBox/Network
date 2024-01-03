//
//  ResponseParserError.swift
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

/// An error that is thrown when ``StubbedWebClient`` can't parse response from file.
public enum ResponseParserError: Error, Equatable {
   /// Thrown when status code is not a number.
   case incorrectStatusCodeData

   /// Thrown when status code is not set for a `Response`.
   case statusCodeMissed

   /// Thrown when header can't be read as string.
   case incorrectHeaderData

   /// Thrown when header string can't be parsed into name and value divided by colon.
   case incorrectHeader(String)

   // MARK: - Equatable

   public static func ==(lhs: ResponseParserError, rhs: ResponseParserError) -> Bool {
      switch (lhs, rhs) {
         case (.incorrectStatusCodeData, .incorrectStatusCodeData),
              (.statusCodeMissed, .statusCodeMissed),
              (.incorrectHeaderData, .incorrectHeaderData):
            return true
         case let (.incorrectHeader(lhsHeader), .incorrectHeader(rhsHeader)):
            return lhsHeader == rhsHeader
         default:
            return false
      }
   }
}
