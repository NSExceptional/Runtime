//
//  Method.swift
//  Runtime
//
//  Created by Tanner on 10/18/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

import Foundation

public class Method: Hashable {
    public typealias Signauture = (returnType: Type, argumentTypes: [Type])
    
    public let name: String
    public var imp: IMP
    public let returnType: Type
    public let argumentTypes: [Type]

    public var signature: Signauture {
        return (self.returnType, self.argumentTypes)
    }

    public init(_ name: String, returns: Type = .void, args: [Type] = [], _ imp: @escaping IMP) {
        self.name = name
        self.returnType = returns
        self.argumentTypes = args
        self.imp = imp
    }

    convenience public init(_ name: String, signature: Signauture = (.void, []), _ imp: @escaping IMP) {
        self.init(name, returns: signature.returnType, args: signature.argumentTypes, imp)
    }

    public var hashValue: Int {
        return self.name.hashValue
    }

    public static func ==(lhs: Method, rhs: Method) -> Bool {
        return lhs.name == rhs.name
    }
}
