//
//  InTheGymUIAcceptanceTests.swift
//  InTheGymUIAcceptanceTests
//
//  Created by Findlay Wood on 03/06/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import XCTest

final class InTheGymUIAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()

        app.launch()

        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 22)

        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
    }
}
