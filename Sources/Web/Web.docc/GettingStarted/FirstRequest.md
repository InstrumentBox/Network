# Make Your First Request

Read how to make requests and receive responses using the *Web* library.

## Describe a Request

Let's say you need to fetch `SomeObject` by its ID.

```swift
import Web

struct SomeObjectRequest: Request { 
   let id: String
}
```

Each request must declare response converters for success and failure cases that will be used by a
web client.

```swift
struct SomeObjectRequest: Request { 
   ...

   var successObjectResponseConverter: any ResponseConverter<SomeObject> {
      JSONDecoderResponseConverter()
   }

   var errorObjectResponseConverter: any ResponseConverter<APIError> {
      JSONDecoderResponseConverter()
   }
}
```

Next, you need to describe how `SomeObjectRequest` is converted to `URLRequest`.

```swift
struct SomeObjectRequest: Request { 
   ...

   func toURLRequest(with baseURL: URL?) throws -> URLRequest {
      let url = try URL(path: "some-objects/\(id)", baseURL: baseURL)
      return URLRequest(url: url, method: .get)
   }
}
```

## Simplify Request Declaration

If you use `JSONDecoder` or any other converter for each request, you can simplify request 
description by declaring request protocol in your app.

```swift
protocol MyAppRequest: Request where SuccessObject: Decodable {
   var decoder: JSONDecoder { get }
}

extension MyAppRequest {
   var decoder: JSONDecoder {
      JSONDecoder()
   }

   var successObjectResponseConverter: any ResponseConverter<SuccessObject> {
      JSONDecoderResponseConverter(decoder: JSONDecoder())
   }
   
   var errorObjectResponseConverter: any ResponseConverter<APIError> {
      JSONDecoderResponseConverter()
   }
}
```

Then `SomeObjectRequest` can be described as following:

```swift
struct SomeObjectRequest: MyAppRequest {
   typealias SuccessObject = SomeObject

   let id: String
   
   func toURLRequest(with baseURL: URL?) throws -> URLRequest {
      let url = try URL(path: "some-objects/\(id)", baseURL: baseURL)
      return URLRequest(url: url, method: .get)
   }
}
```

## Create a Web Client

To send a request you need to create an instance of web client.

```swift
import WebCore

let configuration: URLSessionWebClientConfiguration = .default
configuration.baseURL = URL(string: "https://api.myservice.com/v1/")
let webClient: WebClient = URLSessionWebClient(configuration: configuration)
```

Important thing here is that if you use `URL(path:baseURL) throws` provided by this library,
you probably need to end baseURL with `/` and path shouldn't begin with `/` as this initializer uses 
relative URL mechanism

## Send a Request

Finally, you can create and execute request on the web client.

```swift
do {
   let request = SomeObjectRequest(id: requiredID)
   let someObject = try await webClient.execute(request)
   use(someObject)
} catch let error as APIError {
   react(to: error)
} catch error {
   doSomethingElse(with: error)
}
```

## Cancel a Request

If you need to cancel requests, you can use `Task` API provided by Swift concurrency.

```swift
let task = Task {
   let request = SomeObjectRequest(id: requiredID)
   return try await webClient.execute(request)
}
self.task = task

do {
   let someObject = try await task.value
   use(someObject)
} catch {
   ...
}

// Later somewhere in code

self.task?.cancel()
```

That's it!
