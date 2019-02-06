//
//  CacheStorage.swift
//  BeappCache
//
//  Created by Antoine Richeux on 04/02/2019.
//

import Foundation
import Cache

class CacheStorage {
    
    private var storage: Storage<DummyCodable>?
    
    private var config: CacheStorageConfig!
    
    private init() { }
    
    convenience init(_ cacheConfig: CacheStorageConfig) {
        self.init()
        config = cacheConfig
        initStorage()
    }
    
    private func initStorage() {
        do {
            storage = try Storage(
                diskConfig: config.diskConfig,
                memoryConfig: config.memoryConfig,
                transformer: TransformerFactory.forCodable(ofType: DummyCodable.self)
            )
        } catch {
            print("[BeappCache][ERROR] cannot with init of CacheStorage")
        }
    }
}

// MARK: - ExternalStorageProtocol
extension CacheStorage: ExternalStorageProtocol {
    
    func count() -> Int {
        return 0
    }
    
    func exist(forKey key: String) throws -> Bool {
        return try storage?.existsObject(forKey: key) ?? false
    }
    
    func get<T>(forKey key: String, of type: T.Type) throws -> CacheWrapper<T>? where T : Decodable, T : Encodable {
        guard let _storage = storage else {
            return nil
        }
        
        do {
            return try _storage.transformCodable(ofType: CacheWrapper<T>.self).object(forKey: key)
        } catch {
            print("[BeappCache][ERROR] cannot get storage from Cache")
            return nil
        }
    }
    
    func put<T>(data: CacheWrapper<T>, forKey key: String) throws where T : Decodable, T : Encodable {
        try storage?.transformCodable(ofType: CacheWrapper.self).setObject(data, forKey: key)
    }
    
    func delete(forKey key: String) throws {
        do {
            try storage?.removeObject(forKey: key)
        } catch {
            print("[ERROR] cannot delete cache for key \(key) with \(error)")
        }
    }
    
    func clear() throws {
        do {
            try storage?.removeAll()
        } catch {
            print("[ERROR] cannot clear cache with \(error)")
        }
    }
}
