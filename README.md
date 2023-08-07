# flckr-img-search

This is implementation of test assignment.

## Configuration

- Open workspace with XCode
- Select correct development team & bundle identifier
- Add flick API key to `image-search/ImageSearch/Shared/Api/FlickrEndpoint.swift`

## Data flow

This application is implemented using MVVM+C pattern. Coordinator use is fairly standart but data flow is organized using `AsynSequences` containing `State` entities.

Each `State` enitity must fully describe state that view will use to update it's properties. This approach attemps to eliminate state abguity and simplify transition between different states.
While approach using `AsynSequences` is experimental and not fully fleshed out I beleive that current implementation is good enough to demonstate basic idea and provide required features.

To fetch and display images I've decided to use [Nuke](https://github.com/kean/Nuke) which provides all required functionaly out of the box including asynchronous loading and caching.

Application uses `UserDefaults` to store search history. I've decided to use this approach because of it's simplicity and low amount of simple data that needs to be stored.

To display data I'm using `UICollectionViewController` powered by `UICollectionViewDiffableDataSource` and `UICollectionViewCompositionalLayout` with mixture of simple `UICollectionViewCell` to display an image and default `UICollectionViewListCell` to display search history. Currently all data is stored in data source as item identifiers.

## Possible improvements

Due to limited constraints and this app being test assignment I've decided to omit some features and improvements that would be highly desirable for an actual production-ready application:

### UX/UI

- A11y support: currently the are no a11y labels for image cells
- Image prefetching
- Low power mode and low data mode: both of modes should take into consideration device conditions and limit network and battery usage accordingly. For example we could disable prefetching, change page size or decrease quality of photos to save on power and data
- Support for multiple windows: in order to enable multiple windows we would need to add support for state broadcast for `SearchHistoryService` to be able to update state in one window based on changes from other window
- Select image resolution based on actual image cell size

### Developer Experience

- Better secret management
- Improve usability of unit-test and remove duplicated checks
- Add proper middleware support to `ApiService` in order to simplify injection of common data such as api tokens
- Support for queries in api service mocks
