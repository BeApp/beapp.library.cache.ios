//
//  CacheStrategy.swift
//  BeappCache
//
//  Created by Anthony Dudouit on 03/09/2018.
//  Copyright © 2018 Cedric G. All rights reserved.
//

import Foundation
import RxSwift

protocol CacheStrategyProtocol {
	func getStrategyObservable<T>(cacheObservable: Maybe<CacheWrapper<T>>, asyncObservable: Single<CacheWrapper<T>>) -> Observable<CacheWrapper<T>> where T: Codable
}

public enum CacheStrategy {
	case cacheThenAsync
	case asyncOrCache
	case cacheOrAsync
	case justCache
	case justAsync
	
	var strategy: CacheStrategyProtocol {
		switch self {
		case .cacheThenAsync:
			return CacheThenAsyncStrategy()
		case .asyncOrCache:
			return AsyncOrCacheStrategy()
		case .justCache:
			return JustCacheStrategy()
		case .justAsync:
			return JustAsyncStrategy()
		case .cacheOrAsync:
			return CacheOrAsyncStrategy()
		}
	}
}
