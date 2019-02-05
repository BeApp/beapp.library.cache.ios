//
//  CacheManager.swift
//  BeappCache_Example
//
//  Created by Antoine Richeux on 05/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import BeappCache
import RxSwift

class CacheManager {
    static let shared = CacheManager()
    
    func saveData(text: String) -> Observable<String> {
        let singleText = Single.just(text)
        
        return RxCacheManager.cacheShared.fromKey(key: "cache_library")
            .withAsync(singleText)
            .withStrategy(.asyncOrCache)
            .fetch()
    }
    
}
