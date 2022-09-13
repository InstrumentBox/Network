# Create URL and URLRequest

Read how to create different requests you may want to send in convenient way.

## Create a URL

*Web* library has convenience initializers to simplify creation process of `URL`.

The first initializer for `URL` is

```swift
URL(path: String, baseURL: URL?) throws
```

This init is similar to `URL(string:relativeURL)` but throws error instead of returning `nil`

The second one is

```swift
URL(path: String, baseURL: URL?, query: [String: Any], encoder: URLEncoder = URLEncoder()) throws
```

It allows you to create `URL` with percent encoded query string. `URLEncoder`'s behavior can be 
customized for one case by using `URLEncoder(arrayKeyEncoding:boolEncoding:)` initializer, or 
globally by setting `URLEncoder.arrayKeyEncoding` and `URLEncoder.boolEncoding`

## Create a Request

*Web* library also has convenience initializers to simplify creation process of `URLRequest`. So 
let's take a look at initializers for `URLRequest`

The first one is

```swift
URLRequest(url: URL, method: Method, headers: [String: String]? = nil)
```

that just create a request with url, method, and header fields. *Web* has all default HTTP 
methods but you can use your own if you need it

```swift
extension Method {
   static let myOwnMethod = Method("MY_OWN_METHOD")
}
```

The second `URLRequest`'s initializer is

```swift
URLRequest<Body>(
   url: URL, 
   method: Method, 
   headers: [String: String]? = nil, 
   body: Body,
   converter: some BodyConverter<Body>
) throws
```

that does the same as the first one and in addition uses body converter to set request's body and 
add `Content-Type` header.
