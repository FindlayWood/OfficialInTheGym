//
//  AddMoreTimeViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class AddMoreTimeViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: AddMoreToExerciseCoordinator?
    
    var display = AddMoreBasicView()
    
    var cellModel: AddMoreCellModel!
    
    var setsDataSource: SetsDataSource!
    
    var viewModel = AddMoreViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    let message = "Add a time to complete each set for this exercise. Adding a time will not be appropriate for every exercise."

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
        navigationItem.title = "Add Time"
    }
    // MARK: - Nav Bar Button
    func initBarButton() {
        let barButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addPressed))
        navigationItem.rightBarButtonItem = barButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    // MARK: - Init Display
    func initDisplay() {
        display.numberTextfield.keyboardType = .numberPad
        display.numberTextfield.delegate = self
        display.setButtonTitlesTo("Seconds", "Minutes", nil, message)
        display.buttoneOne.addTarget(self, action: #selector(secondsPressed), for: .touchUpInside)
        display.buttoneTwo.addTarget(self, action: #selector(minutesPressed), for: .touchUpInside)
        display.updateButton.addTarget(self, action: #selector(updatePressed), for: .touchUpInside)
    }
    func emptyCheck() -> Bool {
        return display.numberTextfield.text == "" || display.weightMeasurementField.text == ""
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
        viewModel.getTimeCellModels()
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
private extension AddMoreTimeViewController {
    @objc func updatePressed() {
        guard let enteredTime = display.numberTextfield.text,
              let enteredWeight = display.weightMeasurementField.text
        else {return}
        guard var timeInt = Int(enteredTime) else {return}
        if enteredWeight == "mins" {
            timeInt = timeInt * 60
        }
        viewModel.timeUpdated(timeInt.description)
    }
    @objc func addPressed() {
        cellModel.value.value = "Added"
        viewModel.timeAdded()
        navigationController?.popViewController(animated: true)
    }
    @objc func secondsPressed() {
        display.weightMeasurementField.text = "secs"
        display.numberTextfield.becomeFirstResponder()
        display.updateButton.isHidden = false
        navigationItem.rightBarButtonItem?.isEnabled = !emptyCheck()
    }
    @objc func minutesPressed() {
        display.weightMeasurementField.text = "mins"
        display.numberTextfield.becomeFirstResponder()
        display.updateButton.isHidden = false
        navigationItem.rightBarButtonItem?.isEnabled = !emptyCheck()
    }
}
// MARK: - TextField Delegate
extension AddMoreTimeViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string).trimTrailingWhiteSpaces()
        navigationItem.rightBarButtonItem?.isEnabled = (newString != "") && (display.weightMeasurementField.text != "")
        return true
    }
}
