//
//  LoadingListSnapshotTests.swift
//  ITGWorkoutKitiOSTests
//
//  Created by Findlay Wood on 22/07/2024.
//

import XCTest
import ITGWorkoutKitiOS
@testable import ITGWorkoutKit

final class LoadingListSnapshotTests: XCTestCase {

    func test_emptyList() {
        let sut = makeSUT()
        
        sut.display(emptyList())
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "EMPTY_LOADINGLIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "EMPTY_LOADINGLIST_dark")
    }
    
    func test_listWithErrorMessage() {
        let sut = makeSUT()

        sut.display(.error(message: "This is a\nmulti-line\nerror message"))

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LOADINGLIST_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LOADINGLIST_WITH_ERROR_MESSAGE_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "LOADINGLIST_WITH_ERROR_MESSAGE_light_extraExtraExtraLarge")
    }
    
    func test_initialLoadinglist() {
        let sut = makeSUT()

        sut.display(.init(isLoading: true))

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "LOADINGLIST_INITIAL_LOAD_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "LOADINGLIST_INITIAL_LOAD_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "LOADINGLIST_INITIAL_LOAD_light_extraExtraExtraLarge")
    }

    
    // MARK: - Helpers
    
    private func makeSUT() -> LoadingListViewController {
        let controller = LoadingListViewController()
        controller.loadViewIfNeeded()
        controller.tableView.separatorStyle = .none
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func emptyList() -> [CellController] {
        return []
    }
    
}
