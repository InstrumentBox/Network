// swift-tools-version:5.10

//
//  Package.swift
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

import CompilerPluginSupport
import PackageDescription

let package = Package(
   name: "Network",
   platforms: [
      .iOS(.v13),
      .macOS(.v10_15),
      .macCatalyst(.v13),
      .tvOS(.v13),
      .watchOS(.v6)
   ],
   products: [
      .library(name: "Web", targets: ["Web"]),
      .library(name: "WebCore", targets: ["WebCore"]),
      .library(name: "WebStub", targets: ["WebStub"])
   ],
   dependencies: [
      .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.0")
   ],
   targets: [
      .target(name: "Web", dependencies: ["WebMacros"]),
      .macro(
         name: "WebMacros",
         dependencies: [
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
         ]
      ),
      .testTarget(
         name: "WebTests",
         dependencies: [
            "Web",
            "WebMacros",
            "NetworkTestUtils",
            .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
         ]
      ),

      .target(name: "WebCore", dependencies: ["Web"]),
      .testTarget(name: "WebCoreTests", dependencies: ["Web", "WebCore", "NetworkTestUtils"]),

      .target(name: "WebStub", dependencies: ["Web"]),
      .testTarget(
         name: "WebStubTests",
         dependencies: ["Web", "WebCore", "WebStub", "NetworkTestUtils"],
         resources: [
            .process("Reader/Resources/Data.txt"),
            .process("ResponseParser/Resources/Full.response"),
            .process("ResponseParser/Resources/EmptyBody.response"),
            .process("ResponseParser/Resources/NoHeaders.response"),
            .process("ResponseParser/Resources/NoStatusCode.response"),
            .process("ResponseParser/Resources/IncorrectHeader.response"),
            .process("ResponseParser/Resources/HeadersAsBody.response"),
            .process("ResponseParser/Resources/JustStatusCode.response")
         ]
      ),

      .target(
         name: "NetworkTestUtils",
         dependencies: [
            "Web",
            "WebCore"
         ],
         path: "Tests/NetworkTestUtils",
         resources: [
            .process("Resources/APIError.response"),
            .process("Resources/TestObject.response"),
            .process("Resources/XML.response")
         ],
         packageAccess: true
      )
   ]
)
