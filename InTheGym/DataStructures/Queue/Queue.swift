//
//  Queue.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

/// A Queue - Custom data Structure
/// Can only add elements to the end and remove elements from the front
/// FIFO - First In First Out
/// Uses Generic values
/// Queues provide a safer, much more secure way to remove and access the elements, but we must follow their rules.
struct Queue<T> {

    /// Current Elements of the queue
    private var elements = [T]()

    /// Returns the first element of the queue
    var peek: T? {
        elements.first
    }

    /// Returns a boolean indicating whether the queue is empty.
    var isEmpty: Bool {
        elements.isEmpty
    }

    /// Returns the number of element in the queue
    var count: Int {
        elements.count
    }

    /// Appends an element to the end of the queue.
    /// - Parameter element: element to be appended
    mutating func enqueue(_ element: T) {
        elements.append(element)
    }

    /// Removes and returns the first element of the queue
    /// - Returns: the first element of the queue
    mutating func dequeue() -> T? {
        guard !elements.isEmpty else {
            return nil
        }

        return elements.removeFirst()
    }
}
