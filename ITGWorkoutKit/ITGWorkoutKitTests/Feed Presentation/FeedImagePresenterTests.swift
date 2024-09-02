//
//  FeedImagePresenterTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 01/05/2024.
//

import XCTest
import ITGWorkoutKit

class FeedImagePresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let image = uniqueImage()

        let viewModel = FeedImagePresenter.map(image)

        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
    }
}
