//
//  AddMoreRestTimeViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class AddMoreRestTimeViewController: UIViewController {
    
    weak var coordinator: AddMoreToExerciseCoordinator?

    var display = AddMoreBasicView()
    
    var cellModel: AddMoreCellModel!
    
    var exerciseViewModel: ExerciseCreationViewModel!
    
    var setsDataSource: SetsDataSource!
    
    var viewModel = AddMoreViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    let message = "Add a rest time for between each set for this exercise. Adding a rest time will not be appropriate for every exercise."

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
        navigationItem.title = "Add Rest Time"
    }
    func initBarButton() {
        let barButton = UIBarButtonItem(title: "Add", style: .done, target: self, action: #selector(addPressed))
        navigationItem.rightBarButtonItem = barButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    func initDisplay() {
        display.numberTextfield.keyboardType = .numberPad
        display.numberTextfield.delegate = self
        display.setButtonTitlesTo("Seconds", "Minutes", nil, message)
        display.buttoneOne.addTarget(self, action: #selector(secondsPressed), for: .touchUpInside)
        display.buttoneTwo.addTarget(self, action: #selector(minutesPressed), for: .touchUpInside)
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
        
        viewModel.$isLiveWorkout
            .sink { [weak self] isLive in
                if isLive {
                    self?.display.topCollection.isUserInteractionEnabled = false
                    self?.setsDataSource.setSelected.send(self?.viewModel.cellCount)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.getRestTimeCellModels(from: exerciseViewModel)
    }

    func emptyCheck() -> Bool {
        return display.numberTextfield.text == "" || display.weightMeasurementField.text == ""
    }
}

extension AddMoreRestTimeViewController {
    @objc func updatePressed() {
        guard let enteredTime = display.numberTextfield.text,
              let enteredWeight = display.weightMeasurementField.text
        else {return}
        guard var timeInt = Int(enteredTime) else {return}
        if display.weightMeasurementField.text == "mins" {
            timeInt = timeInt * 60
        }
        viewModel.restTimeUpdated(timeInt.description)
    }
    @objc func addPressed() {
        guard let enteredTime = display.numberTextfield.text,
              let enteredWeight = display.weightMeasurementField.text
        else {return}
        guard var timeInt = Int(enteredTime) else {return}
        if display.weightMeasurementField.text == "mins" {
            timeInt = timeInt * 60
        }
        cellModel.value.value = "Added"
        guard let times = (viewModel.setCellModels?.map { $0.weightString }) else {return}
        let seconds = times.map { Int($0) ?? 0}
        exerciseViewModel.addRestTime(seconds)
        coordinator?.restTimeAdded(timeInt)
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

extension AddMoreRestTimeViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string).trimTrailingWhiteSpaces()
        navigationItem.rightBarButtonItem?.isEnabled = (newString != "") && (display.weightMeasurementField.text != "")
        return true
    }
}
