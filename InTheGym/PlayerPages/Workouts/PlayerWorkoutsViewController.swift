//
//  PlayerWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine
import SCLAlertView


class PlayerWorkoutsViewController: UIViewController {

    // MARK: - Coordinator
    // TODO: - New Coordinator Needed
    
    // MARK: - Display Property
    var display = PlayerWorkoutsView()
    
    // MARK: - View Model
    var viewModel = PlayerWorkoutsViewModel()
    
    // MARK: - Data Source Property
    var dataSource: PlayerWorkoutsDataSource!
    
    // MARK: - Subscriptions
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        initDataSource()
        setupSubscribers()
        showFirstMessage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
        view.addSubview(display)
    }
    

    func initDataSource() {
        dataSource = .init(tableView: display.tableview)
    }
    
    // MARK: - Subscribers
    func setupSubscribers() {
        viewModel.workouts
            .dropFirst()
            .sink { [weak self] in self?.dataSource.updateTable(with: $0) }
            .store(in: &subscriptions)
        
        dataSource.workoutSelected
            .sink { [weak self] in self?.workoutSelected(at: $0) }
            .store(in: &subscriptions)
        
        viewModel.fetchWorkouts()
    }
    
    // MARK: - Actions
    func workoutSelected(at indexPath: IndexPath) {
        
    }
    
    @objc func plusButtonTapped(_ sender: UIButton) {
        
    }
}
//MARK: - First Time Message
extension PlayerWorkoutsViewController {
    func showFirstMessage() {
        if UIApplication.isFirstWorkoutsLaunch() {

            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("WORKOUTS!", subTitle: FirstTimeMessages.workoutsMessage, closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }
}
