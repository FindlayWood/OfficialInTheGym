//
//  OtherExerciseViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class OtherExerciseViewController: UIViewController {
    // Coordinator
    weak var coordinator: ExerciseSelectionFlow?
    // exercise
    var exercise: ExerciseModel?
    // display
    var display = OtherExerciseView()
    // view model
    var viewModel = OtherExerciseViewModel()
    // subscriptions
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        initDisplay()
        initViewModel()
    }
    // MARK: - Display
    func initDisplay() {
        display.continueButton.addTarget(self, action: #selector(continueTapped(_:)), for: .touchUpInside)
        display.cancelButton.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)
        display.exerciseTextField.delegate = self
        display.exerciseTextField.textPublisher
            .sink { [weak self] in self?.viewModel.text = $0 }
            .store(in: &subscriptions)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$isValid
            .sink { [weak self] in self?.display.setContinueButton(to: $0)}
            .store(in: &subscriptions)
        viewModel.initSubscriptions()
    }
}
// MARK: - Actions
private extension OtherExerciseViewController {
    @objc func continueTapped(_ sender: UIButton) {
        viewModel.exerciseModel.exercise = viewModel.text.trimTrailingWhiteSpaces()
        viewModel.exerciseModel.type = .CU
        dismiss(animated: true, completion: nil)
        coordinator?.exerciseSelected(viewModel.exerciseModel)
    }
    @objc func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
