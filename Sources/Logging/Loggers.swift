//
//  Loggers.swift
//
//  Copyright © 2025 Aleksei Zaikin.
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

import OSLog

enum Loggers: @unchecked Sendable {
   nonisolated(unsafe)
   private static var loggers: [String: Logger] = [:]
   private static let lock = NSLock()

   static func logger(forSubsystem subsystem: Subsystem, category: Category) -> Logger {
      lock.lock()
      defer {
         lock.unlock()
      }

      let key = "\(subsystem.rawValue)_\(category.rawValue)"

      if let logger = loggers[key] {
         return logger
      }

      guard let env = ProcessInfo.processInfo.environment["NETWORK_LOGGING"] else {
         let logger = Logger(.disabled)
         loggers[key] = logger
         return logger
      }

      let log = switch (env, category) {
         case let ("ON", category) where category != .requestCURL,
              let ("ON CURL", category) where category != .request:
            OSLog(subsystem: "InstrumentBox.Network.WebCore", category: category.rawValue)
         default:
            OSLog.disabled
      }

      let logger = Logger(log)
      loggers[key] = logger
      return logger
   }
}

extension Loggers {
   enum Subsystem: String {
      case webCore = "InstrumentBox.Network.WebCore"
      case webStub = "InstrumentBox.Network.WebStub"
   }
}

extension Loggers {
   enum Category: String {
      case request = "Request"
      case requestCURL = "Request cURL"
      case response = "Response"
   }
}
