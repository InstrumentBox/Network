//
//  MIME.swift
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

struct MIME: Hashable, Sendable, CustomStringConvertible {
   let type: String
   let subtype: String

   // MARK: - Init

   init(type: String, subtype: String) {
      self.type = type
      self.subtype = subtype
   }

   // MARK: - Factory

   static func parseMIMEString(_ mimeString: String) -> MIME? {
      if #available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, *) {
         regex_parseMIMEString(mimeString)
      } else {
         nsRegularExpression_parseMIMEString(mimeString)
      }
   }

   @available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, *)
   private static func regex_parseMIMEString(_ mimeString: String) -> MIME? {
      let regex = /^(?<type>(\w+([-.+\w]*\w)?)|(\*))\/(?<subtype>(\w+([-.+\w]*\w)?)|(\*))(;\s?q=\d(.\d)?)?$/
      guard let match = try? regex.firstMatch(in: mimeString) else {
         return nil
      }

      let output = match.output
      let typeRange = output.type.startIndex..<output.type.endIndex
      let subtypeRange = output.subtype.startIndex..<output.subtype.endIndex
      let type = String(mimeString[typeRange])
      let subtype = String(mimeString[subtypeRange])
      return MIME(type: type, subtype: subtype)
   }

   private static func nsRegularExpression_parseMIMEString(_ mimeString: String) -> MIME? {
      let typeCaptureGroupName = "type"
      let subtypeCaptureGroupName = "subtype"
      let pattern = String(
         format: #"^(?<%@>(\w+([-.+\w]*\w)?)|(\*))\/(?<%@>(\w+([-.+\w]*\w)?)|(\*))(;\s?q=\d(.\d)?)?$"#,
         typeCaptureGroupName, subtypeCaptureGroupName
      )
      guard let regex = try? NSRegularExpression(pattern: pattern) else {
         assertionFailure("Can't create regular expression for MIME string")
         return nil
      }

      let mimeStringRange = NSRange(mimeString.startIndex..<mimeString.endIndex, in: mimeString)
      let matches = regex.matches(in: mimeString, range: mimeStringRange)
      guard let match = matches.first else {
         return nil
      }

      var captures: [String: String] = [:]
      for captureGroupName in [typeCaptureGroupName, subtypeCaptureGroupName] {
         let captureGroupNSRange = match.range(withName: captureGroupName)
         if let captureGroupRange = Range(captureGroupNSRange, in: mimeString) {
            let captureGroupValue = String(mimeString[captureGroupRange])
            captures[captureGroupName] = captureGroupValue
         }
      }
      guard
         let type = captures[typeCaptureGroupName],
         let subtype = captures[subtypeCaptureGroupName]
      else {
         return nil
      }

      return MIME(type: type, subtype: subtype)
   }

   // MARK: - Matching

   func matches(_ mime: MIME) -> Bool {
      switch (mime.type, mime.subtype) {
         case (type, subtype), ("*", subtype), (type, "*"), ("*", "*"):
            return true
         default:
            return false
      }
   }

   // MARK: - CustomStringConvertible

   var description: String {
      type + "/" + subtype
   }
}
