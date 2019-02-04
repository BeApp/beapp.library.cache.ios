//
//  VMCacheManager.swift
//  lejournal
//
//  Created by Anthony Dudouit on 01/08/2018.
//  Copyright © 2018 Cedric G. All rights reserved.
//

import Foundation
import Cache
import RxSwift

public struct DummyCodable: Codable { }

// MARK: - Protocol
protocol RxCacheManagerDependant {}

extension RxCacheManagerDependant {
	var cacheManager: RxCacheManager {
		return RxCacheManager.shared
	}
}

/**
[RxCache Beapp Android]: (https://bitbucket.org/beappers/beapp.cache.andro)

This class is the entry point of the Cache management

- References: [RxCache Beapp Android]
*/
class RxCacheManager {
	
	static let shared = RxCacheManager()
	
	var storage: Storage<DummyCodable>?
	
	private init() {
		let diskConfig = DiskConfig(name: "Floppy")
		let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
		do {
			storage = try Storage(
				diskConfig: diskConfig,
				memoryConfig: memoryConfig,
				transformer: TransformerFactory.forCodable(ofType: DummyCodable.self)
			)
			
		} catch {
			print(error)
		}
	}
	
	fileprivate func buildCacheObservable<T>(key: String, of type: T.Type) -> Maybe<CacheWrapper<T>> where T: Codable {
		return Maybe<CacheWrapper<T>>.create { maybe in
			guard let _storage = self.storage else {
				print("[CACHE] no storage error")
				maybe(.completed)
				return Disposables.create()
			}
			do {
				let cacheWrapper = try _storage.transformCodable(ofType: CacheWrapper<T>.self).object(forKey: key)
				print("[CACHE] cacheWrapper for \(key) retrieved from cache")
				maybe(.success(cacheWrapper))
			} catch {
				print("[CACHE] cacheWrapper for \(key) not retrieved with error \(error)")
				maybe(.completed)
			}
			return Disposables.create()
		}
			.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
	}
	
	fileprivate func buildAsyncObservableCaching<T>(asyncObservable: Single<T>, key: String) -> Single<CacheWrapper<T>> where T: Codable {
		return asyncObservable
			.do(onSuccess: { (decodable) in
				self.setCache(decodable, with: key)
			})
			.map { CacheWrapper<T>(date: Date(), data: $0) }
		
	}
	
	fileprivate func setCache<T>(_ data: T, with key: String) where T: Codable {
		print("[CACHE] saving \(key)")

		let cacheData = CacheWrapper<T>(date: Date(), data: data)
		do {
			try storage?.transformCodable(ofType: CacheWrapper.self).setObject(cacheData, forKey: key)
		} catch {
			print("[CACHE] error saving cache with \(key) \(error)")
		}
	}
	
	/**
	Create a new builder to configure data cache resolution strategy for the given key.
	
	- parameter key:  The key pattern to retrieve data
	- returns: A builder to prepare cache resolution
	*/
	func fromKey<T: Codable>(key: String) -> StrategyBuilder<T> {
		return StrategyBuilder<T>(key: key, cacheManager: self)
	}

}

class StrategyBuilder<T: Codable> {
    private let key: String
    private let cacheManager: RxCacheManager
    private var cacheStrategy: CacheStrategy
    
    private var asyncObservable: Single<T>
    
    fileprivate init(key: String, cacheManager: RxCacheManager) {
        self.key = key
        self.cacheManager = cacheManager
        self.cacheStrategy = .cacheThenAsync
        self.asyncObservable = Single.never()
    }
    
    /**
     Apply the strategy to use
     - parameter strategy: The strategy pattern to use
     */
    func withStrategy(_ strategy: CacheStrategy) -> StrategyBuilder<T> {
        self.cacheStrategy = strategy
        return self
    }
    
    /**
     The Single to use for async operations.
     - parameter async: Single
     */
    func withAsync(_ async: Single<T>) -> StrategyBuilder<T> {
        self.asyncObservable = async
        return self
    }
    /**
     Convert this resolution data strategy to a Rx Observable
     - returns: an Observable
     */
    func fetch() -> Observable<T> {
        return self.fetchWrapper()
            .map { cacheWrapper in cacheWrapper.data }
    }
    
    /**
     Convert this resolution data strategy to a Rx Observable
     - returns: an Observable
     */
    func fetchWrapper() -> Observable<CacheWrapper<T>> {
        
        let asyncObservableCaching = cacheManager.buildAsyncObservableCaching(asyncObservable: self.asyncObservable, key: self.key)
        let cacheObservable = cacheManager.buildCacheObservable(key: self.key, of: T.self)
        
        return cacheStrategy.strategy.getStrategyObservable(cacheObservable: cacheObservable, asyncObservable: asyncObservableCaching)
    }
}