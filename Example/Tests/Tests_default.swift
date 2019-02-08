import XCTest
import BeappCache
import RxSwift

class Tests_default: XCTestCase {
    
    var bag: DisposeBag?
    var cacheManager: RxCacheManager?
    
    override func setUp() {
        super.setUp()

        bag = DisposeBag()
        cacheManager = RxCacheManager()
        clearDatabase()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateKeyInCache() {
        guard let _cacheManager = cacheManager else { XCTAssert(false) }
        
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
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
