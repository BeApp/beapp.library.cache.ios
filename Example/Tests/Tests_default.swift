import XCTest
import BeappCache

class Tests_default: XCTestCase {
    
    var xcCache: XCCache!
    
    override func setUp() {
        super.setUp()
        
        xcCache = XCCache(cacheManager: RxCacheManager(verbose: true))
        xcCache.clear()
    }
    
    func testCreateKeyInCache() {
        xcCache.setDataInCache(forKey: "key_1", strategy: .justAsync) { (status) in
            if status {
                XCTAssertTrue(self.xcCache.exist(forKey: "key_1"))
            } else {
                XCTAssert(false)
            }
        }
        
        xcCache.setDataInCache(forKey: "key_2", strategy: .asyncOrCache) { (status) in
            if status {
                XCTAssertTrue(self.xcCache.exist(forKey: "key_2"))
            } else {
                XCTAssert(false)
            }
        }
        
        xcCache.setDataInCache(forKey: "key_3", strategy: .cacheThenAsync) { (status) in
            if status {
                XCTAssertTrue(self.xcCache.exist(forKey: "key_3"))
            } else {
                XCTAssert(false)
            }
        }
        
        xcCache.setDataInCache(forKey: "key_4", strategy: .cacheOrAsync) { (status) in
            if status {
                XCTAssertTrue(self.xcCache.exist(forKey: "key_4"))
            } else {
                XCTAssert(false)
            }
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
