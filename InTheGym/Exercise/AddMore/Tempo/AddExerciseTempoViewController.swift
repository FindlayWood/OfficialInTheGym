//
//  AddExerciseTempoViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import UIKit

class AddExerciseTempoViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: AddMoreToExerciseCoordinator?
    
    var display = Display()
    
    var cellModel: AddMoreCellModel!
    
    var setsDataSource: SetsDataSource!
    
    var viewModel = AddMoreViewModel()
    
    var tempoViewModel = AddExerciseTempoViewModel()
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initBarButton()
        initDataSource()
        initTargets()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = "Add Time"
    }
    // MARK: - Nav Bar Button
    func initBarButton() {
        let barButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addPressed))
        navigationItem.rightBarButtonItem = barButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    // MARK: - Init Data Source
    func initDataSource() {
        setsDataSource = .init(collectionView: display.topCollection)
        
        setsDataSource.setSelected
            .sink { [weak self] selectedSet in
                self?.viewModel.selectedSet = selectedSet
                self?.display.setUpdateButton(to: selectedSet)
            }
            .store(in: &subscriptions)
    }
    
    // MARK: - Targets
    func initTargets() {
        display.updateButton.addTarget(self, action: #selector(updatePressed), for: .touchUpInside)
    }
    
    // MARK: - Init View Model
    func initViewModel() {
        
        tempoViewModel.initTempoModels(exercise: viewModel.exercise)
        
        display.eccentricTextfield.textPublisher
            .sink { [weak self] in self?.tempoViewModel.eccentric = Int($0) }
            .store(in: &subscriptions)
        
        display.eccentricPauseTextfield.textPublisher
            .sink { [weak self] in self?.tempoViewModel.eccentricPause = Int($0) }
            .store(in: &subscriptions)
        
        display.concentricTextfield.textPublisher
            .sink { [weak self] in self?.tempoViewModel.concentric = Int($0) }
            .store(in: &subscriptions)
        
        display.concentricPauseTextfield.textPublisher
            .sink { [weak self] in self?.tempoViewModel.concentricPause = Int($0) }
            .store(in: &subscriptions)
        
        tempoViewModel.$valid
            .sink { [weak self] in self?.display.displayUpdateButton($0) }
            .store(in: &subscriptions)
        
        viewModel.$setCellModels
            .compactMap { $0 }
            .sink { [weak self] in self?.setsDataSource.updateCollection(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.getTempoCellModels()
        
        viewModel.$isLiveWorkout
            .sink { [weak self] isLive in
                if isLive {
                    self?.setsDataSource.isLive = true
                    self?.setsDataSource.setSelected.send(self?.viewModel.cellCount)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$isEditing
            .filter { $0 }
            .sink { [weak self] _ in
                self?.setsDataSource.isLive = true
                self?.setsDataSource.setSelected.send(self?.viewModel.editingSet)
            }.store(in: &subscriptions)
    }
}
// MARK: - Actions
private extension AddExerciseTempoViewController {
    @objc func updatePressed(_ sender: UIButton) {
        guard let eccentric = tempoViewModel.eccentric,
              let eccentricPause = tempoViewModel.eccentricPause,
              let concentric = tempoViewModel.concentric,
              let concentricPause = tempoViewModel.concentricPause
        else {
            return
        }
        let model = ExerciseTempoModel(eccentric: eccentric, eccentricPause: eccentricPause, concentric: concentric, concentricPause: concentricPause)
        viewModel.tempoUpdated(model)
        tempoViewModel.updateTempoModels(viewModel.selectedSet, model: model)
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    @objc func addPressed() {
        cellModel.value.value = "Added"
        viewModel.tempoAdded(tempoViewModel.tempoModels)
        navigationController?.popViewController(animated: true)
    }
}
