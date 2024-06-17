//
//  SharedLocalizationTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 17/06/2024.
//

import XCTest
import ITGWorkoutKit

final class SharedLocalizationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Shared"
        let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }

    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
}
