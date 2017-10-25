//
//  Object.swift
//  Runtime
//
//  Created by Tanner on 10/18/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

import Foundation

public struct Object {
    var isa: Class!

    public var getClass: Class {
        return self.isa
    }

    public func respondsTo(_ selector: SEL) -> Bool {
        return self.isa.getMethodIMP(selector) != nil
    }
}

extension Pointer: CustomStringConvertible, CustomDebugStringConvertible {
    public var debugDescription: String { return self.description }
    public var description: String {
        if Pointee.self is Object.Type {
            let this: id = ~self
            if this|.respondsTo("description") {
                return msgSend(this, "description")
            } else {
                return "<\(this|.getClass) \(self.raw.debugDescription)>"
            }
        }

        return self.raw.debugDescription
    }
}
