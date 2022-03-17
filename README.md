# Description

The Application emulates the product view of the Stockx's mobile App. We have a single product (the id is hardoced in the App) that is fetched from Curie's API and displayer in a product view. Once the App is started it starts fetching a 3D model for the product. While the product is being downloaded, a thumbnail image appears. This thumbnail image is currently a placeholder which shows only while we are waiting for the 3D model to download, after that it replaces it. Currenlty, we are still working on generating thumbanail urls for our products. If you notice a problem that the thumbnail image does not appear, please let us know and we will work to resolve it.

You may notice that this app utilizes a framework for actually calling the API. This framework automatically handles for you downloading and caching models. An example of how to use the framework is located in

`ARTask/ARTask/ViewController.swift`

The parameters you need to provide are:

* `apiKey` - Your API Key (the one in the code will work for testing purposes, further if we start working together we will give you another API Key which gives you access to all products which your company hosts with us)
* `maxNumberOfModelsToCache` - The number of models you want to cache. For example, if this is 2, the last 2 models you downloaded will always be cached and you won't need to download them again. 
* `aRModelKey` - The product id (the one in the code will work for testing purposes, further if we start working together you will be able to access a list of ids for all products you host with us)

Here is a link with a more detailed description on how to use the ARManager framework https://docs.google.com/document/d/1WojLvq02wFfQQiELd8vZLmHr2Hyq3NW2Vp6Hz3XknnM/edit?usp=sharing 

It is important to notice that to use the framework you should import it in the project. A detailed description on how to import it is in the link above. 

The ARManager.xcframework is located under the ARTask directory.
