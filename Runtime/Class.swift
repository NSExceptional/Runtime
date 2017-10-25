//
//  Class.swift
//  Runtime
//
//  Created by Tanner on 10/18/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

import Foundation

public class Class {
    public let isa: Class! // metaclass, nil for metaclasses
    let magic: UInt = 0xAAAABBBBCCCCDDDD // for debugging purposes, will be removed
    public let superclass: Class! // nil if no superclass
    public let name: String
    public let instanceSize: Int

    /// Instance class property-backing variables
    let ivars: [Ivar]
    /// Instance or class methods
    let methods: [SEL: Method]
    /// Instance or class properties
    let properties: [Property]
    /// Protocols conformed to by instances; not applicable to classes
    let protocols: [Protocol]

    private static let __swobjSize = 16
    /// Used to refer to the class as an object.
    /// Temporary workaround since class objects themselves
    /// already have an `isa` provided by Swift.
    public var ref: id {
        var ptr: id = ~self
        ptr += Class.__swobjSize
        return ptr
    }

    public init(isa: Class!, superclass: Class?, name: String,
        ivars stubs: [Ivar.Stub] = [], methods: [Method] = [], properties: [Property] = [], protocols: [Protocol] = [], extraBytes: Int = 0) {
        let offset = superclass?.instanceSize ?? Type.pointer(.class("")).size

        self.isa = isa
        self.superclass = superclass
        self.name = name
        self.instanceSize = offset + stubs.map { return $0.type.size }.reduce(0, +) + extraBytes

        self.ivars = Ivar.make(from: stubs, offset)
        self.properties = properties
        self.protocols = protocols
        self.methods = {
            var dict: [SEL: Method] = [:]
            for method in methods {
                dict[method.name] = method
            }

            return dict
        }()

        Class.classList.append(self)
    }

    public func createInstance() -> id {
        let instance = Pointer<Object>.calloc(self.instanceSize)
        instance.pointee.isa = self
        return instance
    }

    public func method(named: String) -> Method! {
        return self.methods[named]
    }

    public func ivar(named name: String) -> Ivar! {
        return self.ivars.filter { $0.name == name }.first
    }

    public func property(named  name: String) -> Property! {
        return self.properties.filter { $0.name == name }.first
    }

    public func conforms(to protocol: String) -> Bool {
        return !self.protocols.filter { $0.name == name }.isEmpty
    }

    public func getIvarOffset(_ name: String) -> Int! {
        return self.ivar(named: name)?.offset
    }

    public func getMethodIMP(_ sel: SEL) -> IMP? {
        return self.method(named: sel)?.imp
    }

    public static func isClass(_ object: id) -> Bool {
        if object|.isa == nil {
            // Metaclass.isa -> nil
            return true
        } else if object|.isa.isa == nil {
            // Class.isa -> metaclass.isa -> nil
            return true
        } else {
            // Object.isa -> Class.isa -> metaclass.isa -> nil
            return false
        }
    }
}

public extension Class {
    static var classList: [Class] = []

    public static func named(_ name: String) -> Class! {
        return Class.classList.filter { $0.name == name }.first
    }
}
