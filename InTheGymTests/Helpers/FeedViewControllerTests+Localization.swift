//
//  FeedViewControllerTests+Localization.swift
//  ITGWorkoutKitiOSTests
//
//  Created by Findlay Wood on 28/04/2024.
//

import Foundation
import XCTest
import ITGWorkoutKit

extension FeedUIIntegrationTests {
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
}
