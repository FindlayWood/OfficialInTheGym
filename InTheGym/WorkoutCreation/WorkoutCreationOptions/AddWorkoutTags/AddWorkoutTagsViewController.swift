//
//  AddWorkoutTagsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class AddWorkoutTagsViewController: UIViewController {
    // MARK: - Properties
    var display = AddNewTagView()
    var viewModel = AddWorkoutTagsViewModel()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initTargets()
        initDisplay()
        initViewModel()
    }
    // MARK: - Targets
    func initTargets() {
        display.addButton.addTarget(self, action: #selector(addButtonAction(_:)), for: .touchUpInside)
        display.cancelButton.addTarget(self, action: #selector(dismissButtonAction(_:)), for: .touchUpInside)
        display.textfield.delegate = self
    }
    // MARK: - Display
    func initDisplay() {
        display.textfield.textPublisher
            .sink { [weak self] in self?.viewModel.text = $0 }
            .store(in: &subscriptions)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$canAdd
            .sink { [weak self] in self?.display.setAddButton(to: $0)}
            .store(in: &subscriptions)
        viewModel.$text
            .sink { [weak self] in self?.display.setExampleLabel(to: $0)}
            .store(in: &subscriptions)
        viewModel.addNewTagPublisher
            .sink { [weak self] _ in self?.dismiss(animated: true)}
            .store(in: &subscriptions)
        viewModel.alreadyExists
            .sink { [weak self] in self?.dismiss(animated: true)}
            .store(in: &subscriptions)
        viewModel.initSubscriptions()
    }
}
// MARK: - Actions
private extension AddWorkoutTagsViewController {
    @objc func addButtonAction(_ sender: UIButton) {
        viewModel.addButtonAction()
    }
    @objc func dismissButtonAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
