//
//  NewWeightViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

// this page is used instead of weightviewcontroller

import UIKit
import SCLAlertView
import Combine

class WeightSelectionViewController: UIViewController {
    
    weak var coordinator: WeightSelectionFlow?
//    weak var newCoordinator: WeightSelectionFlow?
    
//    weak var exerciseViewModel: ExerciseCreationViewModel?
    
    var display = WeightView()
    
    var viewModel = WeightSelectionViewModel()
    
    var setsDataSource: SetsDataSource!
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func loadView() {
        view = display
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        initDataSource()
        initViewModel()
        initTargets()
        initNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Weight"
        editNavBarColour(to: .darkColour)
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
                    self?.setsDataSource.isLive = true
                    self?.setsDataSource.setSelected.send(self?.viewModel.cellCount)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.getSetCellModels()
        viewModel.isLiveWorkout = coordinator is LiveWorkoutSetCreationCoordinator
    }
    
    
    // MARK: - Nav Bar
    func initNavBar() {
        let nextButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(nextPressed(_:)))
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    // MARK: - Init Targets
    func initTargets() {
        display.kgButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        display.lbsButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        display.percentageButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        display.bodyweightButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        display.bodyWeightPercentButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        display.maxButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        display.updateButton.addTarget(self, action: #selector(updatePressed(_:)), for: .touchUpInside)
        
        display.nextButton.addTarget(self, action: #selector(nextPressed(_:)), for: .touchUpInside)
        display.skipButton.addTarget(self, action: #selector(skipPressed(_:)), for: .touchUpInside)
    }
    
    func showEmptyAlert(){
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40, showCircularIcon: true
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.showError("Enter a Weight!", subTitle: "You have not entered a number for the weight. To enter a number tap on the left side of the big dark blue box. You can continue without entering a weight by pressing the SKIP button near the bottom of the screen.", closeButtonTitle: "OK")
    }
}

// MARK: - Actions
private extension WeightSelectionViewController {
    @objc func buttonPressed(_ sender: UIButton) {
        display.resetButtons()
        sender.backgroundColor = .darkColour
        display.weightMeasurementField.text = sender.titleLabel?.text
        display.updateButton.isHidden = false
        if sender == display.maxButton || sender == display.bodyweightButton {
            display.numberTextfield.isUserInteractionEnabled = false
            display.numberTextfield.text = ""
        } else {
            display.numberTextfield.isUserInteractionEnabled = true
            display.numberTextfield.becomeFirstResponder()
        }
    }
    @objc func updatePressed(_ sender: UIButton) {
        guard let weightString = display.weightMeasurementField.text else {return}
        let numberString = display.numberTextfield.text ?? ""
        let fullString = numberString + weightString
        viewModel.weightUpdated(fullString)
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    @objc func nextPressed(_ sender: UIButton) {
        guard let weights = (viewModel.setCellModels?.map { $0.weightString }) else {return}
        viewModel.exercise.weight = weights
        coordinator?.weightSelected(viewModel.exercise)
//        exerciseViewModel?.addWeight(weights)
//        newCoordinator?.next()
    }
    @objc func skipPressed(_ sender: UIButton) {
        guard let weights = (viewModel.setCellModels?.map { $0.weightString }) else {return}
//        exerciseViewModel?.addWeight(weights)
//        newCoordinator?.next()
    }
}
