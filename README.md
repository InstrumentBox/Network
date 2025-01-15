# Network

[![Language: Swift 6.0](https://img.shields.io/badge/Language-Swift%206.0-F48041.svg?style=flat)](https://developer.apple.com/swift)
![Platforms: iOS | watchOS | macCatalyst | macOS | tvOS | visionOS](https://img.shields.io/badge/Platforms-iOS%20%7C%20watchOS%20%7C%20macCatalyst%20%7C%20macOS%20%7C%20tvOS%20%7C%20visionOS-blue.svg?style=flat)
[![SPM: Compatible](https://img.shields.io/badge/SPM-Compatible-4BC51D.svg?style=flat)](https://swift.org/package-manager/)
[![License: MIT](http://img.shields.io/badge/License-MIT-lightgray.svg?style=flat)](https://github.com/InstrumentBox/Network/blob/main/LICENSE)

*Network* is a Swift package that provides you with set of network libraries built on top of new 
concurrency model introduced in Swift 5.5.

## Web

*Web* is a library that provides abstractions to build service layer, e.g. Request, WebClient, 
Converters, etc.

### Features

- [x] [Well documented](https://instrument-box-network-web-docs.netlify.app/documentation/web/)
- [x] Customizable
- [x] Response validation
- [x] Multipart requests

## WebCore

*WebCore* is a library that provides full-featured implementation of *WebClient*.

### Feartures

- [x] [Well documented](https://instrument-box-network-web-core-docs.netlify.app/documentation/webcore/)
- [x] Customizable
- [x] Request authorization
- [x] Certificate and public key pinning
- [x] 2FA support

## WebStub

*WebStub* is a library that provides an implementation of web client that allows you to stub responses.

### Features

- [x] [Well documented](https://instrument-box-network-web-stub-docs.netlify.app/documentation/webstub/)
- [x] Customizable
- [x] Chain of responses
- [x] Stubbed and server responses combination
- [x] Latency simulation
