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
            print("[BeappCache] [ERROR] cannot with init of CacheStorage")
        }
    }
}

// MARK: - ExternalStorageProtocol
extension CacheStorage: ExternalStorageProtocol {
    
    func count() -> Int {
        return 0
    }
    
    func exist(forKey key: String) throws -> Bool {
        guard let _storage = storage else { return false }
        
        return try _storage.existsObject(forKey: key)
    }
    
    func get<T>(forKey key: String, of type: T.Type) throws -> CacheWrapper<T>? where T : Decodable, T : Encodable {
        guard let _storage = storage else { return nil }
        
        return try _storage.transformCodable(ofType: CacheWrapper<T>.self).object(forKey: key)
    }
    
    func put<T>(data: CacheWrapper<T>, forKey key: String) throws where T : Decodable, T : Encodable {
        try storage?.transformCodable(ofType: CacheWrapper.self).setObject(data, forKey: key)
    }
    
    func delete(forKey key: String) throws {
        try storage?.removeObject(forKey: key)
    }
    
    func clear() throws {
        try storage?.removeAll()
    }
}
