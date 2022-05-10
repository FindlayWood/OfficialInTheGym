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
//        switch indexPath.row {
//        case 0:
//            coordinator?.timeSelected(viewModel.getData(at: indexPath))
//        case 1:
//            coordinator?.distanceSelected(viewModel.getData(at: indexPath))
//        case 2:
//            coordinator?.restTimeSelected(viewModel.getData(at: indexPath))
//        case 3:
//            coordinator?.noteSelected(viewModel.getData(at: indexPath))
//        default:
//            break
//        }
    }  
}
// MARK: - Actions
private extension AddMoreToExerciseViewController {
    @objc func continuePressed() {
        coordinator?.finishedExercise(viewModel.exercise)
//        coordinator?.addNewExercise()
    }
}
