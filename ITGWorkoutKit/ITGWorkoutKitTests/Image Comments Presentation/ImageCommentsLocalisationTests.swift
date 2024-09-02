//
//  ImageCommentsLocalisationTests.swift
//  ITGWorkoutKitTests
//
//  Created by Findlay Wood on 20/06/2024.
//

import XCTest
import ITGWorkoutKit

final class ImageCommentsLocalisationTests: XCTestCase {

    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
         let table = "ImageComments"
         let bundle = Bundle(for: ImageCommentsPresenter.self)

         assertLocalizedKeyAndValuesExist(in: bundle, table)
     }

}
