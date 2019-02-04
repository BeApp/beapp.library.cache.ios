//
//  ExternalStorage.swift
//  BeappCache
//
//  Created by Antoine Richeux on 04/02/2019.
//

import Foundation
import RxSwift

protocol ExternalStorageProtocol {
    func getCacheWrapper<T>(key: String, of type: T.Type) -> CacheWrapper<T>? where T: Codable
    func setCacheData<T>(data: CacheWrapper<T>, for key: String) -> Bool where T: Codable
}

public enum ExternalStorageEnum {
    case Cache
    case CoreData
    
    var storage: ExternalStorageProtocol {
        return CacheStorage()
    }
}
