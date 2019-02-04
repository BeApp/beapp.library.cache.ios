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
    
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveDataToCache()
    }
    
    func saveDataToCache() {
        let singleEmail = Single.just("Test BeappCache")
        
        let observer = RxCacheManager.shared.fromKey(key: "test_beappCache")
            .withAsync(singleEmail)
            .withStrategy(.justAsync)
            .fetch()
        
        observer
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (email) in
                print(email)
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: bag)
    }
}

