# Authorize Request

Read how to use authorize requests using `RequestAuthorizer`.

## Implement Request Authorizer

The *Web* library provides a `RequestAuthorizer` protocol that allows you to authorize all
requests you send using a web client. `RequestAuthorizer` is a good place where you can fetch an
authorization token in the keychain or suspend all request and refresh all tokens using refresh 
token. 

```swift
final class MyAppRequestAuthorizer: RequestAuthorizer {
   ...

   func authorizationHeader<Request: Web.Request>(
      for request: Request
   ) async throws -> AuthorizationHeader? {
      let token = try keychain.fetchToken()
      return AuthorizationHeader(name: "Authorization", value: "Bearer \(token))
   }
}
```

Then you need to set this authorizer to web client configuration.

```swift
let configuration: URLSessionWebClientConfiguration = .default
configuration.requestAuthorizer = MyAppRequestAuthorizer(keychain: keychain)
```

## Skip Authorization for Requests

If you need some requests to not to be authorized, you can either use different web client 
instances or use protocol-marker to mark needed request. The *Web* library provides protocol-marker
called `WithoutAuthorizationRequest`.

```swift
struct SomeObjectRequest: MyAppRequest, WithoutAuthorizationRequest {
   ...
}

final class MyAppRequestAuthorizer: RequestAuthorizer {
   ...

   func authorizationHeader<Request: Web.Request>(
      for request: Request
   ) async throws -> AuthorizationHeader? {
      if request is WithoutAuthorizationRequest {
         return nil
      }

      ...
   }
}
```
