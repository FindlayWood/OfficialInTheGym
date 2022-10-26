//
//  WorkloadChildViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine
import Charts

class WorkloadChildViewController: UIViewController {
    // MARK: - Properties
    var display = WorkloadChildView()
    var viewModel = WorkloadChildViewModel()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
        initDisplay()
        initTargets()
    }
    // MARK: - Display
    func initDisplay() {
        display.segment.selectedIndex
            .sink { [weak self] in self?.segmentChanged(to: $0)}
            .store(in: &subscriptions)
    }
    // MARK: - Targets
    func initTargets() {
        display.allWorkloadButton.addTarget(self, action: #selector(workloadTappedAction(_:)), for: .touchUpInside)
        display.addButton.addTarget(self, action: #selector(addWorkloadButtonAction(_:)), for: .touchUpInside)
    }
    // MARK: - ViewModel
    func initViewModel() {
        viewModel.chartDataPublisher
            .sink { [weak self] in self?.display.lineChart.data = $0 }
            .store(in: &subscriptions)
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading(to: $0)}
            .store(in: &subscriptions)
        viewModel.$barCharData
            .compactMap { $0 }
            .sink { [weak self] in self?.setChartData(with: $0)}
            .store(in: &subscriptions)
        viewModel.$workloadsToShow
            .sink { [weak self] in self?.updateDisplay(with: $0)}
            .store(in: &subscriptions)
        viewModel.customWorkloadAdded
            .sink { [weak self] _ in
                guard let self = self else {return}
                self.segmentChanged(to: self.viewModel.selectedIndex)
            }.store(in: &subscriptions)
        viewModel.$acuteLoad
            .sink { [weak self] in self?.display.acuteLoadLabel.text = Int($0).description }
            .store(in: &subscriptions)
        viewModel.$chronicLoad
            .sink { [weak self] in self?.display.chronicLoadLabel.text = $0.description }
            .store(in: &subscriptions)
        viewModel.loadWorkloads()
        viewModel.initSubscriptions()
    }
    // MARK: - Actions
    func setLoading(to loading: Bool) {
        if loading {
            display.activitiyIndicator.startAnimating()
            display.lineChart.isHidden = true
        } else {
            display.activitiyIndicator.stopAnimating()
            display.lineChart.isHidden = false
        }
    }
}
// MARK: - Actions
extension WorkloadChildViewController {
    @objc func workloadTappedAction(_ sender: Any) {
        let vc = MyWorkloadsViewController()
        vc.viewModel.workloadModels = viewModel.workloadModels
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc func addWorkloadButtonAction(_ sender: UIButton) {
        let vc = AddCustomWorkloadViewController()
        vc.viewModel.successfulUpload = viewModel.customWorkloadAdded
        navigationController?.present(vc, animated: true)
    }
    func setChartData(with data: BarChartData) {
        switch viewModel.selectedIndex {
        case 0:
            display.lineChart.xAxis.valueFormatter = WorkloadChartXAxisFormatter(days: 7)
        case 1:
            display.lineChart.xAxis.valueFormatter = WorkloadChartXAxisFormatter(days: 14)
        case 2:
            display.lineChart.xAxis.valueFormatter = WorkloadChartXAxisFormatter(days: 28)
        default:
            display.lineChart.xAxis.valueFormatter = WorkloadChartXAxisFormatter(days: 7)
        }
        display.lineChart.data = data
    }
    func segmentChanged(to index: Int) {
        viewModel.selectedIndex = index
        switch index {
        case 0:
            viewModel.loadRange(from: viewModel.workloadModels, for: 7)
        case 1:
            viewModel.loadRange(from: viewModel.workloadModels, for: 14)
        case 2:
            viewModel.loadRange(from: viewModel.workloadModels, for: 28)
        default:
            viewModel.loadRange(from: viewModel.workloadModels, for: 7)
        }
    }
    func updateDisplay(with models: [WorkloadModel]) {
        let workloads = models.map { $0.workload + ($0.customAddedWorkload ?? 0) + ($0.matchWorkload ?? 0)}
        let totalWorkload = workloads.reduce(0, +)
        display.totalWorkloadLabel.text = totalWorkload.description
        let times = models.map { $0.timeToComplete }
        let totalTime = times.reduce(0, +)
        display.filteredTimeLabel.text = totalTime.convertToWorkoutTime()
    }
}
