//
//  LoadingListWithNavBarSnapshotTests.swift
//  ITGWorkoutKitiOSTests
//
//  Created by Findlay Wood on 27/07/2024.
//

import XCTest
import ITGWorkoutKitiOS
@testable import ITGWorkoutKit

final class LoadingListWithNavBarSnapshotTests: XCTestCase {
    
    func test_emptyList() {
        let (sut, nav) = makeSUT()
        
        sut.display(emptyList())
        
        assert(snapshot: nav.snapshot(for: .iPhone(style: .light)), named: "EMPTY_LOADINGLIST_WITH_NAV_BAR_light")
        assert(snapshot: nav.snapshot(for: .iPhone(style: .dark)), named: "EMPTY_LOADINGLIST_WITH_NAV_BAR_dark")
    }
    
    func test_listWithErrorMessage() {
        let (sut, nav) = makeSUT()
        
        sut.display(.error(message: "This is a\nmulti-line\nerror message"))
        
        assert(snapshot: nav.snapshot(for: .iPhone(style: .light)), named: "LOADINGLIST_WITH_NAV_BAR_WITH_ERROR_MESSAGE_light")
        assert(snapshot: nav.snapshot(for: .iPhone(style: .dark)), named: "LOADINGLIST_WITH_NAV_BAR_WITH_ERROR_MESSAGE_dark")
        assert(snapshot: nav.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "LOADINGLIST_WITH_NAV_BAR_WITH_ERROR_MESSAGE_light_extraExtraExtraLarge")
    }
    
    func test_initialLoadinglist() {
        let (sut, nav) = makeSUT()
        
        sut.display(.init(isLoading: true))
        
        assert(snapshot: nav.snapshot(for: .iPhone(style: .light)), named: "LOADINGLIST_WITH_NAV_BAR_INITIAL_LOAD_light")
        assert(snapshot: nav.snapshot(for: .iPhone(style: .dark)), named: "LOADINGLIST_WITH_NAV_BAR_INITIAL_LOAD_dark")
        assert(snapshot: nav.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "LOADINGLIST_WITH_NAV_BAR_INITIAL_LOAD_light_extraExtraExtraLarge")
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT() -> (LoadingListViewController, UINavigationController) {
        let controller = LoadingListViewController()
        controller.loadViewIfNeeded()
        controller.tableView.separatorStyle = .none
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        controller.title = "Loading List Title"
        let nav = UINavigationController(rootViewController: controller)
        nav.navigationBar.prefersLargeTitles = true
        return (controller, nav)
    }
    
    private func emptyList() -> [CellController] {
        return []
    }
    
}

public final class DefaultAddButton: UIButton {
    
    public var onTap: (() -> ())?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func configure() {
        
        var configuration = Configuration.plain()
        configuration.image = UIImage(systemName: "plus.circle.fill")
        configuration.contentInsets = .zero
        self.configuration = configuration

        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
        
    }

    @objc private func hideMessageAnimated() {
        onTap?()
    }

}
