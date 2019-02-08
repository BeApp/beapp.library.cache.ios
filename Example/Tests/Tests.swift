import XCTest
import BeappCache
import RxSwift

class Tests: XCTestCase {
    
    let bag = DisposeBag()
    let cacheManager = RxCacheManager()
    
    override func setUp() {
        super.setUp()

        clearDatabase()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateKeyInCache() {
        setDataInCache(forKey: "key_1", strategy: .justAsync)
        XCTAssertTrue(cacheManager.exist(forKey: "key_1"))
        setDataInCache(forKey: "key_2", strategy: .asyncOrCache)
        XCTAssertTrue(cacheManager.exist(forKey: "key_2"))
        setDataInCache(forKey: "key_3", strategy: .cacheThenAsync)
        XCTAssertTrue(cacheManager.exist(forKey: "key_3"))
        setDataInCache(forKey: "key_4", strategy: .cacheOrAsync)
        XCTAssertTrue(cacheManager.exist(forKey: "key_4"))
    }

    func testGetKeyValueFromCache() {
        getDataFromCache(forKey: "key_1")
        getDataFromCache(forKey: "key_2")
        getDataFromCache(forKey: "key_3")
        getDataFromCache(forKey: "key_4")
    }
    
    func testDeleteKey() {
        cacheManager.delete(forKey: "key_1")
        XCTAssertFalse(cacheManager.exist(forKey: "key_1"))
        clearDatabase()
    }

    private func clearDatabase() {
        cacheManager.clear()
        XCTAssertFalse(cacheManager.exist(forKey: "key_2"))
    }
    
    private func setDataInCache(forKey key: String, strategy: CacheStrategy) {
        let expectation = XCTestExpectation(description: "Download data from cache with key \(key)")
        
        cacheManager.fromKey(key: key)
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
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    private func getDataFromCache(forKey key: String) {
        cacheManager.fromKey(key: key)
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
            .disposed(by: bag)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
