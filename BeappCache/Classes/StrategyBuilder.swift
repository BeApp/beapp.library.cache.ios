//
//  StrategyBuilder.swift
//  BeappCache
//
//  Created by Cedric G on 06/02/2019.
//

import Foundation
import RxSwift

public class StrategyBuilder<T: Codable> {
    private let key: String
    private let cacheManager: RxCacheManager
    private var cacheStrategy: CacheStrategy
    
    private var asyncObservable: Single<T>
    
    init(key: String, cacheManager: RxCacheManager) {
        self.key = key
        self.cacheManager = cacheManager
        self.cacheStrategy = .cacheThenAsync
        self.asyncObservable = Single.never()
    }
    
    /**
     Apply the strategy to use
     - parameter strategy: The strategy pattern to use
     */
    public func withStrategy(_ strategy: CacheStrategy) -> StrategyBuilder<T> {
        self.cacheStrategy = strategy
        return self
    }
    
    /**
     The Single to use for async operations.
     - parameter async: Single
     */
    public func withAsync(_ async: Single<T>) -> StrategyBuilder<T> {
        self.asyncObservable = async
        return self
    }
    
    /**
     Convert this resolution data strategy to a Rx Observable
     - returns: an Observable
     */
    public func fetch() -> Observable<T> {
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
