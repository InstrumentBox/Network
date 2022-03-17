# Multipart

Read how to deal with multipart requests.

## Make a Request with Multipart Body

The *Web* library allows you to make requests with multipart bodies using `MultipartBodyConverter`. 
This converter takes array of `BodyPart` as parameters. Let's say you want to upload image using 
multipart request. 

```swift
struct UploadImageRequest: MyAppRequest {
   typealias Object = UploadImageResponse

   let image: UIImage

   func toURLRequest(with baseURL: URL?) throws -> URLRequest {
      let bodyParts = try [
         BodyPart(name: "my_image", body: image, converter: JPEGImageBodyConverter())
      ]
      ...
      return try URLRequest(..., body: bodyParts, converter: MultipartBodyConverter())
   }
}
```

You can choose one of the following content types `MultipartBodyConverter` returns:

- `multipart/alternative`
- `multipart/form-data`
- `multipart/mixed`
- `multipart/related`

## Create Your Own Form Data

The *Web* library provides you with the `FormData` protocol so it allows you to implement your own 
form data. In this case you are responsible to add boundary, headers, and all needed line breaks.  

```swift
struct MyFormData: FormData {
   func makeFormData(boundary: String) throws -> Data {
      // Make form data here
   }
}
```
