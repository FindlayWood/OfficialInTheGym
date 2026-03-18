//
//  FeedImagePresenter.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 01/05/2024.
//

import Foundation

public final class FeedImagePresenter {
    
    public static func map(_ image: WorkoutItem) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location)
    }
}
