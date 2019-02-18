//
//  Tests_Cache_Custom.swift
//  BeappCache_Tests
//
//  Created by Antoine Richeux on 08/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import RxSwift
import Cache
import BeappCache

class Tests_Cache_Custom: XCTestCase {
    
    var bag: DisposeBag?
    var cacheManager: RxCacheManager?
    
    override func setUp() {
        super.setUp()
        
        bag = DisposeBag()
        
        let diskConfig = DiskConfig(name: "BeappCache")
        let memoryConfig = MemoryConfig(expiry: .date(Date().addingTimeInterval(3600 * 24)), countLimit: 20, totalCostLimit: 20)
        let cacheConfig = CacheStorageConfig(diskConfig: diskConfig, memoryConfig: memoryConfig)
        cacheManager = RxCacheManager(storageType: .cache(config: cacheConfig), verbose: true)
        
        clearDatabase()
    }
    
    override func tearDown() {
        super.tearDown()
        
        bag = nil
        cacheManager = nil
    }

    func testCreateKeyInCache() {
        guard let _cacheManager = cacheManager else { return }
        
        setDataInCache(forKey: "key_1", strategy: .justAsync)
        XCTAssertTrue(_cacheManager.exist(forKey: "key_1"))
        setDataInCache(forKey: "key_2", strategy: .asyncOrCache)
        XCTAssertTrue(_cacheManager.exist(forKey: "key_2"))
        setDataInCache(forKey: "key_3", strategy: .cacheThenAsync)
        XCTAssertTrue(_cacheManager.exist(forKey: "key_3"))
        setDataInCache(forKey: "key_4", strategy: .cacheOrAsync)
        XCTAssertTrue(_cacheManager.exist(forKey: "key_4"))
    }
    
    func testGetKeyValueFromCache() {
        getDataFromCache(forKey: "key_1")
        getDataFromCache(forKey: "key_2")
        getDataFromCache(forKey: "key_3")
        getDataFromCache(forKey: "key_4")
    }
    
    func testDeleteKey() {
        guard let _cacheManager = cacheManager else { return }
        
        _cacheManager.delete(forKey: "key_1")
        XCTAssertFalse(_cacheManager.exist(forKey: "key_1"))
        clearDatabase()
    }
    
    private func clearDatabase() {
        guard let _cacheManager = cacheManager else { return }
        
        _cacheManager.clear()
        XCTAssertFalse(_cacheManager.exist(forKey: "key_2"))
    }
    
    private func setDataInCache(forKey key: String, strategy: CacheStrategy) {
        guard let _cacheManager = cacheManager, let _bag = bag else { return }
        
        let expectation = XCTestExpectation(description: "Download data from cache with key \(key)")
        
        _cacheManager.fromKey(key: key)
            .withAsync(Single.just("Data for key \(key) is saved"))
            .withStrategy(strategy)
            .fetch()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (result) in
                print("Data is created for key \(key)")
            }, onError: { (error) in
                print("[ERROR] Cannot add the key with error \(error)")
                XCTAssert(false)
            }, onCompleted: {
                expectation.fulfill()
            })
            .disposed(by: _bag)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    private func getDataFromCache(forKey key: String) {
        guard let _cacheManager = cacheManager, let _bag = bag else { return }
        
        _cacheManager.fromKey(key: key)
            .withAsync(Single.just(String()))
            .withStrategy(.justCache)
            .fetch()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (keyValue) in
                XCTAssert(keyValue == "Data for key \(key) is saved")
            }, onError: { (error) in
                print("[ERROR] Cannot retrieve the key value with error \(error)")
                XCTAssert(false)
            })
            .disposed(by: _bag)
    }
}
