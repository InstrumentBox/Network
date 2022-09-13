//
//  BodyPartTestCase.swift
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

class BodyPartTestCase: XCTestCase {
   private let partName = "some_data"
   private let fileName = "some_file"
   private let contentType = "application/octet-stream"
   private let body = Data([0x01, 0x02, 0x03])
   private let boundary = "123456"

   // MARK: - Test Cases

   func test_part_isConvertedCorrectly_withoutFileName() throws {
      let expectedData = makeExpectedData(withFileName: false)
      let part = try makeBodyPart(withFileName: false)
      let partData = try part.makeFormData(boundary: boundary)
      XCTAssertEqual(partData, expectedData)
   }

   func test_part_isConvertedCorrectly_withFileName() throws {
      let expectedData = makeExpectedData(withFileName: true)
      let part = try makeBodyPart(withFileName: true)
      let partData = try part.makeFormData(boundary: boundary)
      XCTAssertEqual(partData, expectedData)
   }

   // MARK: - Factory

   private func makeBodyPart(withFileName: Bool) throws -> BodyPart {
      let converter = DataBodyConverter(contentType: contentType)
      let part = try BodyPart(
         name: partName,
         fileName: withFileName ? fileName : nil,
         body: body,
         converter: converter
      )
      return part
   }

   private func makeExpectedData(withFileName: Bool) -> Data {
      var data = Data()
      data.append("--\(boundary)")
      data.append("\r\n")
      data.append(#"Content-Disposition: form-data; name="\#(partName)""#)
      if withFileName {
         data.append(#"; filename="\#(fileName)""#)
      }
      data.append("\r\n")
      data.append("Content-Type: \(contentType)\r\n")
      data.append("\r\n")
      data.append(body)
      data.append("\r\n")
      return data
   }
}
