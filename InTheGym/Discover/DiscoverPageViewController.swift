//
//  DiscoverPageViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView
import Combine

class DiscoverPageViewController: UIViewController {
    
    // MARK: - Properties
    var coordinator: DiscoverCoordinator?
    
    var display = DiscoverPageView()
    
    var viewModel = DiscoverPageViewModel()
    
    var dataSource: DiscoverPageDataSource!
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDataSource()
        initViewModel()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
        
        dataSource.itemSelected
            .sink { [weak self] in self?.viewModel.itemSelected($0)}
            .store(in: &subscriptions)
    }

    // MARK: - View Model
    func initViewModel(){
        
        viewModel.workoutSelected
            .sink { [weak self] in self?.coordinator?.workoutSelected($0)}
            .store(in: &subscriptions)
        
        viewModel.exerciseSelected
            .sink { [weak self] in self?.coordinator?.exerciseSelected($0)}
            .store(in: &subscriptions)

        viewModel.workoutModelsPublisher
            .sink { [weak self] in self?.dataSource.updateWorkouts(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.exercisesPublisher
            .sink { [weak self] in self?.dataSource.updateExercises(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.clipsPublisher
            .sink { [weak self] in self?.dataSource.updateClips(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.programPublisher
            .sink { [weak self] in self?.dataSource.updateProgram(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.loadWorkouts()
        viewModel.loadExercises()
        viewModel.loadClips()
        viewModel.loadPrograms()
        
    }
    
}

//MARK: - Actions
extension DiscoverPageViewController {
    @IBAction func searchTapped(_ sender: UIButton) {
        coordinator?.search()
    }
}


//MARK: - First Launch Message
extension DiscoverPageViewController {
    func showFirstMessage() {
        if UIApplication.isFirstDiscoverLaunch() {

            let screenSize: CGRect = UIScreen.main.bounds
            let screenWidth = screenSize.width
            
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: screenWidth - 40 )

            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("DISCOVER!", subTitle: FirstTimeMessages.discoverMessage, closeButtonTitle: "GOT IT!", colorStyle: 0x347aeb, animationStyle: .bottomToTop)
        }
    }
}
