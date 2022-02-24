//
//  ProgramCreationViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ProgramCreationViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: ProgramCreationCoordinator?
    
    var viewModel = ProgramCreationViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var childVC = ProgramsChildViewController()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initNavBar()
        initViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.view.frame = getFullViewableFrame()
        childVC.didMove(toParent: self)
        initDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = "Program Creation"
    }
    
    // MARK: - Nav Bar
    func initNavBar() {
        let navButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(nextPressed(_:)))
        navigationItem.rightBarButtonItem = navButton
    }
    
    
    // MARK: - Data Source
    func initDataSource() {
        childVC.weeksDataSource.setForCreation()
        childVC.workoutsDataSource.setForCreation()
        
        childVC.weeksDataSource.numberSelected
            .sink { [weak self] in self?.viewModel.currentlySelectedWeek.send($0) }
            .store(in: &subscriptions)
        
        childVC.weeksDataSource.plusSelected
            .sink { [weak self] in self?.viewModel.addNewWeek() }
            .store(in: &subscriptions)
        childVC.weeksDataSource.removeItem
            .sink { [weak self] in self?.viewModel.removeWeek(with: $0) }
            .store(in: &subscriptions)
        
        childVC.workoutsDataSource.plusSelected
            .sink { [weak self] in self?.coordinator?.addSavedWorkout() }
            .store(in: &subscriptions)
        
        childVC.workoutsDataSource.removeItem
            .sink { [weak self] in self?.viewModel.removeWorkout(with: $0) }
            .store(in: &subscriptions)
            
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.currentlySelectedWeek
            .dropFirst()
            .sink { [weak self] number in
                guard let self = self else {return}
                self.childVC.workoutsDataSource.removeAll(true)
                self.childVC.workoutsDataSource.updateTable(with: self.viewModel.getWeeksWorkouts())
                self.childVC.display.updateWeekLabel(to: number)
                self.childVC.weeksDataSource.scrollTo(number: number)
            }
            .store(in: &subscriptions)
        
        viewModel.addedNewWeekPublisher
            .sink { [weak self] in self?.childVC.weeksDataSource.addNewWeek(with: $0) }
            .store(in: &subscriptions)
        
        viewModel.addedNewWorkoutPublisher
            .sink { [weak self] in self?.childVC.workoutsDataSource.addWorkout($0) }
            .store(in: &subscriptions)
        
        coordinator?.savedWorkoutSelected
            .sink { [weak self] in self?.viewModel.addWorkout($0) }
            .store(in: &subscriptions)
        
        viewModel.$next
            .sink { [weak self] in self?.navigationItem.rightBarButtonItem?.isEnabled = $0 }
            .store(in: &subscriptions)
        
        viewModel.removedWeek
            .sink { [weak self] in self?.childVC.weeksDataSource.updateTable(with: $0, isCreating: true, animated: false) }
            .store(in: &subscriptions)
        
        viewModel.programCleanedUpPublisher
            .sink { [weak self] in self?.childVC.weeksDataSource.updateTable(with: $0.weeks.count, isCreating: true, animated: true)}
            .store(in: &subscriptions)
    }
}

// MARK: - Actions
private extension ProgramCreationViewController {
    @objc func nextPressed(_ sender: UIBarButtonItem) {
        viewModel.removeEmptyEndWeeks()
        coordinator?.showDetailPage(with: viewModel.startingProgram)
    }
}
