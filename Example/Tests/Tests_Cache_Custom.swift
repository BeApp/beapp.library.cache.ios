//
//  Tests_Cache_Custom.swift
//  BeappCache_Tests
//
//  Created by Antoine Richeux on 08/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import Cache
import BeappCache

class Tests_Cache_Custom: XCTestCase {
    
    var xcCache: XCCache!
    
    override func setUp() {
        super.setUp()
        
        let diskConfig = DiskConfig(name: "BeappCache")
        let memoryConfig = MemoryConfig(expiry: .date(Date().addingTimeInterval(3600 * 24)), countLimit: 20, totalCostLimit: 20)
        let cacheConfig = CacheStorageConfig(diskConfig: diskConfig, memoryConfig: memoryConfig)
        xcCache = XCCache(cacheManager: RxCacheManager(storageType: .cache(config: cacheConfig), verbose: true))
    }
    
    func testCreateKeyInCache() {
        xcCache.setDataInCache(forKey: "key_1", strategy: .justAsync) {
            XCTAssertTrue(self.xcCache.exist(forKey: "key_1"))
        }
        
        xcCache.setDataInCache(forKey: "key_2", strategy: .asyncOrCache) {
            XCTAssertTrue(self.xcCache.exist(forKey: "key_2"))
        }
        
        xcCache.setDataInCache(forKey: "key_3", strategy: .cacheThenAsync) {
            XCTAssertTrue(self.xcCache.exist(forKey: "key_3"))
        }
    }
    
    func testGetKeyValueFromCache() {
        xcCache.getDataFromCache(forKey: "key_1") { (keyValue) in
            XCTAssert(keyValue == "Data for key key_1 is saved")
        }
        xcCache.getDataFromCache(forKey: "key_2") { (keyValue) in
            XCTAssert(keyValue == "Data for key key_2 is saved")
        }
        xcCache.getDataFromCache(forKey: "key_3") { (keyValue) in
            XCTAssert(keyValue == "Data for key key_3 is saved")
        }
        xcCache.getDataFromCache(forKey: "key_4") { (keyValue) in
            XCTAssert(keyValue == "Data for key key_4 is saved")
        }
    }
    
    func testDeleteKey() {
        xcCache.delete(forKey: "key_1")
        XCTAssertFalse(xcCache.exist(forKey: "key_1"))
        xcCache.clear()
        XCTAssertFalse(xcCache.exist(forKey: "key_2"))
    }
}
