//
//  Log.swift
//  BeappCache
//
//  Created by Antoine Richeux on 06/02/2019.
//

import Foundation

class Log {
    var verbose: Bool
    
    init(verbose: Bool) {
        self.verbose = verbose
    }
    
    func printLog(type: String, message: String) {
        if verbose {
            print("[BeappCache] [\(type)] \(message)")
        }
    }
}
