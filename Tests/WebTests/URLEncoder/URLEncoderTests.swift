//
//  URLEncoderTests.swift
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

import Foundation
import Testing

@Suite("URLEncoder")
struct URLEncoderTests {
   let encoder = URLEncoder()

   // MARK: - Tests

   @Test("Encodes bool as literal")
   func testEncodeBool() throws {
      let value = try encoder.encode(["bool": true])
      #expect(value == "bool=true")
   }

   @Test("Encodes number with bool as literal")
   func encodeNumberWithBool() throws {
      let value = try encoder.encode(["bool": NSNumber(value: true)])
      #expect(value == "bool=true")
   }

   @Test("Encodes array key with brackets")
   func encodeArray() throws {
      let value = try encoder.encode(["array": [42]])
      #expect(value == "array%5B%5D=42")
   }

   @Test("Encodes by using percent escaping")
   func encodePercentEscapedValues() throws {
      let value = try encoder.encode(["greeting": "hello world"])
      #expect(value == "greeting=hello%20world")
   }

   @Test("Encodes dictionary")
   func encodeDictionary() throws {
      let value = try encoder.encode(["dict": ["value": 42]])
      #expect(value == "dict%5Bvalue%5D=42")
   }

   @Test("Encodes in the same order")
   func encodeTwoTimes() throws {
      let firstValue = try encoder.encode(["foo": "bar", "baz": 42])
      let secondValue = try encoder.encode(["baz": 42, "foo": "bar"])
      #expect(firstValue == secondValue)
   }
}
