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
        var expectArray = [XCTestExpectation]()
        for i in 1...4 {
            expectArray.append(XCTestExpectation(description: "save key_\(i)"))
        }
        
        xcCache.setDataInCache(forKey: "key_1", strategy: .justAsync) {
            XCTAssert(self.xcCache.exist(forKey: "key_1"))
            expectArray[0].fulfill()
        }
        
        xcCache.setDataInCache(forKey: "key_2", strategy: .asyncOrCache) {
            XCTAssert(self.xcCache.exist(forKey: "key_2"))
            expectArray[1].fulfill()
        }
        
        xcCache.setDataInCache(forKey: "key_3", strategy: .cacheThenAsync) {
            XCTAssert(self.xcCache.exist(forKey: "key_3"))
            expectArray[2].fulfill()
        }
        
        xcCache.setDataInCache(forKey: "key_4", strategy: .cacheOrAsync) {
            XCTAssert(self.xcCache.exist(forKey: "key_4"))
            expectArray[3].fulfill()
        }
        
        wait(for: [expectArray[0], expectArray[1], expectArray[2], expectArray[3]], timeout: 5.0)
        
        getKeyValueFromCache()
    }
    
    func getKeyValueFromCache() {
        var expectArray = [XCTestExpectation]()
        for i in 1...4 {
            expectArray.append(XCTestExpectation(description: "get key_\(i)"))
        }
        
        xcCache.getDataFromCache(forKey: "key_1") { (keyValue) in
            print(keyValue)
            XCTAssertTrue(keyValue == "Data for key key_1 is saved")
            expectArray[0].fulfill()
        }
        xcCache.getDataFromCache(forKey: "key_2") { (keyValue) in
            print(keyValue)
            XCTAssertTrue(keyValue == "Data for key key_2 is saved")
            expectArray[1].fulfill()
        }
        xcCache.getDataFromCache(forKey: "key_3") { (keyValue) in
            print(keyValue)
            XCTAssertTrue(keyValue == "Data for key key_3 is saved")
            expectArray[2].fulfill()
        }
        xcCache.getDataFromCache(forKey: "key_4") { (keyValue) in
            print(keyValue)
            XCTAssertTrue(keyValue == "Data for key key_4 is saved")
            expectArray[3].fulfill()
        }
        
        wait(for: [expectArray[0], expectArray[1], expectArray[2], expectArray[3]], timeout: 5.0)
        
        deleteKey()
    }
    
    func deleteKey() {
        xcCache.delete(forKey: "key_1")
        XCTAssertFalse(xcCache.exist(forKey: "key_1"))
        xcCache.clear()
        XCTAssertFalse(xcCache.exist(forKey: "key_2"))
    }
}
