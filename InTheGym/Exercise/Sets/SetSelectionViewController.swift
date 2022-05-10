//
//  SavedWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/09/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//
// this page is not for saved workouts
// it is for the new implementation of sets page
// it asks the user for how many sets on an exercise
// and then passes onto the new implementation of reps page

import UIKit
import SCLAlertView
import Combine

class SetSelectionViewController: UIViewController {
    
    weak var coordinator: SetSelectionFlow?
    
//    weak var newCoordinator: SetsSelectionCoordinator?
    
//    weak var exerciseViewModel: ExerciseCreationViewModel?
    
//    var newExercise: exercise?
    
    var viewModel = SetSelectionViewModel()
    
    var display = SetsView()
  
//    private var setNumber: Int = 1
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        
        display.collection.delegate = self
        display.collection.dataSource = self
        
        initNavBar()
        initTargets()
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    
    // MARK: - Nav Bar
    func initNavBar() {
        let nextButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(nextPressed))
        navigationItem.rightBarButtonItem = nextButton
    }
    // MARK: - Targets
    func initTargets() {
        display.plusButton.addTarget(self, action: #selector(plus), for: .touchUpInside)
        display.minusButton.addTarget(self, action: #selector(minus), for: .touchUpInside)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.initSubscriptions()
        
        viewModel.$setNumber
            .sink { [weak self] in self?.setDisplay(to: $0)}
            .store(in: &subscriptions)
    }
}
private extension SetSelectionViewController {
    func setDisplay(to setNumber: Int) {
        display.setLabel.text = setNumber.description
        display.collection.reloadData()
        display.collection.scrollToItem(at: IndexPath(item: setNumber - 1, section: 0), at: .centeredHorizontally, animated: true)
    }
}
// MARK: - Collection View Data Source & Delegate
extension SetSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SetsCell.cellID, for: indexPath) as! SetsCell
        cell.numberLabel.text = (indexPath.item + 1).description
        if (indexPath.item + 1) == viewModel.setNumber {
            cell.backgroundColor = .darkColour
        } 
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.setNumber = indexPath.item + 1
    }
    
    @objc func plus() {
        if viewModel.setNumber < 20 {
            viewModel.setNumber += 1
        }
    }
    
    @objc func minus() {
        if viewModel.setNumber > 1 {
            viewModel.setNumber -= 1
        }
    }
    
    @objc func nextPressed() {
        viewModel.exercise.reps = Array(repeating: 1, count: viewModel.setNumber)
        viewModel.exercise.weight = Array(repeating: " ", count: viewModel.setNumber)
        viewModel.exercise.completedSets = Array(repeating: false, count: viewModel.setNumber)
        coordinator?.setSelected(viewModel.exercise)
        
//        exerciseViewModel?.addSets(setNumber)
//        newCoordinator?.next(viewModel: exerciseViewModel!)
    }
}
