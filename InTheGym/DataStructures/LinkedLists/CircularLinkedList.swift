//
//  CircularLinkedList.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct CircularLinkedList<T> {
    
    var head: Node<T>?
    var tail: Node<T>?
    
    init(_ elements: [T]) {
        for element in elements {
            append(element)
        }
    }
    
    // MARK: - Append
    mutating func append(_ value: T) {
        
        let node = Node(value: value)
        
        if head == nil { head = node }
        
        tail?.next = node
        tail = node
        node.next = head
    }
    
    // MARK: - Node At
    /// Return the element at the specified index
    func node(at index: Int) -> Node<T>? {
        var currentIndex = 0
        var currentNode = head
        
        while currentNode != nil && currentIndex < index {
            currentNode = currentNode?.next
            currentIndex += 1
        }
        
        return currentNode
    }
}
