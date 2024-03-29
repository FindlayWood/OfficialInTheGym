//
//  AddMoreToExerciseViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class AddMoreToExerciseViewController: UIViewController {
    
    // MARK: - Properties
//    weak var coordinator: AddMoreToExerciseCoordinator?
    weak var coordinator: FinishedExerciseCreationFlow?
    
    var display = AddMoreToExerciseView()
    
    var newExercise: exercise?
    
    var adapter: AddMoreToExerciseAdapter!
    
    var viewModel = AddMoreToExerciseViewModel()
    
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDisplay()
        initBarButton()
        viewModel.observePublishers()
    }
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .darkColour)
        navigationItem.title = "Add More"
    }
    // MARK: - Nav Bar Button
    func initBarButton() {
        let barButton = UIBarButtonItem(title: "Finish", style: .done, target: self, action: #selector(continuePressed))
        navigationItem.rightBarButtonItem = barButton
    }
    // MARK: - Init Display
    func initDisplay() {
        adapter = .init(delegate: self)
        display.collectionView.delegate = adapter
        display.collectionView.dataSource = adapter
    }
}
// MARK: - Collection View Delegate
extension AddMoreToExerciseViewController: AddMoreToExerciseProtocol {
    func getData(at indexPath: IndexPath) -> AddMoreCellModel {
        return viewModel.getData(at: indexPath)
    }
    
    func numberOfItems() -> Int {
        return viewModel.numberOfItems
    }
    
    func itemSelected(at indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = AddMoreTimeViewController()
            vc.viewModel.exercise = viewModel.exercise
            vc.cellModel = viewModel.getData(at: indexPath)
            vc.viewModel.timeUpdatedPublisher = viewModel.timeUpdatedPublisher
            vc.viewModel.isLive = coordinator is LiveWorkoutSetCreationCoordinator
            vc.viewModel.editingSet = viewModel.editingSet
            vc.viewModel.isEditing = viewModel.isEditing
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = AddMoreDistanceViewController()
            vc.viewModel.exercise = viewModel.exercise
            vc.cellModel = viewModel.getData(at: indexPath)
            vc.viewModel.distanceUpdatedPublisher = viewModel.distanceUpdatedPublisher
            vc.viewModel.isLive = coordinator is LiveWorkoutSetCreationCoordinator
            vc.viewModel.editingSet = viewModel.editingSet
            vc.viewModel.isEditing = viewModel.isEditing
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = AddMoreRestTimeViewController()
            vc.viewModel.exercise = viewModel.exercise
            vc.cellModel = viewModel.getData(at: indexPath)
            vc.viewModel.restTimeUpdatedPublisher = viewModel.restTimeUpdatedPublisher
            vc.viewModel.isLive = coordinator is LiveWorkoutSetCreationCoordinator
            vc.viewModel.editingSet = viewModel.editingSet
            vc.viewModel.isEditing = viewModel.isEditing
            navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = AddMoreNoteViewController()
            vc.viewModel.exercise = viewModel.exercise
            vc.cellModel = viewModel.getData(at: indexPath)
            vc.viewModel.noteUpdatedPublisher = viewModel.noteUpdatedPublisher
            navigationController?.present(vc, animated: true)
        case 4:
            let vc = AddExerciseTempoViewController()
            vc.viewModel.exercise = viewModel.exercise
            vc.cellModel = viewModel.getData(at: indexPath)
            vc.viewModel.tempoUpdatedPublisher = viewModel.tempoUpdatedPublisher
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }  
}
// MARK: - Actions
private extension AddMoreToExerciseViewController {
    @objc func continuePressed() {
        coordinator?.finishedExercise(viewModel.exercise)
    }
}
