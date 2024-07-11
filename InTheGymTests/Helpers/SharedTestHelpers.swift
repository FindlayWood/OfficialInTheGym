//
//  SharedTestHelpers.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 31/05/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import Foundation
import ITGWorkoutKit

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func anyURL() -> URL {
    return URL(string: "http://a-url.com")!
}

func uniqueFeed() -> [WorkoutItem] {
    return [WorkoutItem(id: UUID(), description: "any", location: "any", image: anyURL())]
}

private class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
}

var loadError: String {
    LoadResourcePresenter<Any, DummyView>.loadError
}

var feedTitle: String {
    FeedPresenter.title
}

var commentsTitle: String {
    ImageCommentsPresenter.title
}
