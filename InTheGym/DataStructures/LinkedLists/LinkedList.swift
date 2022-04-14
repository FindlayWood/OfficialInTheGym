//
//  LinkedList.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct LinkedList<T> {
    
    var head: Node<T>?
    var tail: Node<T>?
    
    var isEmpty: Bool { head == nil }
    
    init(_ elements: [T]) {
        for element in elements {
            self.append(element)
        }
    }
    
    // MARK: - Push
    mutating func push(_ value: T) {
        head = Node(value: value, next: head)
        
        if tail == nil {
            tail = head
        }
    }
    
    // MARK: - Append
    mutating func append(_ value: T) {
        let node = Node(value: value)
        
        if head == nil {
            head = node
        }
        
        tail?.next = node
        tail = node
    }
    
    // MARK: - Node At
    func node(at index: Int) -> Node<T>? {
        var currentIndex = 0
        var currentNode = head
        
        while currentNode != nil && currentIndex < index {
            currentNode = currentNode?.next
            currentIndex += 1
        }
        
        return currentNode
    }
    
    // MARK: - Insert After
    func insert(value: T, after index: Int) {
        guard let node = node(at: index) else {return}
        
        node.next = Node(value: value, next: node.next)
        
    }
    
    // MARK: - Pop
    mutating func pop() -> T? {
        defer {
            head = head?.next
            
            if isEmpty {
                tail = nil
            }
        }
        
        return head?.value
    }
    
    // MARK: - Remove Last
    mutating func removeLast() -> T? {
        guard let head = head else { return nil }
        guard head.next != nil else { return pop() }
        
        var previousNode = head
        var currentNode = head
        
        while let next = currentNode.next {
            previousNode = currentNode
            currentNode = next
        }
        
        previousNode.next = nil
        tail = previousNode
        
        return currentNode.value
    }
    
    // MARK: - Reverse
    mutating func reverseList() {
        
        var previous: Node<T>?
        var next: Node<T>?
        var currentNode: Node<T>? = head
        
//        currentNode = head
        
        while currentNode != nil {
            next = currentNode?.next
            currentNode?.next = previous
            previous = currentNode
            currentNode = next
        }
        
    }
}
