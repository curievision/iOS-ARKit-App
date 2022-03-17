# Description

The Application emulates the product view of the Stockx's mobile App. We have a single product (the id is hardoced in the App) that is fetched from Curie's API and displayer in a product view. Once the App is started it starts fetching a 3D model for the product. While the product is being downloaded, a thumbnail image appears. This thumbnail image is currently a placeholder which shows only while we are waiting for the 3D model to download, after that it replaces it. Soon (this week) we will offer an endpoint for obtaining this thumbnail image through the API as well

# Calling the API

The code for communicating with the API is located in `ARTask/ARTask/Managers/APIManager.swift`

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
        request.addValue(<API-KEY>, forHTTPHeaderField: "x-curie-api-key")
```
The `<API-KEY>` is currently hardcoded, please change it with your API key.

NOTE:
There is currently a placeholder image which shows once the App is open and we are waiting for the 3D model to be downloaded. Soon (this week) we will offer an endpoint for obtaining this thumbnail image through the API 

