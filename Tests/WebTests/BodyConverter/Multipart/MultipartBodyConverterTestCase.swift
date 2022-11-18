//
//  MultipartBodyConverterTestCase.swift
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

class MultipartBodyConverterTestCase: XCTestCase {
   private let outerBoundary = "123456"
   private let innerBoundary = "abcdef"

   private let outerName1 = "outerName1"
   private let outerName2 = "outerName2"

   private let innerName1 = "innerName1"
   private let innerName2 = "innerName2"

   private let contentType = "application/octet-stream"

   private let outerBody1 = Data([0x31, 0x32, 0x33])

   private let innerBody1 = Data([0x34, 0x35, 0x36])
   private let innerBody2 = Data([0x37, 0x38, 0x39])

   // MARK: - Test Cases

   func test_converter_returnsCorrectBody() throws {
      let converter = MultipartBodyConverter(
         contentTypeKind: .formData,
         boundary: outerBoundary,
         addsLineBreaks: true
      )
      let parts = try makeBodyParts()
      let body = try converter.convert(parts)
      let expectedBody = makeExpectedBody()
      XCTAssertEqual(converter.contentType, "multipart/form-data; boundary=\(outerBoundary)")
      XCTAssertEqual(body, expectedBody)
   }

   // MARK: - Factory

   private func makeBodyParts() throws -> [FormData] {
      let dataBodyConverter = DataBodyConverter(contentType: contentType)

      let innerPart1 = try FormData(
         name: innerName1,
         body: innerBody1,
         converter: dataBodyConverter
      )
      let innerPart2 = try FormData(
         name: innerName2,
         body: innerBody2,
         converter: dataBodyConverter
      )

      let outerPart1 = try FormData(
         name: outerName1,
         body: outerBody1,
         converter: dataBodyConverter
      )
      let outerPart2 = try FormData(
         name: outerName2,
         body: [innerPart1, innerPart2],
         converter: MultipartBodyConverter(
            contentTypeKind: .mixed,
            boundary: innerBoundary,
            addsLineBreaks: false
         )
      )

      return [outerPart1, outerPart2]
   }

   private func makeExpectedBody() -> Data {
      var data = Data()

      data.append("\r\n")

      data.append("--\(outerBoundary)\r\n")
      data.append(makeContentDispositionHeader(name: outerName1))
      data.append(makeContentTypeHeader(contentType: contentType))
      data.append("\r\n")
      data.append(outerBody1)
      data.append("\r\n")

      data.append("--\(outerBoundary)\r\n")
      data.append(makeContentDispositionHeader(name: outerName2))
      data.append(makeContentTypeHeader(contentType: "multipart/mixed; boundary=\(innerBoundary)"))
      data.append("\r\n")

      data.append("--\(innerBoundary)\r\n")
      data.append(makeContentDispositionHeader(name: innerName1))
      data.append(makeContentTypeHeader(contentType: contentType))
      data.append("\r\n")
      data.append(innerBody1)
      data.append("\r\n")

      data.append("--\(innerBoundary)\r\n")
      data.append(makeContentDispositionHeader(name: innerName2))
      data.append(makeContentTypeHeader(contentType: contentType))
      data.append("\r\n")
      data.append(innerBody2)
      data.append("\r\n")

      data.append("--\(innerBoundary)--\r\n")
      data.append("--\(outerBoundary)--\r\n")

      return data
   }

   private func makeContentDispositionHeader(name: String) -> String {
      "Content-Disposition: form-data; name=\"\(name)\"\r\n"
   }

   private func makeContentTypeHeader(contentType: String) -> String {
      "Content-Type: \(contentType)\r\n"
   }
}
