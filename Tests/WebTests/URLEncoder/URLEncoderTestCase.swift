//
//  URLEncoderTestCase.swift
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

class URLEncoderTestCase: XCTestCase {
   func test_urlEncoder_encodesBool_usingLiteralEncoding() throws {
      let encoder = URLEncoder(boolEncoding: LiteralURLEncoderBoolEncoding())
      let value = try encoder.encode(["bool": true])
      XCTAssertEqual(value, "bool=true")
   }

   func test_urlEncoder_encodesBool_usingNumericEncoding() throws {
      let encoder = URLEncoder(boolEncoding: NumericURLEncoderBoolEncoding())
      let value = try encoder.encode(["bool": true])
      XCTAssertEqual(value, "bool=1")
   }

   func test_urlEncoder_encodesNumberWithBool_usingLiteralEncoding() throws {
      let encoder = URLEncoder(boolEncoding: LiteralURLEncoderBoolEncoding())
      let value = try encoder.encode(["bool": NSNumber(value: true)])
      XCTAssertEqual(value, "bool=true")
   }

   func test_urlEncoder_encodesNumberWithBool_usingNumericEncoding() throws {
      let encoder = URLEncoder(boolEncoding: NumericURLEncoderBoolEncoding())
      let value = try encoder.encode(["bool": NSNumber(value: true)])
      XCTAssertEqual(value, "bool=1")
   }

   func test_urlEncoder_encodesArrayKey_usingBracketsEncoding() throws {
      let encoder = URLEncoder(arrayKeyEncoding: BracketsURLEncoderArrayKeyEncoding())
      let value = try encoder.encode(["array": [42]])
      XCTAssertEqual(value, "array%5B%5D=42")
   }

   func test_urlEncoder_encodesArrayKey_usingNoBracketsEncoding() throws {
      let encoder = URLEncoder(arrayKeyEncoding: NoBracketsURLEncoderArrayKeyEncoding())
      let value = try encoder.encode(["array": [42]])
      XCTAssertEqual(value, "array=42")
   }

   func test_urlEncoder_encodesValues_usingPercentEncoding() throws {
      let encoder = URLEncoder()
      let value = try encoder.encode(["greeting": "hello world"])
      XCTAssertEqual(value, "greeting=hello%20world")
   }

   func test_urlEncoder_encodesDictionaryValue() throws {
      let encoder = URLEncoder()
      let value = try encoder.encode(["dict": ["value": 42]])

      XCTAssertEqual(value, "dict%5Bvalue%5D=42")
   }

   func test_urlEncoder_encodesParametersInTheSameOrder() throws {
      let encoder = URLEncoder()
      let firstValue = try encoder.encode(["foo": "bar", "baz": 42])
      let secondValue = try encoder.encode(["baz": 42, "foo": "bar"])
      XCTAssertEqual(firstValue, secondValue)
   }
}
