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

open class RxCacheManager {
	var externalStorageType: ExternalStorageEnum
    var log: Log!
	
    public init(storageType: ExternalStorageEnum = .defaultCache, verbose: Bool = false) {
        externalStorageType = storageType
        log = Log(verbose: verbose)
    }
	
    // MARK: - Internal functions
    
    func buildCacheObservable<T>(key: String, of type: T.Type) -> Maybe<CacheWrapper<T>> where T: Codable {
		return Maybe<CacheWrapper<T>>.create { maybe in
            do {
                if let cacheWrapper = try self.externalStorageType.storage.get(forKey: key, of: T.self) {
                    self.log.printLog(type: self.externalStorageType.type, message: "CacheWrapper for \(key) retrieved from cache")
                    maybe(.success(cacheWrapper))
                }
             } catch {
                self.log.printLog(type: self.externalStorageType.type, message: "[ERROR] CacheWrapper for \(key) not retrieved with error \(error)")
                maybe(.completed)
            }
            
            return Disposables.create()
		}
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
	}
	
    func buildAsyncObservableCaching<T>(asyncObservable: Single<T>, key: String, customExpirySecond: TimeInterval?) -> Single<CacheWrapper<T>> where T: Codable {
		return asyncObservable
			.do(onSuccess: { (decodable) in
                self.setCache(decodable, with: key, customExpirySecond)
			})
			.map { CacheWrapper<T>(date: Date(), data: $0) }
	}
	
    /// Set data in cache file with key
    ///
    /// - Parameters:
    ///   - data: Codable data to stored
    ///   - key: id to save data in cache file
    func setCache<T>(_ data: T, with key: String, _ customExpirySecond: TimeInterval?) where T: Codable {
        log.printLog(type: self.externalStorageType.type, message: "CacheWrapper with the key \(key) saved")

		let cacheData = CacheWrapper<T>(date: Date(), data: data)
        do {
            try externalStorageType.storage.put(data: cacheData, forKey: key, customExpirySecond: customExpirySecond)
        } catch {
            self.log.printLog(type: self.externalStorageType.type, message: "[ERROR] CacheWrapper for \(key) not saved with error \(error)")
        }
	}
	
    // MARK: - Public
    
	/**
	Create a new builder to configure data cache resolution strategy for the given key.
	
	- parameter key:  The key pattern to retrieve data
	- returns: A builder to prepare cache resolution
	*/
    public func fromKey<T: Codable>(key: String, withCustomExpiration expSecond: TimeInterval? = nil) -> StrategyBuilder<T> {
		return StrategyBuilder<T>(key: key, cacheManager: self, customExpirySecond: expSecond)
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
        do {
            return try externalStorageType.storage.exist(forKey: key)
        } catch {
            self.log.printLog(type: self.externalStorageType.type, message: "[ERROR] cannot retrieve information with \(key) with error \(error)")
            return false
        }
    }
    
    /// Delete an entry define by the key pattern
    ///
    /// - Parameter key: The key pattern to delete data
    public func delete(forKey key: String) {
        do {
            try externalStorageType.storage.delete(forKey: key)
            self.log.printLog(type: self.externalStorageType.type, message: "CacheWrapper with the key \(key) deleted")
        } catch {
            self.log.printLog(type: self.externalStorageType.type, message: "[ERROR] CacheWrapper for \(key) not deleted with error \(error)")
        }
    }
    
    /// Clear all data stored
    public func clear() {
        do {
            try externalStorageType.storage.clear()
        } catch {
            self.log.printLog(type: self.externalStorageType.type, message: "[ERROR] CacheWrapper database not cleared with error \(error)")
        }
    }
}
