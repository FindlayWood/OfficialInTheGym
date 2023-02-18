//
//  AssigningSelectionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class AssigningSelectionViewController: UIViewController {
    
    // MARK: - Display
    var display = AssigningSelectionView()
    
    // MARK: - View Model
    var viewModel = AssigningSelectedionViewModel()
    
    // MARK: - Users Child VC
    var usersChildVC = UsersChildViewController()
    
    // MARK: - Groups Child VC
    var groupsChildVC = MyGroupsViewController()
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDisplay()
        initViewModel()
        initDataSource()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = "Assign"
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addToContainer(vc: usersChildVC)
    }
    // MARK: - Display
    func initDisplay() {
        display.segmentControl.selectedIndex
            .sink { [weak self] in self?.changedSegment(to: $0)}
            .store(in: &subscriptions)
    }
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.playersPublisher
            .sink { [weak self] in self?.usersChildVC.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.fetchPlayers()
    }
    // MARK: - Data Source
    func initDataSource() {
        
        usersChildVC.dataSource.userSelected
            .sink { [weak self] _ in self?.showMessage()}
            .store(in: &subscriptions)
        
        groupsChildVC.selectedGroup
            .sink { [weak self] in self?.viewModel.selectedGroup($0)}
            .store(in: &subscriptions)
    }
    // MARK: - Add Child
    func addToContainer(vc controller: UIViewController) {
        addChild(controller)
        display.addSubview(controller.view)
        controller.view.frame = display.containerView.frame
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.didMove(toParent: self)
    }
    // MARK: - Remove Child
    func removeFromContainer(vc controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }
}
// MARK: - Actions
private extension AssigningSelectionViewController {
    func changedSegment(to newIndex: Int) {
        if newIndex == 0 {
            removeFromContainer(vc: groupsChildVC)
            addToContainer(vc: usersChildVC)
        } else {
            removeFromContainer(vc: usersChildVC)
            addToContainer(vc: groupsChildVC)
        }
    }
    func showMessage() {
        displayTopMessage(with: "Assigned!")
    }
}
