//
//  FeedLocalizationTests.swift
//  ITGWorkoutKitiOSTests
//
//  Created by Findlay Wood on 28/04/2024.
//

import XCTest
import ITGWorkoutKit

final class FeedLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
