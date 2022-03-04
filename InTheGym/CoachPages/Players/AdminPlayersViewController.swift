//
//  AdminPlayersViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import EmptyDataSet_Swift
import Combine

class AdminPlayersViewController: UIViewController {
    
    var coordinator: PlayersFlow?
    
    // MARK: - Properties
    var display = AdminPlayersView()
    
    var childVC = UsersChildViewController()
    
    var viewModel = AdminPlayersViewModel()

    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        showFirstMessage()
        initDataSource()
        initTargets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
        childVC.display.tableview.backgroundColor = .darkColour
        view.addSubview(display)
        addChildVC()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Child VC
    func addChildVC() {
        addChild(childVC)
        display.addSubview(childVC.view)
        childVC.view.frame = display.containerView.frame
        childVC.didMove(toParent: self)
    }
    
    // MARK: - Targets
    func initTargets() {
        display.plusButton.addTarget(self, action: #selector(addPlayerTapped(_:)), for: .touchUpInside)
    }
    
    // MARK: - Data Source
    func initDataSource() {
        
        childVC.dataSource.userSelected
            .sink { [weak self] in self?.coordinator?.showPlayerInMoreDetail(player: $0)}
            .store(in: &subscriptions)
        
        initViewModel()
    }
    
     // MARK: - View Model
    func initViewModel() {
        
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading($0) }
            .store(in: &subscriptions)
        
        viewModel.playersPublisher
            .sink { [weak self] in self?.childVC.dataSource.updateTable(with: $0)}
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

// extension for first time message
extension AdminPlayersViewController {
    func showFirstMessage() {
        if UIApplication.isFirstPlayersLaunch() {

            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("PLAYERS!", subTitle: FirstTimeMessages.playersMessage, closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }
}
