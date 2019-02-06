//
//  VMCacheManager.swift
//  BeappCache
//
//  Created by Anthony Dudouit on 01/08/2018.
//  Copyright © 2018 Cedric G. All rights reserved.
//

import Foundation
import RxSwift

public struct DummyCodable: Codable { }

/**
[RxCache Beapp Android]: (https://bitbucket.org/beappers/beapp.cache.andro)

This class is the entry point of the Cache management

- References: [RxCache Beapp Android]
*/

open class RxCacheManager {
	var externalStorageType: ExternalStorageEnum
	
    public init(storageType: ExternalStorageEnum = .defaultCache) {
        externalStorageType = storageType
    }
	
    // MARK: -
    
    func buildCacheObservable<T>(key: String, of type: T.Type) -> Maybe<CacheWrapper<T>> where T: Codable {
		return Maybe<CacheWrapper<T>>.create { maybe in
            if let cacheWrapper = self.externalStorageType.storage.get(forKey: key, of: T.self) {
                print("[CACHE] cacheWrapper for \(key) retrieved from cache")
                maybe(.success(cacheWrapper))
            } else {
                print("[CACHE] cacheWrapper for \(key) not retrieved")
                maybe(.completed)
            }
            return Disposables.create()
		}
        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
	}
	
    func buildAsyncObservableCaching<T>(asyncObservable: Single<T>, key: String) -> Single<CacheWrapper<T>> where T: Codable {
		return asyncObservable
			.do(onSuccess: { (decodable) in
				self.setCache(decodable, with: key)
			})
			.map { CacheWrapper<T>(date: Date(), data: $0) }
	}
	
	fileprivate func setCache<T>(_ data: T, with key: String) where T: Codable {
		print("[CACHE] saving \(key)")

		let cacheData = CacheWrapper<T>(date: Date(), data: data)
        if !externalStorageType.storage.put(data: cacheData, forKey: key) {
			print("[CACHE] error saving cache with \(key)")
		}
	}
	
    // MARK: - Public
    
	/**
	Create a new builder to configure data cache resolution strategy for the given key.
	
	- parameter key:  The key pattern to retrieve data
	- returns: A builder to prepare cache resolution
	*/
	public func fromKey<T: Codable>(key: String) -> StrategyBuilder<T> {
		return StrategyBuilder<T>(key: key, cacheManager: self)
	}
    
    /// Ask to know the current data count
    ///
    /// - Returns: count of data stored
    public func count() -> Int {
        return externalStorageType.storage.count()
    }
    
    /// Ask to know if a data with specific key exist
    ///
    /// - Parameter key: The key pattern to retrieve data
    /// - Returns: if true the data with key exist
    public func exist(forKey key: String) -> Bool {
        return externalStorageType.storage.exist(forKey: key)
    }
    
    /// Delete an entry define by the key pattern
    ///
    /// - Parameter key: The key pattern to delete data
    public func delete(forKey key: String) {
        externalStorageType.storage.delete(forKey: key)
    }
    
    /// Clear all data stored
    public func clear() {
        externalStorageType.storage.clear()
    }
}
