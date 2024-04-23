# Authorize Request

Read how to use authorize requests using `RequestAuthorizer`.

## Implement Request Authorizer

The *WebCore* library provides a `RequestAuthorizer` protocol that allows you to authorize all
requests you send using a web client. `RequestAuthorizer` is a good place where you can fetch an
authorization token in the keychain or suspend all requests and refresh all tokens using refresh 
token. 

```swift
class MyAppRequestAuthorizer: RequestAuthorizer {
   ...

   func authorizationHeader(for request: some Request) async throws -> Header? {
      let token = try keychain.fetchToken()
      return .bearerAuthorization(with: token)
   }
}
```

Then you need to set this authorizer to web client configuration.

```swift
let configuration: URLSessionWebClientConfiguration = .default
configuration.requestAuthorizer = MyAppRequestAuthorizer(keychain: keychain)
```

## Skip Authorization for Requests

If you need some requests to not to be authorized, you can either use a different web client 
instance whose configuration doesn't have request authorizer, or conform desired requests to
`NonAuthorizableRequest` protocol provided by the *Web* library

```swift
struct SomeRequestWithoutAuthorization: Request, NonAuthorizableRequest {
   ...
}
```

or if your prefer to use macros

```swift
@SkippedAuthorization
struct SomeRequestWithoutAuthorization {
   ...
}
```

In this case default implementation of `needsAuthorization(for:)` method of ``RequestAuthorizer``
checks if request conform to `NonAuthorizableRequest` and returns `true` or `false` depending on
this conformance.

For more control you may implement `needsAuthorization(for:)` method of by yourself. 
