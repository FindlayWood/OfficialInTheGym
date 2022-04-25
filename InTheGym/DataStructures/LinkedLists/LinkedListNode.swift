//
//  LinkedListNode.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

/// Node class for linked lists
/// A node has a generic value and an optional next Node

class Node<T> {
    
    /// The value of the current node
    var value: T
    
    /// Optional pointer to the next Node
    var next: Node<T>?
    
    init(value: T, next: Node<T>? = nil) {
        self.value = value
        self.next = next
    }
}
