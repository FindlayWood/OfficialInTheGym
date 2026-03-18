//
//  FeedEndpointTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 13/07/2024.
//

import XCTest
import ITGWorkoutKit

class FeedEndpointTests: XCTestCase {

    func test_feed_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!

        let received = FeedEndpoint.get.url(baseURL: baseURL)
        let expected = URL(string: "http://base-url.com/v1/feed")!

        XCTAssertEqual(received, expected)
    }

}
