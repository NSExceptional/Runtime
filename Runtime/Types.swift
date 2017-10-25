//
//  Types.swift
//  Runtime
//
//  Created by Tanner on 10/18/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

import Foundation

public indirect enum Type {
    case void
    case pointer(Type)
    case integer
    case float
    case bool
    case string
    case tuple(String)
    case optional(Type)
    case object(String)
    case `struct`(String)
    case `class`(String)

    public var description: String {
        switch self {
        case .void:
            return "Void"
        case .pointer(let type):
            return "Pointer<\(type)>"
        case .integer:
            return "Integer"
        case .float:
            return "Float"
        case .bool:
            return "Bool"
        case .string:
            return "String"
        case .tuple(let structName):
            return structName // TDOO: struct.describedAsTuple
        case .optional(let type):
            return type.description + "?"
        case .object(let name):
            return name
        case .struct(let name):
            return name
        case .class(let name):
            return name
        }
    }

    public var encoding: String {
        switch self {
        case .void:
            return "v"
        case .pointer(let type):
            return "^\(type.encoding)"
        case .integer:
            return Platform.is64Bit ? "q" : "i"
        case .float:
            return Platform.is64Bit ? "d" : "f"
        case .bool:
            return "C"
        case .string:
            return "{11_StringCore}"
        case .tuple(let structName):
            return Type.struct(structName).encoding
        case .optional(let type):
            return "?\(type.description.count)\(type.description)"
        case .object(_):
            return "@"
        case .struct(let name):
            return "{\(name.count)" + name + "}"
        case .class(_):
            return "#"
        }
    }

    public var size: Int {
        switch self {
        case .void:
            return 0
        case .pointer(_): fallthrough
        case .integer:
            return MemoryLayout<Int>.size
        case .float:
            return Platform.is64Bit ? MemoryLayout<Float64>.size : MemoryLayout<Float32>.size
        case .bool:
            return MemoryLayout<Bool>.size
        case .string:
            return MemoryLayout<String>.size
        case .tuple(let structName):
            return Type.struct(structName).size
        case .optional(let type):
            switch type {
            case .pointer(let ptrType):
                return ptrType.size
            default:
                return type.size + 1
            }
        case .object(let className):
            return Class.named(className).instanceSize
        case .struct(let name):
            return Struct.named(name).instanceSize
        case .class(_):
            return 0 // You'll never need to know the size of a class in practice
        }
    }
}
