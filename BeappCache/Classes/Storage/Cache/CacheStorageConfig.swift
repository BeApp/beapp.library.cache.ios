//
//  CacheStorageConfig.swift
//  BeappCache
//
//  Created by Cedric G on 06/02/2019.
//

import Foundation
import Cache

public struct CacheStorageConfig {
    var diskConfig: DiskConfig = DiskConfig(name: "Floppy")
    var memoryConfig: MemoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    
    public init() { }
    
    public init(diskConfig: DiskConfig, memoryConfig: MemoryConfig) {
        self.init()
        
        self.diskConfig = diskConfig
        self.memoryConfig = memoryConfig
    }
}
