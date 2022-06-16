//
//  MyWorkoutStatsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine
import Charts

class MyWorkoutStatsViewController: UIViewController {
    // MARK: - Properties
    var display = MyWorkoutStatsView()
    var viewModel = MyWorkoutStatsViewModel()
    var allTimeStatsVC = AllTimeStatsViewController()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    // MARK: - Child VC
    func addSubViews() {
        addToStack(allTimeStatsVC)
    }
    func addToStack(_ viewController: UIViewController) {
        addChild(viewController)
        display.stack.addArrangedSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}
