//
//  JumpResultsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import UIKit

class JumpResultsViewController: UIViewController {
    // MARK: - Properties
    var childContentView: JumpResultsView!
    var viewModel = JumpResultsViewModel()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
        initViewModel()
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init(viewModel: viewModel)
        addSwiftUIView(childContentView)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$dismiss
            .sink { [weak self] value in
                if value { self?.dismiss() }
            }.store(in: &subscriptions)
    }
}
// MARK: - Actions
private extension JumpResultsViewController {
    func dismiss() {
        self.dismiss(animated: true)
    }
}
