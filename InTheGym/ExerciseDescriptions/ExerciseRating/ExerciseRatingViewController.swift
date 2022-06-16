//
//  ExerciseRatingViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ExerciseRatingViewController: UIViewController {
    // MARK: - Properties
    var display = ExerciseRatingView()
    var viewModel = ExerciseRatingViewModel()
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = viewModel.navigationTitle
    }
    // MARK: - Targets
    func initDisplay() {
        display.configureStamps()
        display.dismissButton.addTarget(self, action: #selector(dismissAction(_:)), for: .touchUpInside)
        display.submitButton.addTarget(self, action: #selector(submitButtonAction(_:)), for: .touchUpInside)
        display.newButton.addTarget(self, action: #selector(stampButtonSction(_:)), for: .touchUpInside)
        display.currentRatingLabel.text = viewModel.currentRating?.description
        display.ratingSelected
            .sink { [weak self] newRating in
                self?.viewModel.selectedRating = newRating
                self?.viewModel.ratingSelected = true
            }
            .store(in: &subscriptions)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.addedRatingPublisher?
            .sink { [weak self] _ in self?.dismiss(animated: true)}
            .store(in: &subscriptions)
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading(to: $0)}
            .store(in: &subscriptions)
        viewModel.$ratingSelected
            .sink { [weak self] in self?.display.setSubmitButton(to: $0) }
            .store(in: &subscriptions)
    }
}
// MARK: - Actions
extension ExerciseRatingViewController {
    func setLoading(to loading: Bool) {
        if loading {
            display.loadingIndicator.startAnimating()
        } else {
            display.loadingIndicator.stopAnimating()
        }
    }
    @objc func submitButtonAction(_ sender: UIButton) {
        viewModel.submitRating()
    }
    @objc func stampButtonSction(_ sender: UIButton) {
        viewModel.submitStamp()
    }
    @objc func dismissAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
