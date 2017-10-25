//
//  OrderedSet.swift
//  Runtime
//
//  Created by Tanner on 10/23/17.
//  Copyright © 2017 Tanner Bennett. All rights reserved.
//

import Foundation

class OrderedSet<T: Hashable>: ExpressibleByArrayLiteral {
    var array: [T] = []
    var set: Set<T> = []

    init() { }

    /// - Returns: true if the element was not already in the set, false otherwise
    @discardableResult
    func add(_ element: T) -> Bool {
        if self.set.insert(element).inserted {
            array.append(element)
            return true
        }

        return false
    }

    /// - Returns: true if all elements were not already in the set, false otherwise
    @discardableResult
    func addAll(_ elements: [T]) -> Bool {
        var allIn = true
        for e in elements {
            if !self.add(e) {
                allIn = false
            }
        }

        return allIn
    }

    required init(arrayLiteral elements: T...) {
        self.addAll(elements)
    }
}
