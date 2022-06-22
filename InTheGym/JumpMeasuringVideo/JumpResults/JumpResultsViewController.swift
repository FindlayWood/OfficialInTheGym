//
//  JumpResultsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class JumpResultsViewController: UIViewController {
    // MARK: - Properties
    var display = JumpResultsView()
    var viewModel = JumpResultsViewModel()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initDisplay()
    }
    // MARK: - Display
    func initDisplay() {
        display.configure(with: viewModel.jumpResultCM, viewModel.resultCM)
        display.segment.selectedIndex
            .sink { [weak self] in self?.switchSegment(to: $0)}
            .store(in: &subscriptions)
    }
    // MARK: - View Model
    func initViewModel() {
        
    }
}
// MARK: - Actions
private extension JumpResultsViewController {
    func switchSegment(to index: Int) {
        viewModel.switchSegment(to: index)
        display.configure(with: viewModel.currentValue, viewModel.resultCM)
    }
}
