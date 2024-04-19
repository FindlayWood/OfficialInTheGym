//
//  FeedViewControllerTests.swift
//  ITGWorkoutKitiOSTests
//
//  Created by Findlay Wood on 19/04/2024.
//

import XCTest
import UIKit
import ITGWorkoutKit

final class FeedViewController: UIViewController {
    private var loader: WorkoutLoader?

    convenience init(loader: WorkoutLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loader?.load { _ in }
    }
}

final class FeedViewControllerTests: XCTestCase {


    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)

        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    
    func test_viewDidLoad_loadsFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    // MARK: - Helpers

    class LoaderSpy: WorkoutLoader {
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (WorkoutLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
}
