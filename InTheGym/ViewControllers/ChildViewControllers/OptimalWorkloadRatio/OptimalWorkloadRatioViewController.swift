//
//  OptimalWorkloadRatioViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine
import Charts

class OptimalWorkloadRatioViewController: UIViewController {
    // MARK: - Properties
    var display = OptimalWorkloadRatioView()
    var viewModel = OptimalWorkloadRatioViewModel()
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
        viewModel.$currentACWR
            .dropFirst()
            .sink { [weak self] in self?.display.setRatio(to: $0)}
            .store(in: &subscriptions)
        viewModel.$acwrChartData
            .compactMap { $0 }
            .sink { [weak self] in self?.display.acwrLineChart.data = $0 }
            .store(in: &subscriptions)
        viewModel.$freshnessIndexData
            .compactMap { $0 }
            .sink { [weak self] in self?.display.freshnessIndexLineChart.data = $0 }
            .store(in: &subscriptions)
        viewModel.$monotonyLineChartData
            .compactMap { $0 }
            .sink { [weak self] in self?.display.monotonyLineChart.data = $0}
            .store(in: &subscriptions)
        viewModel.$trainingStrainLineChartData
            .compactMap { $0 }
            .sink { [weak self] in self?.display.trainingStrainLineChart.data = $0}
            .store(in: &subscriptions)
        viewModel.loadWorkloads()
    }
}
