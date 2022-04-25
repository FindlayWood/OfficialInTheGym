//
//  Stack.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

/// A Stack - Custom data Structure
/// Can only add or remove elements from the end
/// LIFO - Last In First Out
/// Uses Generic values
/// Stacks provide a safer, much more secure way to remove and access the elements, but we must follow their rules.
struct Stack<T> {
    
    /// Current Stack Elements
    private var elements = [T]()
    
    /// Returns the last element of the stack
    var peek: T? {
        elements.last
    }

    /// Returns a boolean indicating whether the stack is empty.
    var isEmpty: Bool {
        elements.isEmpty
    }

    /// Returns the number of element in the stack
    var count: Int {
        elements.count
    }

    /// Appends an element to the end of the stack.
    /// - Parameter element: element to be appended
    mutating func push(_ element: T) {
        elements.append(element)
    }

    /// Removes and returns the last element of the stack
    /// - Returns: the last element of the stack
    mutating func pop() -> T? {
        elements.popLast()
    }
}
