# ``Web``

*Web* is a network library that provides you with a full-featured web client built on top of new
concurrency model introduced in Swift 5.5.

## Topics

### Getting Started

- <doc:Installation>
- <doc:FirstRequest>

- ``Request``
- ``WebClient``
- ``URLSessionWebClient``
- ``URLSessionWebClientConfiguration``

### Request

- <doc:CreateURLRequest>
- <doc:ConvertBody>
- <doc:Multipart>
- <doc:AuthorizeRequest>

- ``Method``
- ``Header``
- ``URLConstructionError``
- ``URLEncoder``
- ``URLEncoderError``

- ``BodyConverter``
- ``DataBodyConverter``
 - ``JPEGImageBodyConverter`` 
 - ``JPEGImageBodyConverterError`` 
 - ``PNGImageBodyConverter`` 
 - ``PNGImageBodyConverterError`` 
- ``JSONEncoderBodyConverter``
- ``JSONSerializationBodyConverter``
- ``PropertyListEncoderBodyConverter``
- ``StringBodyConverter``
- ``StringBodyConverterError``
- ``URLEncoderBodyConverter``

- ``MultipartBodyConverter``
- ``FormData``
- ``BodyPart``

- ``RequestAuthorizer``
- ``WithoutAuthorizationRequest``

### Response

- <doc:ValidateResponse>
- <doc:ConvertResponse>

- ``Response``

- ``ResponseValidator``
- ``ResponseValidationDisposition``
- ``StatusCodeContentTypeResponseValidator``
- ``StatusCodeContentTypeResponseValidatorError``

- ``ResponseConverter``
- ``AsIsResponseConverter``
- ``DataResponseConverter``
- ``EmptyResponseConverter``
 - ``ImageResponseConverter`` 
 - ``ImageResponseConverterError`` 
- ``JSONDecoderResponseConverter``
- ``JSONSerializationResponseConverter``
- ``JSONSerializationResponseConverterError``
- ``PropertyListDecoderResponseConverter``
- ``StringResponseConverter``
- ``StringResponseConverterError``

### Security

- <doc:EvaluateServerTrust>

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
