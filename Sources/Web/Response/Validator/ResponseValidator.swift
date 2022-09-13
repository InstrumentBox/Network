//
//  ResponseValidator.swift
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

/// A disposition of a validator after analyzing a response.
public enum ResponseValidationDisposition {
   /// Tells to use an object response converter of a `Request` (e.g. status code of a response is
   /// 2xx).
   case useSuccessObjectResponseConverter

   /// Tells to use an error response converter of a `Request` (e.g status code of a response is
   /// not 2xx).
   case useErrorObjectResponseConverter

   /// Tells to complete with an error occurred during response validation (e.g. *Content-Type* and
   /// *Accept* headers don't match).
   case completeWithError(Error)
}

/// A protocol you need to conform an object to use it a response validator.
public protocol ResponseValidator {
   /// Validate a response and dispose what way a `WebClient` should go further.
   ///
   /// - Parameters:
   ///   - response: A response that needs to be validated.
   /// - Returns: A disposition of what way go further. See `ResponseValidationDisposition`
   ///            for more information.
   func validate(_ response: Response) -> ResponseValidationDisposition
}
