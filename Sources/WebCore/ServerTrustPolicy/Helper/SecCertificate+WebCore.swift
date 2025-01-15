//
//  SecCertificate+WebCore.swift
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

extension SecCertificate {
   /// Finds and returns all certificates in a given bundle. A certificate is a file with one of the
   /// following extensions: .cer/.CER, .crt/.CRT, or .der/.DER.
   ///
   /// - Parameters:
   ///   - bundle: Bundle, in which certificates should be found. Defaults to `Bundle.main`.
   /// - Returns: Array of certificates found in given bundle.
   public static func all(in bundle: Bundle = .main) -> [SecCertificate] {
      let paths = [".cer", ".CER", ".crt", ".CRT", ".der", ".DER"].flatMap { ext -> [String] in
         bundle.paths(forResourcesOfType: ext, inDirectory: nil)
      }

      return paths.compactMap { path in
         guard
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)) as CFData,
            let cert = SecCertificateCreateWithData(nil, data)
         else {
            return nil
         }

         return cert
      }
   }

   var publicKey: SecKey? {
      var publicKey: SecKey?

      var trust: SecTrust?
      let policy = SecPolicyCreateBasicX509()
      let trustCreationStatus = SecTrustCreateWithCertificates(self, policy, &trust)

      if let trust, trustCreationStatus == errSecSuccess {
         publicKey = SecTrustCopyKey(trust)
      }

      return publicKey
   }

   func equals(to cert: SecCertificate) -> Bool {
      let this = SecCertificateCopyData(self) as Data
      let that = SecCertificateCopyData(cert) as Data
      return this == that
   }
}
