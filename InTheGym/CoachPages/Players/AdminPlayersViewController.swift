//
//  AdminPlayersViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import Combine
import UIKit

class AdminPlayersViewController: UIViewController {
    // MARK: - Coordinator
    var coordinator: PlayersCoordinator?
    
    // MARK: - Properties
    var display = AdminPlayersView()
    var viewModel = AdminPlayersViewModel()
    var dataSource: PlayerDashBoardDataSource!
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        initDataSource()
        initTargets()
        initViewModel()
        initDisplay()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    // MARK: Display iOS 14
    func initDisplay() {
        display.tableview.backgroundColor = .secondarySystemBackground
        display.myWorkoutsSelected
            .sink { [weak self] in self?.coordinator?.showMyWorkouts()}
            .store(in: &subscriptions)
        display.iconButton.menu = display.coachMenu
        display.iconButton.showsMenuAsPrimaryAction = true
    }
    // MARK: - Targets
    func initTargets() {
        display.plusButton.addTarget(self, action: #selector(addPlayerTapped(_:)), for: .touchUpInside)
    }
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
        dataSource.userSelected
            .sink { [weak self] in self?.coordinator?.showPlayerInMoreDetail(player: $0)}
            .store(in: &subscriptions)
    }
     // MARK: - View Model
    func initViewModel() {
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading($0) }
            .store(in: &subscriptions)
        viewModel.playersPublisher
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.fetchPlayers()
    }
    // MARK: - Actions
    @objc func addPlayerTapped(_ sender: UIButton) {
        coordinator?.addNewPlayer(viewModel.playersPublisher.value)
    }
    func setLoading(_ loading: Bool) {
        display.plusButton.isHidden = loading
        if loading {
            display.activityIndicator.startAnimating()
        } else {
            display.activityIndicator.stopAnimating()
        }
    }
}
