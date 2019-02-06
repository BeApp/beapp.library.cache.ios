//
//  CacheStorage.swift
//  BeappCache
//
//  Created by Antoine Richeux on 04/02/2019.
//

import Foundation
import Cache

class CacheStorage: ExternalStorageProtocol {
    static let shared = CacheStorage()
    
    var storage: Storage<DummyCodable>?
    
    init() {
        let diskConfig = DiskConfig(name: "Floppy")
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
        do {
            storage = try Storage(
                diskConfig: diskConfig,
                memoryConfig: memoryConfig,
                transformer: TransformerFactory.forCodable(ofType: DummyCodable.self)
            )
        } catch {
            print("[ERROR] cannot with init of CacheStorage")
        }
    }
    
    func count() -> Int {
        return 0
    }
    
    func exist(forKey key: String) -> Bool {
        do {
            return try storage?.existsObject(forKey: key) ?? false
        } catch {
            print("[ERROR] cannot know if key \(key) exist with \(error)")
            return false
        }
    }
    
    func get<T>(forKey key: String, of type: T.Type) -> CacheWrapper<T>? where T : Decodable, T : Encodable {
        guard let _storage = storage else {
            return nil
        }
        
        do {
            return try _storage.transformCodable(ofType: CacheWrapper<T>.self).object(forKey: key)
        } catch {
            print("[ERROR] cannot get storage from Cache")
            return nil
        }
    }
    
    func put<T>(data: CacheWrapper<T>, forKey key: String) -> Bool where T : Decodable, T : Encodable {
        do {
            try storage?.transformCodable(ofType: CacheWrapper.self).setObject(data, forKey: key)
            return true
        } catch {
            return false
        }
    }
    
    func delete(forKey key: String) {
        do {
            try storage?.removeObject(forKey: key)
        } catch {
            print("[ERROR] cannot delete cache for key \(key) with \(error)")
        }
    }
    
    func clear() {
        do {
            try storage?.removeAll()
        } catch {
            print("[ERROR] cannot clear cache with \(error)")
        }
    }
}
