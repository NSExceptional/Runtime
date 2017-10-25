//
//  RootObject.swift
//  Runtime
//
//  Created by Tanner on 10/19/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

import Foundation

/// New classes are defined as static instances within an extension on Class itself.
/// Methods, ivars, properties, etc for these new classes are defined as below.
public struct RootObject {
    static let `class` = Class(
        isa: RootObject_meta.class,
        superclass: nil,
        name: "Object",
        ivars: [("isa", .pointer(.class("self"))), ("_retainCount", .integer)],
        methods: [_init, retain, retainCount]
    )

    static var _init = Method("init", returns: .object("self")) { this, _cmd, args in
        func init$(_ this: id, _ _cmd: SEL) -> id {
            print("\(this|.getClass).init(): \(this)")
            return this
        }

        return init$(this, _cmd)
    }

    static var retain = Method("retain", returns: .object("self")) { this, _cmd, args in
        func retain$(_ this: id, _ _cmd: SEL) -> id {
            let newCount: Int = (this|"_retainCount") + 1
            this |= (newCount, "_retainCount")
            return this
        }

        return retain$(this, _cmd)
    }

    static var release = Method("release") { this, _cmd, args in
        func release$(_ this: id, _ _cmd: SEL) {
            let newCount: Int = (this|"_retainCount") - 1
            this |= (newCount, "_retainCount")
            if newCount < 1 {
                if newCount < 0 {
                    fatalError("Over-released object at \(this.raw.debugDescription)")
                }
                
                this.free()
            }
        }

        release$(this, _cmd)
        return ()
    }

    static var retainCount = Method("retainCount", returns: .integer) { this, _cmd, args in
        func retainCount$(_ this: id, _ _cmd: SEL) {
            return this|"_retainCount"
        }

        retainCount$(this, _cmd)
        return ()
    }
}

public struct RootObject_meta {
    static let `class` = Class(
        isa: nil,
        superclass: nil,
        name: "Object.meta"
    )
}
