//
//  MIMETests.swift
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

@testable
import Web

import Testing

@Suite("MIME")
struct MIMETests {
   @Test("Converted to string correctly")
   func convertToString() {
      let mime = MIME(type: "application", subtype: "json")
      #expect(mime.description == "application/json")
   }

   @Test("Created from MIME string", arguments: [
      ("application/json", "application", "json"),
      ("application/vnd.google-earth.kml+xml", "application", "vnd.google-earth.kml+xml"),
      ("*/*", "*", "*"),
      ("application/json; q=1.0", "application", "json")
   ])
   func createFromString(mimeString: String, type: String, subtype: String) throws {
      let mime = try #require(MIME.parseMIMEString(mimeString))
      #expect(mime.type == type)
      #expect(mime.subtype == subtype)
   }

   @Test("Not created from incorrect string", arguments: [
      "",
      "          ",
      "application/json/xml",
      "application-/json",
      "application/json-",
      "-application/json",
      "application/+json"
   ])
   func createFromIncorrectString(mimeString: String) {
      let mime = MIME.parseMIMEString(mimeString)
      #expect(mime == nil)
   }

   @Test("Matches", arguments: [
      (MIME(type: "application", subtype: "json"), MIME(type: "application", subtype: "json")),
      (MIME(type: "*", subtype: "json"), MIME(type: "application", subtype: "json")),
      (MIME(type: "application", subtype: "*"), MIME(type: "application", subtype: "json")),
      (MIME(type: "*", subtype: "*"), MIME(type: "application", subtype: "json"))
   ])
   func matches(patternMIME: MIME, comparableMIME: MIME) {
      #expect(comparableMIME.matches(patternMIME))
   }

   @Test("Not matches", arguments: [
      (MIME(type: "application", subtype: "json"), MIME(type: "application", subtype: "xml")),
      (MIME(type: "application", subtype: "json"), MIME(type: "*", subtype: "*"))
   ])
   func notMatches(patternMIME: MIME, comparableMIME: MIME) {
      #expect(!comparableMIME.matches(patternMIME))
   }
}
