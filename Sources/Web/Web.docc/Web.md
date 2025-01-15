# ``Web``

*Web* is a network library that provides abstractions to build service layer, e.g. Request, WebClient, 
Converters, etc. Built on top of new concurrency model introduced in Swift 5.5.

## Topics

### Getting Started

- <doc:Installation>
- <doc:FirstRequest>
- <doc:MacrosRequestDeclaration>

- ``Request``
- ``NonAuthorizableRequest``
- ``WebClient``

- ``CONNECT(_:)``
- ``DELETE(_:)``
- ``GET(_:)``
- ``HEAD(_:)``
- ``OPTIONS(_:)``
- ``PATCH(_:)``
- ``POST(_:)``
- ``PUT(_:)``
- ``TRACE(_:)``

- ``Path()``
- ``Path(_:)``

- ``Headers(_:)``
- ``Header()``
- ``Header(_:)``

- ``Query()``
- ``Query(_:)``

- ``Body()``
- ``Body(_:)``

- ``SkippedAuthorization()``

### Request

- <doc:CreateURLRequest>
- <doc:ConvertBody>
- <doc:Multipart>

- ``Method``
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

- ``Foundation``

### Response

- ``Response``

- <doc:ValidateResponse>

- ``ResponseValidator``
- ``ResponseValidationDisposition``
- ``SuccessObjectResponseValidationDisposition``
- ``ErrorObjectResponseValidationDisposition``
- ``ValidationErrorResponseValidationDisposition``
- ``StatusCodeContentTypeResponseValidator``
- ``StatusCodeContentTypeResponseValidatorError``

- <doc:ConvertResponse>

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

### Logging

- <doc:LoggingRequestsAndResponses>
