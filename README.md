# Flickr
### Deployment Target - iOS 10.0 and above
### Swift Version - 5.0

## Architecture
This project is based on protocol oriented MVVM architecture

## Features
- Search given query on Flickr search api and displays results in 3 column scrollable view with pagination
- When clicked on any image a new view controlled is displayed with image loaded in high quality

## Under the hood implementation
- Image caching is implemented using `NSCache`
- Each cell view model has separate image downloading task, this helps to solve the most common image flickering issue
  due to cell reuse. This also helps in Network call optimization by pausing and resuming downloads when cells goes
  offscree and when cells are visible
- Supports `RETRY` logic on individual cell when image loading fails
- `Router` is added to handle routing logic separately without adding routing code in view controller. This will further
  avoiding creating massive view controller :)
  
## Tests
- Basic unit tests for `View Model` behaviour and other functionalities have been added

## Features for production
- Add zoom in and zoom out support for image
- Add support for instagram like picture in picture display of image when long pressed on any of the cell
- Prefetch images using collectioview's `prefetch` api
- Add settings page to support
  - Content type based on flickr api like screenshots only etc.
  - Filtered content
