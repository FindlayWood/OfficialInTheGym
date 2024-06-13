//
//  SceneDelegateTests.swift
//  InTheGymTests
//
//  Created by Findlay Wood on 09/06/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import XCTest
import ITGWorkoutKit
import ITGWorkoutKitiOS
@testable import InTheGym

final class SceneDelegateTests: XCTestCase {
    
    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let window = UIWindowSpy()
        let sut = SceneDelegate()
        sut.window = window
        
        sut.configureWindow()
        
        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1, "Expected to make window key and visible")
      }

    func test_configureWindow_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()

        sut.configureWindow()

        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController

        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
        XCTAssertTrue(topController is FeedViewController, "Expected a feed controller as top view controller, got \(String(describing: topController)) instead")
    }

    private class UIWindowSpy: UIWindow {
      var makeKeyAndVisibleCallCount = 0

      override func makeKeyAndVisible() {
        makeKeyAndVisibleCallCount += 1
      }
    }
}
