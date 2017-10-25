//
//  Runtime.swift
//  Runtime
//
//  Created by Tanner on 10/18/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

import Foundation

public typealias id = Pointer<Object>
public typealias SEL = String
public typealias IMP = (_ self: id, _ _cmd: SEL, _ args: Any) -> Any

@inline(__always) func prepareMsg(_ target: id, _ _cmd: SEL, super: Bool) -> IMP {
    let isClass = Class.isClass(target)
    var cls: Class!
    if isClass {
        cls = `super` ? target|.isa.superclass! : target|.isa
    } else {
        cls = `super` ? target|.getClass.superclass! : target|.getClass
    }

    var imp: IMP!
    repeat {
        imp = cls.getMethodIMP(_cmd)
        cls = cls.superclass
    } while imp == nil && cls != nil
    
    guard imp != nil else {
        let isClass = Class.isClass(target)
        let invocation = (isClass ? "+" : "-") + "[\(target|.getClass.name) \(_cmd)]"
        fatalError("Unrecognized selector sent to instance \(target.raw): " + invocation)
    }

    return imp
}

/// Dynamically calls a method on a `Foo` instance given a method name (like objc_msgSend)
public func msgSend<T>(super: Bool = false, _ target: id, _ _cmd: SEL, _ args: Any = ()) -> T {
    let imp = prepareMsg(target, _cmd, super: `super`)
    return imp(target, _cmd, args) as! T
}

/// Convenience for `Void` or discardable results
public func _msgSend(super: Bool = false, _ target: id, _ _cmd: SEL, _ args: Any = ()) {
    let imp = prepareMsg(target, _cmd, super: `super`)
    _ = imp(target, _cmd, args)
}
