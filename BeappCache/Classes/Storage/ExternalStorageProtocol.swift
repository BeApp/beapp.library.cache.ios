//
//  ExternalStorageProtocol.swift
//  BeappCache
//
//  Created by Cedric G on 06/02/2019.
//

import Foundation

public protocol ExternalStorageProtocol {
    func count() -> Int
    func exist(forKey key: String) -> Bool
    func get<T>(forKey key: String, of type: T.Type) -> CacheWrapper<T>? where T: Codable
    func put<T>(data: CacheWrapper<T>, forKey key: String) -> Bool where T: Codable
    func delete(forKey key: String)
    func clear()
}
