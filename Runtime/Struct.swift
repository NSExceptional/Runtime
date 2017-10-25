//
//  Struct.swift
//  Runtime
//
//  Created by Tanner on 10/18/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

import Foundation

/// As of now, purely for metadata purposes.
/// Provides no way to create and use structs.
/// It may make more sense just to use standard Swift structs
/// alongside instances of `Struct` for reflection purposes.
public class Struct {
    let name: String
    let instanceSize: Int

    let ivars: [Ivar]
    let methods: [Method]
    let properties: [Property]

    public init(name: String, instanceSize: Int, ivars: [Ivar.Stub] = [], methods: [Method] = [], properties: [Property] = []) {
        self.name = name
        self.instanceSize = instanceSize
        self.ivars = Ivar.make(from: ivars, 0)
        self.methods = methods
        self.properties = properties
    }
}

public extension Struct {
    static var structList: [Struct] = []

    public static func named(_ name: String) -> Struct! {
        return Struct.structList.filter { $0.name == name }.first
    }
}

public extension Struct {
    public var describedAsTuple: String {
        return "(" + self.ivars.map({ ivar in
            if !ivar.name.isEmpty {
                return ivar.name + ": " + ivar.type.description
            } else {
                return ivar.type.description
            }
        }).joined(separator: ", ")
    }

    public var typeEncoding: String {
        return ""
    }
}
