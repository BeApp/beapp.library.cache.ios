# BeappCache

This library provides a cache mechanism relying on [RxSwift](https://github.com/ReactiveX/RxSwift).
There are currently one storage implementation :

* [Cache](https://github.com/hyperoslo/Cache)

## Installation

To install it, simply add the following line to your Podfile:

```
pod 'BeappCache'
```

## Usage

1. Declare an instance of RxCacheManager with the storage implementation desired
2. Call `fromKey` method from RxCacheManager instance and define your key
3. Add your asynchronous operation into  `.withAsync()`  (⚠️ Must be a single observer)
4. Define your cache strategy into `.withStrategy()`
5. Fetch the result (Return an Observable)

```
let rxCacheManager = RxCacheManager(storageType: .Cache)
rxCacheManager.fromKey(key: "key_xxx")
.withAsync(singleString)
.withStrategy(.justAsync)
.fetch()
```

## Result

```
[CACHE] saving key_xxx
[CACHE] cacheWrapper for key_xxx retrieved from cache
```

## Author

Beapp, contact@beapp.fr

## License

BeappLogger is available under the MIT license. See the LICENSE file for more info.
