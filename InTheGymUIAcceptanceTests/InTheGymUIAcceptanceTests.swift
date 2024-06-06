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

        XCTAssertEqual(app.cells.count, 22)
        XCTAssertEqual(app.cells.firstMatch.images.count, 1)
    }
}
