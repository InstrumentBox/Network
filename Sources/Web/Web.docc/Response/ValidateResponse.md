# Validate Response

Read how to validate a response.

## Overview

`Request` also has one more property called `responseValidator`, which returns default validator
for every request. The default (`StatusCodeContentTypeResponseValidator`) validator checks that 
status code is in 200...299 range and response's content type matches requested one. In case when 
there's no *Content-Type* header in response and/or no *Accept* header in request, validator 
considers status code only.

## Create Your Own

If you want to use your own response validator, you're free to do this

```swift
struct MyOwnResponseValidator: ResponseValidator {
   func validate(_ response: Response) -> ResponseValidationDisposition {
      // Do validation
   }
}
```

Properties of response you may want to use to validate response

- `request` is a request that has been sent to receive this response
- `statusCode` is status code returned by a server
- `headers` are dictionary with HTTP headers
- `body` contains response's body

Response validator returns disposition which can be one of the following values:
- `.useSuccessObjectResponseConverter` to convert and return object as expected result of a request
- `.useErrorObjectResponseConverter` to convert and throw object as error (e.g. `APIError` in case of 4xx)
- `.completeWithError(Error)` and throw passed validation error (e.g. content types don't match)

Then you can use response validator for every request in you app

```swift
protocol MyAppRequest: Request { }

extension MyAppRequest {
   var responseValidator: ResponseValidator {
      MyOwnResponseValidator()
   }
}
```

Or for concrete request

```swift
struct ConcreteRequest: Request {
   var responseValidator: ResponseValidator {
      MyOwnResponseValidator()
   }
}
```
