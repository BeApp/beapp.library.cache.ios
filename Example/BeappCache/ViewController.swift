//
//  ViewController.swift
//  BeappCache
//
//  Created by aricheux on 02/04/2019.
//  Copyright (c) 2019 aricheux. All rights reserved.
//

import UIKit
import BeappCache
import RxSwift

class ViewController: UIViewController {
    
    // MARK: - Variables
    let bag = DisposeBag()
    let rxCacheManager = RxCacheManager(verbose: true)
    let singleString = Single.just("Test to save data with Cache library")
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        asyncRequestOrCache()
        justAsyncRequest()
        getDataFromCache()
    }
    
    // MARK: - Local functions
    
    /// Call async request or get data from cache if present
    func asyncRequestOrCache() {
        rxCacheManager.fromKey(key: "key_xxx")
            .withAsync(singleString)
            .withStrategy(.asyncOrCache)
            .fetch()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (_) in
                print("Success async request or data from cache")
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: bag)
    }
    
    /// Call only async request
    func justAsyncRequest() {
        rxCacheManager.fromKey(key: "key_xxx")
            .withAsync(singleString)
            .withStrategy(.justAsync)
            .fetch()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (_) in
                print("Success async request")
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: bag)
    }
    
    /// Onlye get data from cache if present
    func getDataFromCache() {
        rxCacheManager.fromKey(key: "key_xxx")
            .withAsync(singleString)
            .withStrategy(.justCache)
            .fetch()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (_) in
                print("Success to get data from cache")
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: bag)
    }
    
}

