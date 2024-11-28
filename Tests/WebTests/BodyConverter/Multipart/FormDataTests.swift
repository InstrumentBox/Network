//
//  FormDataTests.swift
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

@Suite("Form data")
struct FormDataTests {
   private let partName = "some_data"
   private let fileName = "some_file"
   private let contentType = "application/octet-stream"
   private let body = Data([0x01, 0x02, 0x03])

   // MARK: - Tests

   @Test("Converted without filename")
   func convertWithoutFilename() throws {
      let expectedData = makeExpectedData(withFileName: false, withHeaders: false)
      let formData = try makeFormData(withFileName: false, withHeaders: false)
      let partData = try formData.toBodyPartData()
      #expect(partData == expectedData)
   }

   @Test("Converted with filename")
   func convertWithFilename() throws {
      let expectedData = makeExpectedData(withFileName: true, withHeaders: false)
      let formData = try makeFormData(withFileName: true, withHeaders: false)
      let partData = try formData.toBodyPartData()
      #expect(partData == expectedData)
   }

   @Test("Converted with headers")
   func convertWithHeaders() throws {
      let expectedData = makeExpectedData(withFileName: false, withHeaders: true)
      let formData = try makeFormData(withFileName: false, withHeaders: true)
      let partData = try formData.toBodyPartData()
      #expect(partData == expectedData)
   }

   // MARK: - Factory

   private func makeFormData(withFileName: Bool, withHeaders: Bool) throws -> FormData<Data> {
      let converter = DataBodyConverter(contentType: contentType)
      return try FormData(
         name: partName,
         fileName: withFileName ? fileName : nil,
         headers: withHeaders ? ["Content-Language": "en", "Content-Length": "\(body.count)"] : nil,
         body: body,
         converter: converter
      )
   }

   private func makeExpectedData(withFileName: Bool, withHeaders: Bool) -> Data {
      var data = Data()
      data.append(#"Content-Disposition: form-data; name="\#(partName)""#)
      if withFileName {
         data.append(#"; filename="\#(fileName)""#)
      }
      data.append("\r\n")
      data.append("Content-Type: \(contentType)\r\n")
      if withHeaders {
         data.append("Content-Language: en")
         data.append("\r\n")
         data.append("Content-Length: \(body.count)")
         data.append("\r\n")
      }
      data.append("\r\n")
      data.append(body)
      return data
   }
}
