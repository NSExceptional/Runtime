//
//  ClassBuilder.swift
//  Runtime
//
//  Created by Tanner on 10/21/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

import Foundation

public class ClassBuilder {
    public var superclass: Class?
    public var name: String
    public var extraBytes: Int

    private var final = false
    private var methods: OrderedSet<Method> = []
    private var classMethods: OrderedSet<Method> = []
    private var ivars: OrderedSet<IvarStub> = []
    private var properties: OrderedSet<Property> = []
    private var classProperties: OrderedSet<Property> = []
    private var protocols: OrderedSet<Protocol> = []

    /// - Warning: returns nil if a class with the given name already exists.
    public init?(name: String, superclass: Class? = RootObject.class, extraBytes: Int = 0) {
        if Class.named(name) != nil {
            return nil
        }

        self.superclass = superclass
        self.name = name
        self.extraBytes = extraBytes
    }

    /// Actually creates the class and adds it to the runtime.
    ///
    /// The class you are constructing cannot be used until it is finalized.
    /// - Returns: The newly created class.
    public func finalize() -> Class {
        let metaclass = Class(
            isa: nil,
            superclass: self.superclass?.isa,
            name: self.name + ".meta",
            ivars: [],
            methods: self.classMethods.array,
            properties: self.classProperties.array,
            protocols: []
        )
        let cls = Class(
            isa: metaclass,
            superclass: self.superclass,
            name: self.name,
            ivars: self.ivars.array.map({ $0.stub }),
            methods: self.methods.array,
            properties: self.properties.array,
            protocols: self.protocols.array,
            extraBytes: self.extraBytes
        )

        self.final = true
        Class.classList.append(cls)
        return cls
    }

    public func add(_ methods: [Method], toClass: Bool = false) {
        if toClass {
            self.classMethods.addAll(methods)
        } else {
            self.methods.addAll(methods)
        }
    }

    public func add(_ ivars: [IvarStub]) {
        self.ivars.addAll(ivars)
    }

    public func add(_ properties: [Property], toClass: Bool = false) {
        if toClass {
            self.classProperties.addAll(properties)
        } else {
            self.properties.addAll(properties)
        }
    }

    public func add(_ protocols: [Protocol]) {
        self.protocols .addAll(protocols)
    }

    public struct IvarStub: Hashable {
        let name: String
        let type: Type

        fileprivate var stub: Ivar.Stub { return (name, type) }

        public var hashValue: Int {
            return self.name.hashValue
        }

        public static func ==(lhs: IvarStub, rhs: IvarStub) -> Bool {
            return lhs.name == rhs.name
        }
    }
}
