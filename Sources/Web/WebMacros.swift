//
//  WebMacros.swift
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

/// Generates conformance to a ``Request`` protocol and uses *CONNECT* HTTP method.
///
/// - Parameters:
///   - SuccessObject: A type of object which will be returned if network call will succeed with
///                    successful status code.
///   - ErrorObject: A type of error object which will be thrown if network call will succeed with
///                  unsuccessful status code. Type of `ErrorObject` MUST conform to `Error`.
///   - path: A path string that is used to construct URL.
@attached(
   extension,
   conformances: Request,
   names:
      named(SuccessObject),
      named(ErrorObject),
      named(successObjectResponseConverter),
      named(errorObjectResponseConverter),
      named(toURLRequest(with:))
)
public macro CONNECT<SuccessObject, ErrorObject>(_ path: String) = #externalMacro(
   module: "WebMacros",
   type: "RequestMacro"
)

/// Generates conformance to a ``Request`` protocol and uses *DELETE* HTTP method.
///
/// - Parameters:
///   - SuccessObject: A type of object which will be returned if network call will succeed with
///                    successful status code.
///   - ErrorObject: A type of error object which will be thrown if network call will succeed with
///                  unsuccessful status code. Type of `ErrorObject` MUST conform to `Error`.
///   - path: A path string that is used to construct URL. It may have variables that begin with
///           colon, e.g. `path/:to/resource`.
@attached(
   extension,
   conformances: Request,
   names:
      named(SuccessObject),
      named(ErrorObject),
      named(successObjectResponseConverter),
      named(errorObjectResponseConverter),
      named(toURLRequest(with:))
)
public macro DELETE<SuccessObject, ErrorObject>(_ path: String) = #externalMacro(
   module: "WebMacros",
   type: "RequestMacro"
)

/// Generates conformance to a ``Request`` protocol and uses *GET* HTTP method.
///
/// - Parameters:
///   - SuccessObject: A type of object which will be returned if network call will succeed with
///                    successful status code.
///   - ErrorObject: A type of error object which will be thrown if network call will succeed with
///                  unsuccessful status code. Type of `ErrorObject` MUST conform to `Error`.
///   - path: A path string that is used to construct URL. It may have variables that begin with
///           colon, e.g. `path/:to/resource`.
@attached(
   extension,
   conformances: Request,
   names:
      named(SuccessObject),
      named(ErrorObject),
      named(successObjectResponseConverter),
      named(errorObjectResponseConverter),
      named(toURLRequest(with:))
)
public macro GET<SuccessObject, ErrorObject>(_ path: String) = #externalMacro(
   module: "WebMacros",
   type: "RequestMacro"
)

/// Generates conformance to a ``Request`` protocol and uses *HEAD* HTTP method.
///
/// - Parameters:
///   - SuccessObject: A type of object which will be returned if network call will succeed with
///                    successful status code.
///   - ErrorObject: A type of error object which will be thrown if network call will succeed with
///                  unsuccessful status code. Type of `ErrorObject` MUST conform to `Error`.
///   - path: A path string that is used to construct URL. It may have variables that begin with
///           colon, e.g. `path/:to/resource`.
@attached(
   extension,
   conformances: Request,
   names:
      named(SuccessObject),
      named(ErrorObject),
      named(successObjectResponseConverter),
      named(errorObjectResponseConverter),
      named(toURLRequest(with:))
)
public macro HEAD<SuccessObject, ErrorObject>(_ path: String) = #externalMacro(
   module: "WebMacros",
   type: "RequestMacro"
)

/// Generates conformance to a ``Request`` protocol and uses *OPTIONS* HTTP method.
///
/// - Parameters:
///   - SuccessObject: A type of object which will be returned if network call will succeed with
///                    successful status code.
///   - ErrorObject: A type of error object which will be thrown if network call will succeed with
///                  unsuccessful status code. Type of `ErrorObject` MUST conform to `Error`.
///   - path: A path string that is used to construct URL. It may have variables that begin with
///           colon, e.g. `path/:to/resource`.
@attached(
   extension,
   conformances: Request,
   names:
      named(SuccessObject),
      named(ErrorObject),
      named(successObjectResponseConverter),
      named(errorObjectResponseConverter),
      named(toURLRequest(with:))
)
public macro OPTIONS<SuccessObject, ErrorObject>(_ path: String) = #externalMacro(
   module: "WebMacros",
   type: "RequestMacro"
)

/// Generates conformance to a ``Request`` protocol and uses *PATCH* HTTP method.
///
/// - Parameters:
///   - SuccessObject: A type of object which will be returned if network call will succeed with
///                    successful status code.
///   - ErrorObject: A type of error object which will be thrown if network call will succeed with
///                  unsuccessful status code. Type of `ErrorObject` MUST conform to `Error`.
///   - path: A path string that is used to construct URL. It may have variables that begin with
///           colon, e.g. `path/:to/resource`.
@attached(
   extension,
   conformances: Request,
   names:
      named(SuccessObject),
      named(ErrorObject),
      named(successObjectResponseConverter),
      named(errorObjectResponseConverter),
      named(toURLRequest(with:))
)
public macro PATCH<SuccessObject, ErrorObject>(_ path: String) = #externalMacro(
   module: "WebMacros",
   type: "RequestMacro"
)

/// Generates conformance to a ``Request`` protocol and uses *POST* HTTP method.
///
/// - Parameters:
///   - SuccessObject: A type of object which will be returned if network call will succeed with
///                    successful status code.
///   - ErrorObject: A type of error object which will be thrown if network call will succeed with
///                  unsuccessful status code. Type of `ErrorObject` MUST conform to `Error`.
///   - path: A path string that is used to construct URL. It may have variables that begin with
///           colon, e.g. `path/:to/resource`.
@attached(
   extension,
   conformances: Request,
   names:
      named(SuccessObject),
      named(ErrorObject),
      named(successObjectResponseConverter),
      named(errorObjectResponseConverter),
      named(toURLRequest(with:))
)
public macro POST<SuccessObject, ErrorObject>(_ path: String) = #externalMacro(
   module: "WebMacros",
   type: "RequestMacro"
)

/// Generates conformance to a ``Request`` protocol and uses *PUT* HTTP method.
///
/// - Parameters:
///   - SuccessObject: A type of object which will be returned if network call will succeed with
///                    successful status code.
///   - ErrorObject: A type of error object which will be thrown if network call will succeed with
///                  unsuccessful status code. Type of `ErrorObject` MUST conform to `Error`.
///   - path: A path string that is used to construct URL. It may have variables that begin with
///           colon, e.g. `path/:to/resource`.
@attached(
   extension,
   conformances: Request,
   names:
      named(SuccessObject),
      named(ErrorObject),
      named(successObjectResponseConverter),
      named(errorObjectResponseConverter),
      named(toURLRequest(with:))
)
public macro PUT<SuccessObject, ErrorObject>(_ path: String) = #externalMacro(
   module: "WebMacros",
   type: "RequestMacro"
)

/// Generates conformance to a ``Request`` protocol and uses *TRACE* HTTP method.
///
/// - Parameters:
///   - SuccessObject: A type of object which will be returned if network call will succeed with
///                    successful status code.
///   - ErrorObject: A type of error object which will be thrown if network call will succeed with
///                  unsuccessful status code. Type of `ErrorObject` MUST conform to `Error`.
///   - path: A path string that is used to construct URL. It may have variables that begin with
///           colon, e.g. `path/:to/resource`.
@attached(
   extension,
   conformances: Request,
   names:
      named(SuccessObject),
      named(ErrorObject),
      named(successObjectResponseConverter),
      named(errorObjectResponseConverter),
      named(toURLRequest(with:))
)
public macro TRACE<SuccessObject, ErrorObject>(_ path: String) = #externalMacro(
   module: "WebMacros",
   type: "RequestMacro"
)

// MARK: -

/// Marks a variable that should be substituted to path string in *GET/POST/...* macro.
///
/// Variable this macro is attached SHOULD NOT be optional and name of variable MUST match path
/// segment name in path string. Macro may be attached only to variables.
@attached(peer)
public macro Path() = #externalMacro(module: "WebMacros", type: "PathMacro")

/// Marks a variable that should be substituted to path string in *GET/POST/...* macro.
///
/// Variable this macro is attached SHOULD NOT be optional. Macro may be attached only to variables.
///
/// - Parameters:
///   - segmentName: Name of segment in path string.
@attached(peer)
public macro Path(_ segmentName: String) = #externalMacro(module: "WebMacros", type: "PathMacro")

/// Marks a variable that should be used as query item in URL string.
///
/// Name of variable is used as query item name. Macro may be attached only to variables.
@attached(peer)
public macro Query() = #externalMacro(module: "WebMacros", type: "QueryMacro")

/// Marks a variable that should be used as query item in URL string.
///
/// Macro may be attached only to variables.
///
/// - Parameters:
///   - queryItemName: Name of query item that the variable represents.
@attached(peer)
public macro Query(_ queryItemName: String) = #externalMacro(module: "WebMacros", type: "QueryMacro")

/// Marks a variable that should be used as header of request.
///
/// Macro may be attached only to variables that have a type of `String`. Name of variable is used
/// as header's name.
@attached(peer)
public macro Header() = #externalMacro(module: "WebMacros", type: "HeaderMacro")

/// Marks a variable that should be used as header of request.
///
/// Macro may be attached only to variables that have a type of `String`.
///
/// - Parameters:
///   - headerName: Header's name of request.
@attached(peer)
public macro Header(_ headerName: String) = #externalMacro(module: "WebMacros", type: "HeaderMacro")

/// Defines headers of a request with constant values.
///
/// Macro may be attached only to class or struct declarations.
///
/// - Parameters:
///   - headers: A set of headers.
@attached(peer)
public macro Headers(_ headers: [String: String]) = #externalMacro(
   module: "WebMacros",
   type: "HeadersMacro"
)

/// Marks a variable that should be used as body of a request.
///
/// Macro may be attached only to variables. Each request MUST have the only variable marked with
/// `@Body`.
@attached(peer)
public macro Body() = #externalMacro(module: "WebMacros", type: "BodyMacro")

/// Marks a variable that should be used as body of a request.
///
/// Macro may be attached only to variables. Each request MUST have the only variable marked with
/// `@Body`. 
///
/// - Parameters:
///   - converter: Converter's initialization code that's used to create converter.
@attached(peer)
public macro Body(_ converter: (any BodyConverter)) = #externalMacro(
   module: "WebMacros",
   type: "BodyMacro"
)

/// Generates conformance of request to ``NonAuthorizableRequest`` protocol.
@attached(extension, conformances: NonAuthorizableRequest)
public macro SkippedAuthorization() = #externalMacro(
   module: "WebMacros",
   type: "SkippedAuthorizationMacro"
)
