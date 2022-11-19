# Convert Body

Read what is body converter, how to use them and how to create your own.

## Overview

The body converter is an object that takes some other object, data from which you want send to a 
server, and converts it to the binary representation that can be used by an HTTP.

Usually you use body converters when you create instances of URLRequests as described in the 
<doc:CreateURLRequest> article. The library provides you with the following body converters

- `DataBodyConverter`
- `JSONEncoderBodyConverter`
- `JSONSerializationBodyConverter`
- `PropertyListEncoderBodyConverter`
- `StringBodyConverter`
- `URLEncoderBodyConverter`

On platforms where `UIKit` is available you can use `JPEGImageBodyConverter` and 
`PNGImageBodyConverter`.

For more information please read related symbols in topics.

## Create Your Own

If you need to convert some object that can't be converted by provided converters, you can create
your own body converter. Here's the example how you can do this:

```swift
struct MyOwnBodyConverter: BodyConverter {
   var contentType: String {
      // Return appropriate content type here
   }
    
   func convert(_ body: MyCustomObject) throws -> Data {
      // Convert object to data here
   }
}
```
