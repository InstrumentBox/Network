# Getting Started

Read how to use `StubbedWebClient` in your test environment.

## Overview

``StubbedWebClient`` is an implementation of `WebClient` protocol that allows you to stub responses 
to your requests.

## Create a web client and receive stubbed response 

```swift
import WebStub

let configuration = StubbedWebClientConfiguration()
let webClient = StubbedWebClient(configuration: configuration)
```

For now, if you will try to send request, web client throws error that is has no registered 
responses.  To solve this, you need to register a response. Let's say you need to do it for 
`SomeObjectRequest`

```swift
let chain = await client.stubChain(for: SomeObjectRequest.self)
await chain.registerResponse(at: <URL to file with a response>)
```

Now you need to add a response file. Response file is a file with the following format:

```
200
Content-Type: application/json; charset=utf-8

{
   "this": "Value",
   "that"": 42
}
```

As you can see, this format is very similar to an HTTP message. The first line MUST contain status 
code. The next lines MAY contains headers. Each header MUST be on a separate line. Response body 
MUST be preceded by empty line. If empty line is right after status code, next headers will be 
considered as response's body.

Now you can send request and receive stubbed response

```swift
let object = try await client.execute(SomeObjectRequest())
```

That's it.
