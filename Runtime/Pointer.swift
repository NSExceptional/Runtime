//
//  Pointer.swift
//  MirrorKit.swift
//
//  Created by Tanner on 8/25/17.
//

import Foundation

extension UnsafeMutableRawPointer {
    @inline(__always)
    init<T>(to thing: inout T) {
        self = withUnsafeMutablePointer(to: &thing) { UnsafeMutableRawPointer($0) }
    }
}

prefix operator ~
public prefix func ~<T,U>(thing: T) -> U {
    return unsafeBitCast(thing, to: U.self)
}

infix operator |=
/// Shorthand ivar set
public func |=<T>(pointer: id, change: (value: T, ivar: String)) {
    let offset = pointer|.getClass.getIvarOffset(change.ivar)!
    let pointer: Pointer<T> = ~pointer + offset
    pointer.pointee = change.value
}

infix operator |
/// Shorthand ivar get
public func |<T>(pointer: id, ivar: String) -> T {
    let offset = pointer|.getClass.getIvarOffset(ivar)!
    let ivarPtr: Pointer<T> = ~(pointer + offset)
    return ivarPtr.pointee
}

postfix operator |
/// Shorthand for .pointee
public postfix func |<T>(pointer: Pointer<T>) -> T {
    return pointer.pointee
}

prefix operator |
/// Shorthand for .pointee
@inline(__always)
public prefix func |<T>(pointee: inout T) -> Pointer<T> {
    return Pointer(to: &pointee)
}

public struct Pointer<Pointee>: Strideable, Hashable, Equatable {

    // MARK: Public

    public let raw: UnsafeMutableRawPointer
    public var pointee: Pointee {
        get { return self.read() }
        nonmutating set { return self.write(newValue) }
    }

    // Get a Pointer to some variable
    public init<T>(to thing: inout T) {
        self.raw = UnsafeMutableRawPointer(to: &thing)
    }

    // Convert some variable, which is already a "pointer" itself, into a Pointer
    public init(from pointer: inout Any) {
        self.raw = ~pointer
    }

    public func read<T>(byteOffset: Int = 0) -> T {
        return self.raw.load(fromByteOffset: byteOffset, as: T.self)
    }

    public func write<T>(_ value: T, byteOffset: Int = 0) {
        self.raw.storeBytes(of: value, toByteOffset: byteOffset, as: T.self)
    }

    // MARK: Memory management

    public static func alloc(_ count: Int) -> Pointer {
        return Pointer(raw: UnsafeMutablePointer.allocate(capacity: count))
    }

    public static func calloc(_ count: Int) -> Pointer {
        return Pointer(raw: Darwin.calloc(count, 5))
    }

    public func free(_ count: Int) {
        self.raw.deallocate(bytes: count, alignedTo: MemoryLayout<Pointee>.alignment)
    }

    // MARK: Private

    init(raw pointer: UnsafeMutableRawPointer) {
        self.raw = pointer
    }

    // MARK: Strideable

    public func distance(to other: Pointer) -> Int {
        return self.raw.distance(to: other.raw)
    }

    public func advanced(by n: Int) -> Pointer {
        return Pointer(raw: self.raw.advanced(by: n))
    }

    // MARK: Hashable

    public var hashValue: Int {
        return self.raw.hashValue
    }

    // MARK: Convenience

    public static func +(lhs: Pointer, rhs: Int) -> Pointer {
        return lhs.advanced(by: rhs)
    }

    public static func -(lhs: Pointer, rhs: Int) -> Pointer {
        return lhs.advanced(by: -rhs)
    }

    public static func +=(lhs: inout Pointer, rhs: Int) {
        lhs = lhs.advanced(by: rhs)
    }

    public static func -=(lhs: inout Pointer, rhs: Int) {
        lhs = lhs.advanced(by: -rhs)
    }

    public static postfix func ++(pointer: inout Pointer) {
        pointer = pointer.advanced(by: 1)
    }

    public static postfix func --(pointer: inout Pointer) {
        pointer = pointer.advanced(by: -1)
    }
}
