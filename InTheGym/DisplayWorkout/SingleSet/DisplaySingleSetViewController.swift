//
//  DisplaySetMoreInfoViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplaySingleSetViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: SingleSetCoordinator?
    var display = DisplaySingleSetView()
    var viewModel = DisplaySingleSetViewModel()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0)
        initDisplay()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBackground(to: 0.3)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.backgroundColor = .clear
    }
    // MARK: - Init Display
    func initDisplay() {
        display.dismissButton.addTarget(self, action: #selector(dismissButtonAction(_:)), for: .touchUpInside)
        display.editButton.addTarget(self, action: #selector(editButtonAction(_:)), for: .touchUpInside)
        display.configure(with: viewModel.setModel, isEditable: viewModel.isEditable)
    }
}
// MARK: - Actions
private extension DisplaySingleSetViewController {
    @objc func dismissButtonAction(_ sender: UIButton) {
        coordinator?.dismissVC()
    }
    @objc func editButtonAction(_ sender: UIButton) {
        coordinator?.editSet()
        viewModel.editSetAction?.send(viewModel.setModel)
    }
    func animateBackground(to opacity: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.view.backgroundColor = .black.withAlphaComponent(opacity)
        }
    }
}
