# Take More Control

Read how to gain more control over stubbing responses.

## Overview

As you remember from <doc:GettingStarted>, you need to register responses in a chain for a request.
The chain allows you to use each stubbed response a given number of times and combine stubbed 
responses with responses from your server which may be useful e.g. in case of integration testing.

## How to make responses chain

```swift
let configuration = StubbedWebClient.Configuration()
configuration.fallbackWebClient = <web client>
let client = StubbedWebClient(configuration: configuration)

let chain = await client.stubChain(for: SomeObjectRequest.self)
await chain.registerResponse(at: <URL to file with a successful response>, usageCount: 3)
await chain.registerResponse(at: <URL to file with an API error>)
try await chain.registerFallbackResponse()
```

**Note:** `registerFallbackResponse()` throws error if `fallbackWebClient` is not provided by 
configuration.

In the case above `StubbedWebClient` will return succeeded response with some object 3 times, then it 
will throw an API error, and then it will use your server to receive responses to a request.

Also you can reset whole chain by using 
```swift  
await chain.reset()
``` 
method and create new chain of responses.

## Fallback all requests

In some cases you may want to fallback all requests responses to which are not registered. To do 
this you need to enable corresponding setting in `StubbedWebClient.Configuration` that's disabled 
by default.

```swift
configuration.fallbackRequestsIfNoResponsesRegistered = true
```
