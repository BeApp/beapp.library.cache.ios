//
//  XCCache.swift
//  BeappCache_Example
//
//  Created by Antoine Richeux on 18/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import BeappCache
import RxSwift

class XCCache {
    
    let bag = DisposeBag()
    var cacheManager: RxCacheManager!
    
    init(cacheManager: RxCacheManager) {
        self.cacheManager = cacheManager
        clear()
    }
    
    func exist(forKey key: String) -> Bool {
        return cacheManager.exist(forKey: key)
    }
    
    func delete(forKey key: String) {
        cacheManager.delete(forKey: key)
    }
    
    func clear() {
        cacheManager.clear()
    }
    
    func setDataInCache(forKey key: String, strategy: CacheStrategy, callBack: @escaping(Bool) -> ()) {
        cacheManager.fromKey(key: key)
            .withAsync(Single.just("Data for key \(key) is saved"))
            .withStrategy(strategy)
            .fetch()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (result) in
                print("Data is created for key \(key)")
            }, onError: { (error) in
                print("[ERROR] Cannot add the key with error \(error)")
                callBack(false)
            }, onCompleted: {
                callBack(true)
            })
            .disposed(by: bag)        
    }
    
    func getDataFromCache(forKey key: String, callBack: @escaping(String) -> ()) {
        cacheManager.fromKey(key: key)
            .withAsync(Single.just(String()))
            .withStrategy(.justCache)
            .fetch()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (keyValue) in
                callBack(keyValue)
            }, onError: { (error) in
                print("[ERROR] Cannot retrieve the key value with error \(error)")
                callBack("[ERROR]")
            })
            .disposed(by: bag)
    }
    
}
