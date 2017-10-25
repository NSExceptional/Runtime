//
//  Ivar.swift
//  Runtime
//
//  Created by Tanner on 10/18/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

import Foundation

public struct Ivar: Hashable {
    public typealias Stub = (name: String, type: Type)
    
    public let name: String
    public let type: Type
    public let offset: Int

    public var hashValue: Int {
        return self.name.hashValue
    }

    public static func ==(lhs: Ivar, rhs: Ivar) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Ivar {
    static func make(from stubs: [Stub], _ offset: Int) -> [Ivar] {
        var offsett = offset
        return stubs.map { stub -> Ivar in
            defer { offsett += stub.type.size }
            return Ivar(name: stub.name, type: stub.type, offset: offsett)
        }
    }
}
