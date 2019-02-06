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
let rxCacheManager = RxCacheManager()
rxCacheManager.fromKey(key: "key_xxx")
.withAsync(singleString)
.withStrategy(.justAsync)
.fetch()
```

## RxCacheManager configuration

### Default configuration
* `RxCacheManager()`: 
1. Use  the Cache librairy
2. Cache configuration is by default `DiskConfig(name: "Floppy")` and `MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)`

### Cache with configuration
* `RxCacheManager(storageType: .cache(config: cacheConfig))`
1. Use the cache librairy
2. Define your cache configuration like next  `let cacheConfig = CacheStorageConfig(diskConfig: DiskConfig(name: "your_name"), memoryConfig: MemoryConfig(expiry: expiry, countLimit: Uint, totalCostLimit: Uint))`

### Custom storage protocol
* `RxCacheManager(storageType: .custom(storage: YourExternalStorageProtocol()))` 
1. Define your own `ExternalStorageProtocol`

## Result

```
[BeappCache] [Cache] CacheWrapper with the key key_xxx saved
Success async request or data from cache

[BeappCache] [Cache] CacheWrapper with the key key_xxx saved
Success async request

[BeappCache] [Cache] CacheWrapper for key_xxx retrieved from cache
Success to get data from cache
```

## Author

Beapp, contact@beapp.fr

## License

BeappLogger is available under the MIT license. See the LICENSE file for more info.
