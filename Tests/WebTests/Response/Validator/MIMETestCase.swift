//
//  MIMETestCase.swift
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

@testable
import Web

import XCTest

class MIMETestCase: XCTestCase {
   func test_mime_isConvertedToStringCorrectly() {
      let mime = MIME(type: "application", subtype: "json")
      XCTAssertEqual(mime.description, "application/json")
   }
   
   func test_mime_isCreatedFromMIMEString() throws {
      let type = "application"
      let subtype = "json"
      let mime = try XCTUnwrap(MIME.make(mimeString: type + "/" + subtype))
      XCTAssertEqual(mime.type, type)
      XCTAssertEqual(mime.subtype, subtype)
   }

   func test_mime_isCreatedFromMIMEString_withSymbols() throws {
      let type = "application"
      let subtype = "vnd.google-earth.kml+xml"
      let mime = try XCTUnwrap(MIME.make(mimeString: type + "/" + subtype))
      XCTAssertEqual(mime.type, type)
      XCTAssertEqual(mime.subtype, subtype)
   }

   func test_mime_isCreatedFromWildcardMIMEString() throws {
      let type = "*"
      let subtype = "*"
      let mime = try XCTUnwrap(MIME.make(mimeString: type + "/" + subtype))
      XCTAssertEqual(mime.type, type)
      XCTAssertEqual(mime.subtype, subtype)
   }

   func test_mime_isCreatedFromMIMEString_withQFactor() throws {
      let type = "application"
      let subtype = "json"
      let mime = try XCTUnwrap(MIME.make(mimeString: type + "/" + subtype + "; q=1.0"))
      XCTAssertEqual(mime.type, type)
      XCTAssertEqual(mime.subtype, subtype)
   }

   func test_mime_isNotCreatedFromEmptyMIMEString() {
      let mime = MIME.make(mimeString: "")
      XCTAssertNil(mime)
   }

   func test_mime_isNotCreatedFromSpacesMIMEString() {
      let mime = MIME.make(mimeString: "     ")
      XCTAssertNil(mime)
   }

   func test_mime_isNotCreatedFromMIMEString() {
      let mime = MIME.make(mimeString: "application/json/xml")
      XCTAssertNil(mime)
   }

   func test_mime_isNotCreatedFromMIMEString_ifTypeEndsWithSymbol() {
      let mime = MIME.make(mimeString: "application-/json")
      XCTAssertNil(mime)
   }

   func test_mime_isNotCreatedFromMIMEString_ifSubtypeEndsWithSymbol() {
      let mime = MIME.make(mimeString: "application/json-")
      XCTAssertNil(mime)
   }

   func test_mime_isNotCreatedFromMIMEString_ifTypeBeginsWithSymbol() {
      let mime = MIME.make(mimeString: "-application/json")
      XCTAssertNil(mime)
   }

   func test_mime_isNotCreatedFromMIMEString_ifSubtypeBeginsWithSymbol() {
      let mime = MIME.make(mimeString: "application/+json")
      XCTAssertNil(mime)
   }

   func test_mimes_matches_ifSame() {
      let patternMIME = MIME(type: "application", subtype: "json")
      let comparableMIME = MIME(type: "application", subtype: "json")
      XCTAssertTrue(comparableMIME.matches(patternMIME))
   }

   func test_mimes_matches_ifPatternTypeIsWildcard() {
      let patternMIME = MIME(type: "*", subtype: "json")
      let comparableMIME = MIME(type: "application", subtype: "json")
      XCTAssertTrue(comparableMIME.matches(patternMIME))
   }

   func test_mimes_matches_ifPatternSubtypeIsWildcard() {
      let patternMIME = MIME(type: "application", subtype: "*")
      let comparableMIME = MIME(type: "application", subtype: "json")
      XCTAssertTrue(comparableMIME.matches(patternMIME))
   }

   func test_mimes_matches_ifPatternIsWildcard() {
      let patternMIME = MIME(type: "*", subtype: "*")
      let comparableMIME = MIME(type: "application", subtype: "json")
      XCTAssertTrue(comparableMIME.matches(patternMIME))
   }

   func test_mimes_notMatches_ifNotSame() {
      let patternMIME = MIME(type: "application", subtype: "json")
      let comparableMIME = MIME(type: "application", subtype: "xml")
      XCTAssertFalse(comparableMIME.matches(patternMIME))
   }

   func test_mimes_notMatches_ifComparableIsWildcard_andPatternIsNot() {
      let patternMIME = MIME(type: "application", subtype: "json")
      let comparableMIME = MIME(type: "*", subtype: "*")
      XCTAssertFalse(comparableMIME.matches(patternMIME))
   }
}
