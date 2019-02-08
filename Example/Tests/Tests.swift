import XCTest
import BeappCache
import RxSwift

class Tests: XCTestCase {
    
    let bag = DisposeBag()
    let cacheManager = RxCacheManager()
    
    override func setUp() {
        super.setUp()

        cacheManager.clear()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_a_CreateKeyInCache() {
        setDataInCache(forKey: "key_1", strategy: .justAsync)
        setDataInCache(forKey: "key_2", strategy: .asyncOrCache)
        setDataInCache(forKey: "key_3", strategy: .cacheThenAsync)
        setDataInCache(forKey: "key_4", strategy: .cacheOrAsync)
    }

    func test_c_GetKeyValueFromCache() {
        getDataFromCache(forKey: "key_1")
        getDataFromCache(forKey: "key_2")
        getDataFromCache(forKey: "key_3")
        getDataFromCache(forKey: "key_4")
    }
    
    func test_d_DeleteKey() {
        cacheManager.delete(forKey: "key_1")
        XCTAssertFalse(cacheManager.exist(forKey: "key_1"))
    }

    func test_e_ClearDatabase() {
        cacheManager.clear()
        XCTAssertFalse(cacheManager.exist(forKey: "key_2"))
    }
    
    private func setDataInCache(forKey key: String, strategy: CacheStrategy) {
        cacheManager.fromKey(key: key)
            .withAsync(Single.just("Data for key \(key) is saved"))
            .withStrategy(strategy)
            .fetch()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (result) in
                XCTAssertTrue(self.cacheManager.exist(forKey: key))
                XCTAssert(true)
                print("Data is created for key \(key)")
            }, onError: { (error) in
                print("[ERROR] Cannot add the key with error \(error)")
                XCTAssert(false)
            })
            .disposed(by: bag)
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
    
}
