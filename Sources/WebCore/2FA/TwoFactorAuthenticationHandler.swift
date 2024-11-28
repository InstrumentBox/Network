//
//  TwoFactorAuthenticationHandler.swift
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

import Web

/// A protocol you need to implement and set to `URLSessionWebClient.Configuration` to handle
/// authentication challenges.
public protocol TwoFactorAuthenticationHandler: AnyObject, Sendable {
   /// Checks response and returns flag if 2FA process needs to be started.
   ///
   /// - Parameters:
   ///   - response: Response that needs to be check if 2FA process should be started.
   /// - Returns: `true` if 2FA handling needs to be started, otherwise `false`.
   func responseRequiresTwoFactorAuthentication(_ response: Response) -> Bool

   /// Starting point of 2FA challenge handling process.
   ///
   /// - Parameters:
   ///   - challenge: 2FA challenge that needs to be authenticated or cancelled.
   func handle(_ challenge: TwoFactorAuthenticationChallenge)
}
