//
//  ExerciseSelectionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

@available(iOS 13, *)
class ExerciseSelectionViewController: UIViewController {
    
    weak var coordinator: CreationFlow?
    
    weak var newCoordinator: ExerciseSelectionFlow?
    
    var newExercise: exercise?
    
    var display = ExerciseSelectionView()
    
    var viewModel = ExerciseSelectionViewModel()
    
    var adapter: ExerciseSelectionAdapter!
    
    var workoutCreationViewModel: ExerciseAdding!

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initViewModel()
        initDisplay()
        initNavBar()
        initViewTaps()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
    }
    
    func initViewModel() {
        viewModel.reloadCollectionClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.display.collectionView.reloadData()
            }
        }
        
        viewModel.updateLoadingStatusClosure = { [weak self] in
            guard let self = self else {return}
            if self.viewModel.isLoading {
                UIView.animate(withDuration: 0.3) {
                    self.display.collectionView.alpha = 0.0
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.display.collectionView.alpha = 1.0
                }
            }
        }
        viewModel.loadExercises()
    }
    
    func initDisplay() {
        adapter = .init(delegate: self)
        display.collectionView.delegate = adapter
        display.collectionView.dataSource = adapter
        display.searchBar.delegate = self
        if newCoordinator is CircuitExerciseSelectionCoordinator || newCoordinator is AmrapExerciseSelectionCoordinator || newCoordinator is EmomExerciseSelectionCoordinator {
            display.hideStack()
        }
    }
    func initNavBar() {
        navigationItem.title = "Select Exercise"
        let otherButton = UIBarButtonItem(title: "Other", style: .done, target: self, action: #selector(otherTapped(_:)))
        navigationItem.rightBarButtonItem = otherButton
    }
    
    @objc func otherTapped(_ sender: UIBarButtonItem) {
        guard let newExercise = newExercise else {return}
        coordinator?.otherSelected(newExercise)
    }
    
    func initViewTaps() {
        let circuitTap = UITapGestureRecognizer(target: self, action: #selector(circuitTapped))
        display.circuitView.addGestureRecognizer(circuitTap)
        let amrapTap = UITapGestureRecognizer(target: self, action: #selector(amrapTapped))
        display.amrapView.addGestureRecognizer(amrapTap)
        let emomTap = UITapGestureRecognizer(target: self, action: #selector(emomTapped))
        display.emomView.addGestureRecognizer(emomTap)
    }
    
    // MARK: - Actions
    @objc func circuitTapped() {
        let coordinator = coordinator as? RegularAndLiveFlow
        coordinator?.circuitSelected()
        newCoordinator?.ciruit()
    }
    @objc func amrapTapped() {
        let coordinator = coordinator as? RegularAndLiveFlow
        coordinator?.amrapSelected()
        newCoordinator?.amrap()
    }
    @objc func emomTapped() {
        let coordinator = coordinator as? RegularAndLiveFlow
        coordinator?.emomSelected()
        newCoordinator?.emom()
    }
}

@available(iOS 13, *)
extension ExerciseSelectionViewController: ExerciseSelectionProtocol {
    func getData(at indexPath: IndexPath) -> String {
        return viewModel.getData(at: indexPath)
    }
    func numberOfItems(at section: Int) -> Int {
        return viewModel.numberOfItems(at: section)
    }
    func numberOfSections() -> Int {
        if coordinator is CircuitCoordinator || coordinator is AMRAPCoordinator || coordinator is EMOMCoordinator {
            return 4
        } else {
            return viewModel.numberOfSections()
        }
    }
    func itemSelected(at indexPath: IndexPath) {
//        guard let newExercise = newExercise else {return}
//        newExercise.exercise = viewModel.getData(at: indexPath)
//        newExercise.type = viewModel.getBodyType(from: indexPath)
//        coordinator?.exerciseSelected(newExercise)
        let newE = ExerciseModel(exercise: viewModel.getData(at: indexPath), type: viewModel.getBodyType(from: indexPath))
//        let newE = ExerciseModel(workoutPosition: 0,
//                                 exercise: viewModel.getData(at: indexPath),
//                                 type: viewModel.getBodyType(from: indexPath),
//                                 completed: false)
        let newViewModel = ExerciseCreationViewModel()
        newViewModel.exercise = newE
//        newViewModel.addingDelegate = workoutCreationViewModel
        newCoordinator?.exercise(viewModel: newViewModel)
        
//        if indexPath.section == 4 {
//            let coordinator = coordinator as? RegularWorkoutFlow
//            coordinator?.addCircuit()
//        } else if indexPath.section == 5 {
//            let coordinator = coordinator as? RegularWorkoutFlow
//            coordinator?.addAMRAP()
//        } else if indexPath.section == 6 {
//            let coordinator = coordinator as? RegularWorkoutFlow
//            coordinator?.addEMOM()
//        } else {
//            guard let newExercise = newExercise else {return}
//            newExercise.exercise = viewModel.getData(at: indexPath)
//            newExercise.type = viewModel.getBodyType(from: indexPath)
//            coordinator?.exerciseSelected(newExercise)
//        }
    }
}

@available(iOS 13, *)
extension ExerciseSelectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterExercises(with: searchText)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if newCoordinator is RegularExerciseSelectionCoordinator {
            display.searchBegins()
        }
        if coordinator is RegularWorkoutCoordinator || coordinator is LiveWorkoutCoordinator {
            display.searchBegins()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        display.searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        display.searchBar.resignFirstResponder()
        if newCoordinator is RegularExerciseSelectionCoordinator {
            display.searchEnded()
        }
        if coordinator is RegularWorkoutCoordinator || coordinator is LiveWorkoutCoordinator {
            display.searchEnded()
        }
    }
}
