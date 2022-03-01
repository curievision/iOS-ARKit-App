# Calling the API

The request url for obtaining a 3D model by ID is `https://dev.api.curie.io/public/products/\(id)/media?formats=usdz`

Here `\(id)` should be replaced by the ID of the product

Below is the code for creating the request

```swift
  var request = URLRequest(url: URL(string: "https://dev.api.curie.io/public/products/\(id)/media?formats=usdz")!, timeoutInterval: 20)
```

Here is the code for setting the method and the headers for calling the API

```
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(<YOUR-API-KEY>, forHTTPHeaderField: "x-curie-api-key")
```

