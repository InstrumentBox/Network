//
//  LineByLineReader.swift
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

import Foundation

class LineByLineReader {
   private lazy var buffer = Data(capacity: chunkSize)
   private var isAtEOF = false

   private let chunkSize = 40

   private let lineDelimiterData: Data
   private let fileHandle: FileHandle

   // MARK: - Init

   init?(fileURL: URL) {
      guard let lineDelimiterData = "\n".data(using: .utf8) else {
         return nil
      }

      guard let fileHandle = try? FileHandle(forReadingFrom: fileURL) else {
         return nil
      }

      self.lineDelimiterData = lineDelimiterData
      self.fileHandle = fileHandle
   }

   deinit {
      try? fileHandle.close()
   }

   // MARK: - Reading

   func readLine() -> Data? {
      if isAtEOF {
         return nil
      }

      repeat {
         if let range = buffer.range(of: lineDelimiterData) {
            let subData = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
            buffer = buffer[range.upperBound..<buffer.endIndex]
            return subData
         } else {
            let tempData = fileHandle.readData(ofLength: chunkSize)
            if tempData.count == 0 {
               isAtEOF = true
               return (buffer.count > 0) ? buffer : nil
            }
            buffer.append(tempData)
         }
      } while true
   }
}
