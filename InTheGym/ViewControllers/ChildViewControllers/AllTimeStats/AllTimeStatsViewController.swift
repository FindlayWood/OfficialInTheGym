//
//  AllTimeStatsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class AllTimeStatsViewController: UIViewController {
    // MARK: - Properties
    var display = AllTimeStatsView()
    var viewModel = AllTimeStatsViewModel()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$statsModel
            .compactMap { $0 }
            .sink { [weak self] in self?.display.configure(with: $0)}
            .store(in: &subscriptions)
        viewModel.loadStats()
    }
}
