//
//  Method.swift
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

/// An HTTP method.
public struct Method: Equatable {
   let raw: String

   // MARK: - Init

   /// Creates and returns a `Method` instance from a raw value.
   ///
   /// - Parameters:
   ///   - raw: Raw value of HTTP method
   public init(_ raw: String) {
      self.raw = raw
   }

   // MARK: - Predefined

   /// CONNECT method.
   public static let connect = Method("CONNECT")

   /// DELETE method.
   public static let delete = Method("DELETE")

   /// GET method.
   public static let get = Method("GET")

   /// HEAD method.
   public static let head = Method("HEAD")

   /// OPTIONS method.
   public static let options = Method("OPTIONS")

   /// PATCH method.
   public static let patch = Method("PATCH")

   /// POST method.
   public static let post = Method("POST")

   /// PUT method.
   public static let put = Method("PUT")

   /// TRACE method.
   public static let trace = Method("TRACE")
}
