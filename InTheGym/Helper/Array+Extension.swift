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
