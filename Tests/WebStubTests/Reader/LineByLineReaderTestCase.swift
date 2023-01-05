//
//  LineByLineReaderTestCase.swift
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
import WebStub

import XCTest

class LineByLineReaderTestCase: XCTestCase {
   func test_linewiseReader_readsFileLineByLine() throws {
      let fileURL = try XCTUnwrap(Bundle.module.url(forResource: "Data", withExtension: "txt"))
      let reader = try XCTUnwrap(LineByLineReader(fileURL: fileURL))
      var lines: [Data] = []
      while let line: Data = reader.readLine() {
         lines.append(line)
      }
      XCTAssertEqual(lines, [Data([0x30]), Data([0x31]), Data([0x32]), Data([0x33])])
   }
}
