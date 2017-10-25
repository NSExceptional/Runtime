//
//  DebugDescriptions.swift
//  Runtime
//
//  Created by Tanner on 10/21/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

import Foundation

extension Class: CustomDebugStringConvertible, CustomStringConvertible, CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .text(self.name)
    }
    
    public var description: String {
        return self.name
    }
    
    public var debugDescription: String {
        var me = self
        return """
<Class \(self.name) (\(|me))> {
    isa:        \(self.isa?.name ?? "nil"),
    superclass: \(self.superclass?.name ?? "nil"),
    methods:    \(self.methods.count),
    properties: \(self.properties.count),
    protocols:  \(self.protocols.count),
}
"""
    }
}
