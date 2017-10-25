//
//  Protocol.swift
//  Runtime
//
//  Created by Tanner on 10/18/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

import Foundation

public class Protocol: Hashable {
    public let name: String
    public let methods: [Method]

    public init(name: String, methods: [Method]) {
        self.name = name
        self.methods = methods
    }

    public var hashValue: Int {
        return self.name.hashValue
    }

    public static func ==(lhs: Protocol, rhs: Protocol) -> Bool {
        return lhs.name == rhs.name
    }
}

public extension Protocol {
    static var protocolList: [Protocol] = []

    public static func named(_ name: String) -> Protocol! {
        return Protocol.protocolList.filter { $0.name == name }.first
    }
}
