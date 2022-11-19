# Convert Response

Read how to convert a response to Swift objects.

## Overview

The response converter is an object to which a web client delegates responsibility to convert
binary response body from to a Swift object.

Each request returns two response converters: one for successful response and one for failed. The 
*Web* library has several built-in response converters such as

- `JSONDecoderResponseConverter`
- `JSONSerializationResponseConverter`
- `DataResponseConverter`
- `PropertyListDecoderResponseConverter`
- `StringResponseConverter`
- `EmptyResponseConverter`

On platforms where `UIKit` is available you can also use `ImageResponseConverter`.

## Create Your Own

If you use custom response formats or custom JSON decoding libraries, you can declare your own 
converter

```swift
struct MyOwnResponseConverter<ConvertedResponse>: ResponseConverter {
   func convert(_ response: Response) throws -> ConvertedResponse {
      // Convert response to Swift object here
   }
}
```

The data to be converted can be accessed via `response.body`.
