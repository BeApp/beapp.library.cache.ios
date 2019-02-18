//
//  JustAsyncStrategy.swift
//  BeappCache
//
//  Created by Anthony Dudouit on 03/09/2018.
//  Copyright © 2018 Cedric G. All rights reserved.
//

import RxSwift

class JustAsyncStrategy: CacheStrategyProtocol {
	
	func getStrategyObservable<T>(cacheObservable: Maybe<CacheWrapper<T>>, asyncObservable: Single<CacheWrapper<T>>) -> Observable<CacheWrapper<T>> where T: Codable {
		return asyncObservable.asObservable()
	}
}
