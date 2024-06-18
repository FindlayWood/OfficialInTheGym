//
//  ResourceErrorViewModel.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 30/04/2024.
//

import Foundation

public struct ResourceErrorViewModel {
    public let message: String?

    static var noError: ResourceErrorViewModel {
        return ResourceErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
}
