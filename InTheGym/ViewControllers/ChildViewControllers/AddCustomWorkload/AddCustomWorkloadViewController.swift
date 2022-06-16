//
//  AddCustomWorkloadViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class AddCustomWorkloadViewController: UIViewController {
    // MARK: - Properties
    var display = AddCustomWorkloadView()
    var viewModel = AddCustomWorkloadViewModel()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initDisplay()
        initViewModel()
    }
    // MARK: - Display
    func initDisplay() {
        display.addButton.addTarget(self, action: #selector(uploadButtonAction(_:)), for: .touchUpInside)
        display.ratingSelected
            .sink { [weak self] in self?.viewModel.selectedRPE = $0 }
            .store(in: &subscriptions)
        display.durationTextField.textPublisher
            .sink { [weak self] in self?.viewModel.durationText = $0 }
            .store(in: &subscriptions)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$canUpload
            .sink { [weak self] in self?.display.addButton.isEnabled = $0 }
            .store(in: &subscriptions)
        viewModel.successfulUpload?
            .sink { [weak self] _ in self?.dismiss(animated: true)}
            .store(in: &subscriptions)
        viewModel.initSubscriptions()
    }
}
// MARK: - Actions
private extension AddCustomWorkloadViewController {
    @objc func uploadButtonAction(_ sender: UIButton) {
        viewModel.uploadAction()
    }
    @objc func dismissButtonAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
