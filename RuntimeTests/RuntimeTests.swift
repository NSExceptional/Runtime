//
//  RuntimeTests.swift
//  RuntimeTests
//
//  Created by Tanner on 10/19/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

import XCTest
@testable import Runtime

class Tests: XCTestCase {
    typealias id = Runtime.id

    override func setUp() {
        // Runtime initialization
        _ = RootObject.class
        _ = Person.class
    }

    func testPerson() {
        let bob: id = msgSend(Person.class.createInstance(), "init")
        let name: String = msgSend(bob, "name")
        let age: Int = msgSend(bob, "age")
        let description: String = msgSend(bob, "description")
        XCTAssertEqual("Bob", name)
        XCTAssertEqual(18, age)
        XCTAssert(description.hasPrefix("\(bob)"))
    }

    func testPointerAssumptions() {
        class Foo {
            struct Layout {
                let magic: (isa: Int, refCount: Int)
                let count: Int
            }
            let count = 0x72656E6E6174
            public init() {}
        }

        var instance = Foo()
        let bitcast = unsafeBitCast(instance, to: Pointer<Foo.Layout>.self)
        let unsafe = withUnsafePointer(to: &instance, { $0 })

        XCTAssertEqual(bitcast|.count, unsafe.pointee.count)
    }

    func testClassObjectReferencing() {
        var cls = Class.named("Object")!
        XCTAssert(cls === RootObject.class)

        let ptr: Pointer<Class> = |cls
        let unsafePtr = withUnsafePointer(to: &cls, { $0 })

        XCTAssertEqual(cls.name, ptr|.name)
        XCTAssertEqual(ptr.raw.debugDescription, unsafePtr.debugDescription)

        var asObject: id = ~cls
        asObject += 16
        XCTAssertEqual(cls.name, ptr|.name)

        let ref = cls.ref
        XCTAssertEqual(asObject, ref)
        XCTAssert(ref|.isa === RootObject_meta.class)
    }

    func testCreateClass() {
        XCTAssertNil(Class.named("Foo"))
        var counter = 0

        let builder = ClassBuilder(name: "Foo")!
        let initializer = Method("init", returns: .object("self")) { this, _cmd, args in
            func init$(_ this: id, _ _cmd: SEL) -> id {
                let this: id = msgSend(super: true, this, _cmd)
                counter += 1
                return this
            }

            return init$(this, _cmd)
        }
        let method = Method("getClassName", returns: .string) { this, _cmd, args in
            func getClassName$(_ this: id, _ _cmd: SEL) -> String {
                return this|.getClass.name
            }

            return getClassName$(this, _cmd)
        }
        builder.add([initializer, method])

        let classMethod = Method("instanceCount", returns: .integer) { this, _cmd, args in
            func instanceCount$(_ this: id, _ _cmd: SEL) -> Int {
                return counter
            }

            return instanceCount$(this, _cmd)
        }
        builder.add([classMethod], toClass: true)
        let created = builder.finalize()
        let asObject = created.ref // TODO: Make this not necessary

        XCTAssert(created === Class.named("Foo"))
        XCTAssertEqual(0, msgSend(asObject, "instanceCount"))

        _msgSend(created.createInstance(), "init")
        XCTAssertEqual(1, msgSend(asObject, "instanceCount"))
    }
}












