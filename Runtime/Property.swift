//
//  Property.swift
//  Runtime
//
//  Created by Tanner on 10/18/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

import Foundation

public struct Property: Hashable, Equatable {
    public let name: String
    public let getter: Method
    public let setter: Method!

    public var type: Type {
        return self.getter.returnType
    }

    public var hashValue: Int {
        return self.name.hashValue
    }

    public static func ==(lhs: Property, rhs: Property) -> Bool {
        return lhs.name == rhs.name
    }
}
