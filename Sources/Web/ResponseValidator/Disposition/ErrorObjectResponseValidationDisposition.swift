//
//  ErrorObjectResponseValidationDisposition.swift
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

/// Response validation disposition that uses `errorObjectResponseConverter` provided by a request object.
public struct ErrorObjectResponseValidationDisposition: ResponseValidationDisposition {
   // MARK: - Init

   /// Creates and returns a new instance of `ErrorObjectResponseValidationDisposition`.
   public init() { }

   // MARK: - ResponseValidationDisposition

   public func processResponse<SuccessObject>(
      _ response: Response,
      for request: some Request<SuccessObject>
   ) throws -> SuccessObject {
      throw try request.errorObjectResponseConverter.convert(response)
   }
}
