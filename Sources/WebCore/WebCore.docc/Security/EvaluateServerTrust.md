# Evaluate Server Trust

Read how to send requests and receive response in a secure way.

## Overview

Using a secure HTTPS connection when communicating with servers and web services is an important 
step in securing sensitive data. By default, the *WebCore* library receives the same automatic TLS 
certificate and certificate chain evaluation as URLSession. While this guarantees the certificate 
chain is valid, it does not prevent man-in-the-middle (MITM) attacks or other potential 
vulnerabilities. In order to mitigate MITM attacks, applications dealing with sensitive customer 
data or financial information should use certificate or public key pinning provided by the *WebCore* 
library.

## Server Trust Policy

The `ServerTrustPolicy` protocol provides a way to perform any sort of server trust evaluation. The 
*WebCore* library includes many different types of trust policies, providing composable control over 
the evaluation process:

- `DefaultServerTrustPolicy` that uses the default server trust evaluation while allowing you to 
  control whether to evaluate the host provided by the challenge.
- `PinnedCertsServerTrustPolicy` that uses the provided certificates to evaluate the server trust. 
  The server trust is considered valid if one of the pinned certificates match one of the server 
  certificates. This policy can also accept self-signed certificates.
- `PublicKeysServerTrustPolicy` that uses the provided public keys to evaluate the server trust. 
  The server trust is considered valid if one of the pinned public keys match one of the server 
  certificate public keys.
- `TrustAllServerTrustPolicy` that should only be used in debug scenarios as it disables all 
  evaluation which in turn will always consider any server trust as valid. This policy should 
  **never** be used in production environments!

## Create Your Own Policy

```swift
class MyServerTrustPolicy: ServerTrustPolicy {
   func evaluate(_ serverTrust: SecTrust, for host: String) -> Bool {
      // Do evaluation here
   }
}
```

## Enable Security in Your App

The `URLSessionWebClientConfiguration` is responsible for storing an internal mapping of 
`ServerTrustPolicy` values to a particular host. This allows the web client to evaluate each host 
with different evaluators. To apply policy for all hosts except specified use `*` as host name.  

```swift
let configuration: URLSessionWebClientConfiguration = .default
configuration.serverTrustPolicies = [
   "cert.example.com": PinnedCertsServerTrustPolicy(),
   "keys.example.com": PublicKeysServerTrustPolicy(),
   "*": DefaultServerTrustPolicy()
]
```
