# ``WebCore``

*WebCore* is a library that provides full-featured implementation of *WebClient* including 2FA,
request authorization, SSL pinning. Built on top of new concurrency model introduced in Swift 5.5.

## Topics

### Getting Started

- ``URLSessionWebClient``

### Request

- <doc:AuthorizeRequest>

- ``AuthorizationHeader``
- ``RequestAuthorizer``

### Security

- <doc:EvaluateServerTrust>

- ``URLAuthenticationHandler``
- ``ServerTrustURLAuthenticationHandler``
- ``ServerTrustPolicy``
- ``TrustAllServerTrustPolicy``
- ``DefaultServerTrustPolicy``
- ``PinnedCertsServerTrustPolicy``
- ``PublicKeysServerTrustPolicy``

### 2FA

- <doc:Handle2FAChallenge>

- ``TwoFactorAuthenticationHandler``
- ``TwoFactorAuthenticationChallenge``
- ``TwoFactorAuthenticationChallengeError``
