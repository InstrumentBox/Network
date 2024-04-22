# Declare Request Using Macros

Learn how to declare requests using macros provided by the *Web* library.

## Describe a Request

The *Web* library also provides shortened way to declare requests by using macros. To declare a 
simple request you just need to do following:

```swift
@GET<SomeObject, APIError>("path/to/some/object")
struct SomeObjectRequest { }
```

In this declaration `SomeObject` is the object you need to get in case when request will succeed 
with successful status code and `APIError` is the object you need to catch when request will succeed
with unsuccessful status code. These conditions may be customized by using ``ResponseValidator``.

Types of generated converters depend on types of `SuccessObject` and `ErrorObject`.

Type of Object | Type of Generated Converter
---|---
Response | AsIsResponseConverter
Data | DataResponseConverter
Void | EmptyResponseConverter
String | StringResponseConverter
UIImage | ImageResponseConverter
Any other type | JSONDecoderResponseConverter

The same table is valid for `ErrorObject`.

If you need to use any other converter, you can just implement `successObjectResponseConverter`
or `errorObjectResponseConverter` by yourself. Implementation of these computed properties MUST
be inside of class or struct body.

```swift
@GET<SomeObject, APIError>("path/to/some/object")
struct SomeObjectRequest {
   var successObjectResponseConverter: any ResponseConverter<SomeObject> {
      MyOwnResponseConverter()
   }
}
```

Instead of `@GET` you may use any other macro with name that matches HTTP method name to declare 
request with desired HTTP method.

**Note:** custom HTTP methods are not supported. If you need custom HTTP method,
you need to implement conformance to ``Request`` by yourself.

## Make Path Dependent on Variables

You are allowed to make a path dynamically changed. Path may have variables that begin with colon 
sign. In this case a request declaration MUST have variable that marked with `@Path` macro.  
Name of this variable may match name of variable in path or you may provide path variable name via 
attribute argument. Variable names in path MUST NOT be the same.

Let's say you need to get some article written by an author:

```swift
@GET<Article, APIError>("authors/:author_id/articles/:id")
struct ArticleByIDRequest {
   @Path
   let id: Int

   @Path("author_id")
   let authorID: Int
}
```

## Define Query Items

Each request may have query items. To define query items you may write them directly in path string 
if their values are constants or you may mark needed variables with `@Query` macro. In the 
second case name of variable will be used as query parameter name. To customize it you need to pass 
query parameter name via attribute's argument. `@Query` variable may be optional. Duplication of 
query item names is error.

```swift
@GET<SomeObject, APIError>("path/to/some/object?query_item=42")
struct SomeObjectRequest {
   @Query
   let otherQueryItem: String

   @Query("another_query_item")
   let anotherQueryItem: Bool?
}
```

## Define Headers

Headers also can be defined by using macros. The first macro is `@Headers` that's attached to class
or struct declaring request and used to define headers with constant values. The second one is
`@Header` that's attached to variables of `String` type. Name of variable is used as name of header
in that case. To customize name of header you it via argument of macro. `@Header` variable may be
optional. Duplication of header names is error.

```swift
@GET<SomeObject, APIError>("path/to/some/object")
@Headers([
   "Header-One": "value 1",
   "Header-Two": "value 2"
])
struct SomeObjectRequest {
   @Header
   let headerThree: String

   @Header("Header-Four")
   let headerFour: String
}
```

## Send Request with Body

Body of request may be passed using `@Body` macro. Each request must contain the only body 
parameter.

```swift
@POST<SomeObject, APIError>("path/to/some/object")
struct SomeObjectRequest {
   @Body
   let object: SomeObject
}
```

Types of body converter that is used to convert body to data will depend on type of variable `@Body`
macro is attached. Variable should not be optional.

Type of Object | Type of Generated Converter
---|---
String | StringBodyConverter
Any other type | JSONEncoderResponseConverter

If you need to customize body converter's type or customize initialization of converter, you may do
this by passing argument to `@Body` macro. In that case type of variable must match type body 
converter works with.

Let's say you need customize data encoding strategy of your `JSONEncoder` that's used by converter.

```swift
@POST<SomeObject, APIError>("path/to/some/object")
struct SomeObjectRequest {
   @Body(JSONEncoderBodyConverter<SomeObject>(encoder: {
      let encoder = JSONEncoder()
      encoder.dataEncodingStrategy = .iso8601
      return encoder
   }()))
   let someObject: SomeObject
}
```
