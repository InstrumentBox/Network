//
//  ArrayKeyEncodingTestCase.swift
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

import Web
import XCTest

class ArrayKeyEncodingTestCase: XCTestCase {
   func test_bracketsArrayKeyEncoding_encodesKey() {
      let encoding = URLEncoder.BracketsArrayKeyEncoding()
      let encoded = encoding.encode("key")
      XCTAssertEqual(encoded, "key[]")
   }

   func test_noBracketsArrayKeyEncoding_encodesKey() {
      let encoding = URLEncoder.NoBracketsArrayKeyEncoding()
      let encoded = encoding.encode("key")
      XCTAssertEqual(encoded, "key")
   }

   func test_numericBoolEncoding_encodesTrueAs1() {
      let encoding = URLEncoder.NumericBoolEncoding()
      let encoded = encoding.encode(true)
      XCTAssertEqual(encoded, "1")
   }

   func test_numericBoolEncoding_encodesFalseAs0() {
      let encoding = URLEncoder.NumericBoolEncoding()
      let encoded = encoding.encode(false)
      XCTAssertEqual(encoded, "0")
   }

   func test_literalBoolEncoding_encodesTrueAsTrue() {
      let encoding = URLEncoder.LiteralBoolEncoding()
      let encoded = encoding.encode(true)
      XCTAssertEqual(encoded, "true")
   }

   func test_literalBoolEncoding_encodesFalseAsFalse() {
      let encoding = URLEncoder.LiteralBoolEncoding()
      let encoded = encoding.encode(false)
      XCTAssertEqual(encoded, "false")
   }
}
