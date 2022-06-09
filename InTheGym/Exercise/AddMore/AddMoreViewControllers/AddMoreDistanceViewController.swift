//
//  AddMoreDistanceViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class AddMoreDistanceViewController: UIViewController {

    weak var coordinator: AddMoreToExerciseCoordinator?
    
    var display = AddMoreBasicView()
    
    var cellModel: AddMoreCellModel!
    
    var setsDataSource: SetsDataSource!
    
    var viewModel = AddMoreViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    let message = "Add a distance to complete each set for this exercise. Adding a distance will not be appropriate for every exercise."

    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initDisplay()
        initBarButton()
        initDataSource()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = "Add Distance"
    }
    func initBarButton() {
        let barButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addPressed))
        navigationItem.rightBarButtonItem = barButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    func initDisplay() {
        display.setButtonTitlesTo("Metres", "km", "miles", message)
        display.numberTextfield.delegate = self
        display.buttoneOne.addTarget(self, action: #selector(metresPressed), for: .touchUpInside)
        display.buttoneTwo.addTarget(self, action: #selector(kmPressed), for: .touchUpInside)
        display.buttoneThree.addTarget(self, action: #selector(milesPressed), for: .touchUpInside)
        display.updateButton.addTarget(self, action: #selector(updatePressed), for: .touchUpInside)
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
    // MARK: - Init View Model
    func initViewModel() {
        
        viewModel.$setCellModels
            .compactMap { $0 }
            .sink { [weak self] in self?.setsDataSource.updateCollection(with: $0)}
            .store(in: &subscriptions)
        viewModel.getDistanceCellModels()
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

    func emptyCheck() -> Bool {
        return display.numberTextfield.text == "" || display.weightMeasurementField.text == ""
    }
}

extension AddMoreDistanceViewController {
    @objc func updatePressed() {
        guard let enteredDistance = display.numberTextfield.text,
              let enteredMeasurement = display.weightMeasurementField.text
        else {return}
        let addedDistance = enteredDistance + enteredMeasurement
        viewModel.distanceUpdated(addedDistance)
    }
    @objc func addPressed() {
        cellModel.value.value = "Added"
        viewModel.distanceAdded()
        navigationController?.popViewController(animated: true)
    }
    @objc func metresPressed() {
        display.weightMeasurementField.text = "m"
        display.numberTextfield.becomeFirstResponder()
        display.updateButton.isHidden = false
        navigationItem.rightBarButtonItem?.isEnabled = !emptyCheck()
    }
    @objc func kmPressed() {
        display.weightMeasurementField.text = "km"
        display.numberTextfield.becomeFirstResponder()
        display.updateButton.isHidden = false
        navigationItem.rightBarButtonItem?.isEnabled = !emptyCheck()
    }
    @objc func milesPressed() {
        display.weightMeasurementField.text = "miles"
        display.numberTextfield.becomeFirstResponder()
        display.updateButton.isHidden = false
        navigationItem.rightBarButtonItem?.isEnabled = !emptyCheck()
    }
}

extension AddMoreDistanceViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string).trimTrailingWhiteSpaces()
        navigationItem.rightBarButtonItem?.isEnabled = (newString != "") && (display.weightMeasurementField.text != "")
        return true
    }
}
