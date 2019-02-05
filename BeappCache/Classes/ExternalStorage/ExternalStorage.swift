//
//  ExternalStorage.swift
//  BeappCache
//
//  Created by Antoine Richeux on 04/02/2019.
//

import Foundation
import RxSwift

protocol ExternalStorageProtocol {
    func count() -> Int
    func exist(forKey key: String) -> Bool
    func get<T>(forKey key: String, of type: T.Type) -> CacheWrapper<T>? where T: Codable
    func put<T>(data: CacheWrapper<T>, forKey key: String) -> Bool where T: Codable
    func delete(forKey key: String) -> Bool
    func clear()
}

public enum ExternalStorageEnum {
    case Cache
    case CoreData
    
    var storage: ExternalStorageProtocol {
        switch self {
        case .Cache:
            return CacheStorage()

        case .CoreData:
            return CoreDataStorage()
        }
    }
}
