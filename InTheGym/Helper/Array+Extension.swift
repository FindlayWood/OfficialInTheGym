//
//  Array+Extension.swift
//  InTheGym
//
//  Created by Findlay Wood on 17/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

extension Array where Element == Int {
    func repString() -> String {
        var repString = ""
        for rep in self {
            repString += rep.description + ","
        }
        return String(repString.dropLast())
    }
    func average() -> Double {
        let count = self.count
        let total = self.reduce(0, +)
        return Double(total) / Double(count)
    }
    func countOccurences() -> [Int:Int] {
        let counter = self.reduce(into: [:]) { partialResult, number in
            partialResult[number, default: 0] += 1
        }
        return counter
    }
}

extension Array where Element == String {
    func weightsArray() -> String {
        var weightString = ""
        for weight in self {
            weightString += weight + ","
        }
        return String(weightString.dropLast())
    }
}

extension Array where Element == Double {
    func sum() -> Double {
        self.reduce(0, +)
    }
    func avg() -> Double {
        self.sum() / Double(self.count)
    }
    func stdev() -> Double {
        let mean = self.avg()
        let v = self.reduce(0, { $0 + ($1 - mean)*($1 - mean) })
        return sqrt(v / Double(self.count) - 1)
    }
}
