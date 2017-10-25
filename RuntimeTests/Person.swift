//
//  Person.swift
//  RuntimeTests
//
//  Created by Tanner on 10/19/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

@testable import Runtime

infix operator |=
infix operator |

/// Example subclass of RootObject.
struct Person {
    static let `class` = Class(
        isa: Person_meta.class,
        superclass: RootObject.class,
        name: "Person",
        ivars: [
            (name: "_name", type: .string),
            (name: "_age", type: .integer)
        ],
        methods: [_init, name, setName_, age, setAge_, description],
        properties: [
            Property(name: "name", getter: name, setter: setName_),
            Property(name: "age", getter: age, setter: setAge_),
        ],
        protocols: []
    )

    static var _init = Method("init", returns: .object("self")) { this, _cmd, args in
        func init$(_ this: id, _ _cmd: SEL) -> id {
            _msgSend(this, "setName_", ("Bob"))
            _msgSend(this, "setAge_", (18))
            print("init override: \(this)")

            return msgSend(super: true, this, _cmd)
        }

        return init$(this, _cmd)
    }

    static var name = Method("name", returns: .string) { this, _cmd, args in
        func name$(_ this: id, _ _cmd: SEL) -> String {
            return this|"_name"
        }

        return name$(this, _cmd)
    }

    static var setName_ = Method("setName_", args: [.string]) { this, _cmd, args in
        func setName$(_ this: id, _ _cmd: SEL, _ name: String) {
            this |= (name, "_name")
        }

        let args = (args as! (String))
        setName$(this, _cmd, args)
        return ()
    }

    static var age = Method("age", returns: .string) { this, _cmd, args in
        func age$(_ this: id, _ _cmd: SEL) -> Int {
            return this|"_age"
        }

        return age$(this, _cmd)
    }

    static var setAge_ = Method("setAge_", args: [.string]) { this, _cmd, args in
        func setName$(_ this: id, _ _cmd: SEL, _ age: Int) {
            this |= (age, "_age")
        }

        let args = (args as! (Int))
        setName$(this, _cmd, args)
        return ()
    }

    static var description = Method("description", returns: .string) { this, _cmd, args in
        func description$(_ this: id, _ _cmd: SEL) -> String {
            let name: String = msgSend(this, "name")
            let age: Int = msgSend(this, "age")
            return """
                   <\(this|.getClass) \(this.raw.debugDescription)> {
                       name: \(name),
                       age: \(age)
                   }
                   """
        }

        return description$(this, _cmd)
    }
}

private struct Person_meta {
    static let `class` = Class(
        isa: nil,
        superclass: nil,
        name: "Person.meta",
        ivars: [],
        methods: [],
        properties: [],
        protocols: []
    )
}

/// For debugging purposes
/// unsafeBitCast(this, to: UnsafePointer<person_>.self).pointee
struct person_ {
    let isa: Class
    let _retainCount: Int
    let _name: String
    let _age: Int
}
