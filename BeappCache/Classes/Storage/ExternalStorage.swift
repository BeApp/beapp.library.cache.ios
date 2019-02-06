//
//  ExternalStorage.swift
//  BeappCache
//
//  Created by Antoine Richeux on 04/02/2019.
//

import Foundation
import RxSwift

public enum ExternalStorageEnum {
    case defaultCache
    case cache(config: CacheStorageConfig)
    case custom(storage: ExternalStorageProtocol)
    
    var storage: ExternalStorageProtocol {
        switch self {
        case .defaultCache: return CacheStorage(CacheStorageConfig())
        case .cache(let config): return CacheStorage(config)
        case .custom(let storage): return storage
        }
    }
}
