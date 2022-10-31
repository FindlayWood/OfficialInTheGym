//
//  MyJumpsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import UIKit

class MyJumpsViewController: UIViewController {
    // MARK: - Properties
    weak var coordinator: JumpCoordinator?
    var childContentView: VerticalJumpHomeView!
    var viewModel = MyJumpsViewModel()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init(viewModel: viewModel)
        addSwiftUIView(childContentView)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$action
            .compactMap { $0 }
            .sink { [weak self] in self?.buttonAction($0) }
            .store(in: &subscriptions)
    }
}
// MARK: - Actions
private extension MyJumpsViewController {
    @objc func recordNewJumpActions(_ sender: UIButton) {
        coordinator?.recordNewJump()
    }
    @objc func instructionsAction(_ sender: UIButton) {
        coordinator?.instructions()
    }
    func buttonAction(_ action: VerticalJumpHomeViewActions) {
        switch action {
        case .recordNewJump:
            coordinator?.maxModel = viewModel.maxModel
            coordinator?.recordNewJump()
        case .previousJumps:
            coordinator?.jumpHistory()
        case .help:
            coordinator?.instructions()
        }
    }
}
