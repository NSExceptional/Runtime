//
//  Platform.swift
//  Runtime
//
//  Created by Tanner on 10/18/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

import Foundation

struct Platform {
    static let is64Bit = MemoryLayout<Int>.size == MemoryLayout<Int64>.size
}
