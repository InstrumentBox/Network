//
//  URL+Construction.swift
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

public enum URLConstructionError: Error {
   case cannotConstructURL(path: String, baseURL: URL?)
}

extension URL {
   /// Creates and returns URL that consists of concatenated `path` and `baseURL`.
   ///
   /// This initializer works with relative URL mechanism so the result depends on whether you start
   /// your path with `/` or not and whether you end your base URL with `/` or not.
   ///
   /// Examples:
   ///
   /// ```swift
   /// path = "path/to/resource"
   /// baseURL = "https://api.myservice.com/v1/group/"
   /// completeURL = "https://apy.myservice.com/v1/group/path/to/resource"
   ///
   ///
   /// path = "/path/to/resource"
   /// baseURL = "https://api.myservice.com/v1/group/"
   /// completeURL = "https://apy.myservice.com/path/to/resource"
   ///
   ///
   /// path = "path/to/resource"
   /// baseURL = "https://api.myservice.com/v1/group"
   /// completeURL = "https://apy.myservice.com/v1/path/to/resource"
   /// ```
   ///
   /// - Parameters:
   ///   - path: A string which will be added to base URL.
   ///   - baseURL: A base URL of service web client works with.
   public init(path: String, baseURL: URL?) throws {
      let isPathCompleteURL = path.range(of: "://") != nil

      let comps = URLComponents(string: path)
      let completeURL = isPathCompleteURL ? comps?.url : comps?.url(relativeTo: baseURL)

      guard let completeURL = completeURL else {
         throw URLConstructionError.cannotConstructURL(path: path, baseURL: baseURL)
      }

      self = completeURL
   }

   /// Creates and returns URL that consists of concatenated `path`, `baseURL`, and percent encoded
   /// `query` using `URLEncoder`.
   ///
   /// This initializer works with relative URL mechanism so the result depends on whether you start
   /// your path with `/` or not and whether you end your base URL with `/` or not.
   ///
   /// Examples:
   ///
   /// ```swift
   /// path = "path/to/resource"
   /// baseURL = "https://api.myservice.com/v1/group/"
   /// completeURL = "https://apy.myservice.com/v1/group/path/to/resource"
   ///
   ///
   /// path = "/path/to/resource"
   /// baseURL = "https://api.myservice.com/v1/group/"
   /// completeURL = "https://apy.myservice.com/path/to/resource"
   ///
   ///
   /// path = "path/to/resource"
   /// baseURL = "https://api.myservice.com/v1/group"
   /// completeURL = "https://apy.myservice.com/v1/path/to/resource"
   /// ```
   ///
   /// - Parameters:
   ///   - path: A string which will be added to base URL.
   ///   - baseURL: A base URL of service web client works with.
   ///   - query: Query parameters that will be added to URL.
   ///   - encoder: URLEncoder that will be used to encode query parameters.
   public init(
      path: String,
      baseURL: URL?,
      query: [String: Any],
      encoder: URLEncoder = URLEncoder()
   ) throws {
      let isPathCompleteURL = path.range(of: "://") != nil

      var comps = URLComponents(string: path)
      comps?.percentEncodedQuery = try encoder.encode(query)
      let completeURL = isPathCompleteURL ? comps?.url : comps?.url(relativeTo: baseURL)

      guard let completeURL = completeURL else {
         throw URLConstructionError.cannotConstructURL(path: path, baseURL: baseURL)
      }

      self = completeURL
   }
}
