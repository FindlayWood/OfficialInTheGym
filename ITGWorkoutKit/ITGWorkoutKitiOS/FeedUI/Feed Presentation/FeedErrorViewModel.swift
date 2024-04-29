//
//  FeedErrorViewModel.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 29/04/2024.
//

import Foundation

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
