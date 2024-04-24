//
//  FeedImageViewModel.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 22/04/2024.
//

import Foundation

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
