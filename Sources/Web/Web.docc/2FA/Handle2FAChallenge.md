# Handle 2FA Challenge

Read how to handle and interact with 2FA challenges.

## Overview

Two factor authentication is an authentication method that allows to improve security of your 
app. In our apps we usually use one-time passwords sent to a user via text messages or e-mails. The
*Web* library provides you with functionality to handle these challenges in one place.

##### Note:

This functionality is intended to handle challenges when you need to re-send request to get one-time
password one more time and send the same request but with additional header field to authenticate
challenge.

### Implement Handler

To handle 2FA challenges, *Web* library provides you with a `TwoFactorAuthenticationHandler` 
protocol you need to implement.

```swift
final class My2FAHandler: TwoFactorAuthenticationHandler { }
```

This protocol has two required methods you need to implement. The first one responds for checking a
response if it requires 2FA. Let's say your server returns status code if 600 2FA is required.

```swift
final class My2FAHandler: TwoFactorAuthenticationHandler { 
   func responseRequiresTwoFactorAuthentication(_ response: Response) -> Bool {
      response.statusCode == 600
   }
}
```

The second method is the point where you can present UI to a user.

```swift
final class My2FAHandler: TwoFactorAuthenticationHandler {
   ...

   func handle(_ challenge: TwoFactorAuthenticationChallenge) { }
}
```

A server may return you some data about 2FA challenge so you need to get this data.

```swift
@MainActor
func handle(_ challenge: TwoFactorAuthenticationChallenge) {
   do {
      let props = try challenge.convertedResponse(using: JSONDecoderResponseConverter<TwoFAProps>()) 
   } catch {
      challenge.complete(with: error)
   }
}
```

Now you can present a view controller to a user.

```swift
@MainActor
func handle(_ challenge: TwoFactorAuthenticationChallenge) {
   ...
   let controller = TwoFAViewController(
      props: props, 
      onCancel: { [weak self] in
         self?.cancel(challenge)
      }, 
      onRefresh: {
         try await challenge.refresh()
      },
      onAuthenticate: { [weak self] code in
         let header = Header(name: "X-2FA-HEADER", value: code)
         do {
            try await challenge.authenticate(with: header)
            self?.complete(challenge, with: nil)
         } catch {
            self?.complete(challenge, with: error)
         }
      }
   )
   presentingViewController.present(controller, animated: true)
}

@MainActor
func cancel(_ challenge: TwoFactorAuthenticationChallenge) {
   presentingViewController.dismiss(animated: true) {
      challenge.cancel()
   }
}

@MainActor
func complete(_ challenge: TwoFactorAuthenticationChallenge, with error: Error?) {
   presentingViewController.dismiss(animated: true) {
      challenge.complete(with: error)
   }
}
```

Finally, set the handler to a web client configuration.

```swift
let config: URLSessionWebClientConfiguration = .default
config.twoFactorAuthenticationHandler = My2FAHandler(presentingViewController: controller)
```

That's it! Now you don't have to worry about 2FA challenges for particular requests. They will 
be handled automatically.
