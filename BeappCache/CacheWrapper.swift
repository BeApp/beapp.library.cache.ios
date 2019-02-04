//
//  MCacheWrapper.swift
//  BeappCache
//
//  Created by Anthony Dudouit on 01/08/2018.
//  Copyright © 2018 Cedric G. All rights reserved.
//

import Foundation

public struct CacheWrapper<T>: Codable where T: Codable {
	let date: Date
	let data: T
}
