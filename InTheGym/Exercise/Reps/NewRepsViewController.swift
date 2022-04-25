//
//  NewRepsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

//this is the new reps page. it is used instead of repviewcontroller

import UIKit
import Combine
import SCLAlertView

enum setSelected {
    case allSelected
    case singleSelected(Int)
}

class NewRepsViewController: UIViewController {
    
    weak var coordinator: CreationFlow?
    
    weak var newCoordinator: RepsSelectionCoordinator?
    
    weak var exerciseViewModel: ExerciseCreationViewModel?
    
    var newExercise: exercise?
    
    var display = RepsView()
    
    var viewModel = RepSelectionViewModel()
    
    var dataSource: RepsDataSource!
    
    var setsDataSource: SetsDataSource!
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var repCounter: Int = 1
    

    // MARK: - View
    override func loadView() {
        view = display
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        initDataSource()
        initViewModel()
        setupActions()
        initNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .lightColour)
        navigationItem.title = "Reps"
    }
    

    // MARK: - Nav Bar
    func initNavBar() {
        let nextButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(nextPressed))
        navigationItem.rightBarButtonItem = nextButton
    }

    // MARK: - Targets
    fileprivate func setupActions() {
        display.minusButton.addTarget(self, action: #selector(minus), for: .touchUpInside)
        display.plusButton.addTarget(self, action: #selector(plus), for: .touchUpInside)
        display.nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.bottomCollection)
        setsDataSource = .init(collectionView: display.topCollection)
        
        dataSource.repSelected
            .sink { [weak self] rep in
                self?.display.setNumber(to: rep)
                self?.repCounter = rep
                self?.viewModel.repSelected(rep)
            }
            .store(in: &subscriptions)
        
        setsDataSource.setSelected
            .sink { [weak self] in self?.viewModel.selectedSet = $0 }
            .store(in: &subscriptions)
        
    }
    
    func initViewModel() {
        
        viewModel.$setCellModels
            .compactMap{ $0 }
            .sink { [weak self] in self?.setsDataSource.updateCollection(with: $0)}
            .store(in: &subscriptions)
        
        guard let exerciseViewModel = exerciseViewModel else {return}
        
        viewModel.$isLiveWorkout
            .sink { [weak self] isLive in
                if isLive {
                    self?.setsDataSource.isLive = true
                    self?.setsDataSource.setSelected.send(self?.viewModel.cellCount)
                }
            }
            .store(in: &subscriptions)

        viewModel.getSetCellModels(from: exerciseViewModel)
    }
    

}


//MARK: - button methods
extension NewRepsViewController{
    
    @objc func plus() {
        if repCounter < 99 {
            repCounter += 1
            display.repLabel.text = repCounter.description
            dataSource.repSelected.send(repCounter)
            display.topCollection.reloadData()
        }
    }
    
    @objc func minus() {
        if repCounter == 1 {
            display.repLabel.text = "M"
            repCounter -= 1
        } else if repCounter > 1 {
            repCounter -= 1
            display.repLabel.text = repCounter.description
        }
        dataSource.repSelected.send(repCounter)
        display.topCollection.reloadData()
    }
    
    @objc func nextPressed() {
//        guard let newExercise = newExercise else {return}
//        if coordinator is LiveWorkoutCoordinator {
//            if newExercise.repArray == nil {
//                newExercise.repArray = [repCounter]
//            } else {
//                newExercise.repArray?.append(repCounter)
//            }
//        } else if coordinator is AMRAPCoordinator || coordinator is EMOMCoordinator {
//            newExercise.reps = repCounter
//        } else {
//            newExercise.repArray = repIntArray
//        }
//        coordinator?.repsSelected(newExercise)
//        switch exerciseViewModel?.exercisekind {
//        case .amrap, .emom:
//            exerciseViewModel?.addReps([repCounter])
//            exerciseViewModel?.addSets(1)
//        case .regular, .circuit:
//            exerciseViewModel?.addReps([])
//        case .live:
//            exerciseViewModel?.appendToReps(repCounter)
//        case .none:
//            break
//        }
        let reps = viewModel.setCellModels?.map { $0.repNumber }
        exerciseViewModel?.exercise.reps = reps
//        if exerciseViewModel?.exercisekind == .amrap || exerciseViewModel?.exercisekind == .emom {
//            exerciseViewModel?.addReps([repCounter])
//            exerciseViewModel?.addSets(1)
//        }
//
//        else {
//            exerciseViewModel?.addReps(repIntArray)
//        }
//        exerciseViewModel?.addReps(repIntArray)
        newCoordinator?.next(viewModel: exerciseViewModel!)
    }
}
