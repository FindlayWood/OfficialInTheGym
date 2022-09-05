//
//  WorkloadChildViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine
import Charts

class WorkloadChildViewModel {
    
    // MARK: - Publishers
    var chartDataPublisher = PassthroughSubject<BarChartData,Never>()
    var currentlySelectedIndex = CurrentValueSubject<Int,Never>(0)
    @Published var barCharData: BarChartData?
    @Published var workloadsToShow: [WorkloadModel] = []
    @Published var isLoading: Bool = false
    @Published var workloadModels: [WorkloadModel] = []
    @Published var acuteLoad: Double = 0.0
    @Published var chronicLoad: Double = 0.0
    var customWorkloadAdded = PassthroughSubject<WorkloadModel,Never>()
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var user: Users!
    var selectedIndex: Int = 0
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Actions
    func initSubscriptions() {
        customWorkloadAdded
            .sink { [weak self] in self?.workloadModels.insert($0, at: 0)}
            .store(in: &subscriptions)
    }
    // MARK: - Functions
    func loadWorkloads() {
        isLoading = true
        let workloadSearchModel = WorkloadSearchModel(id: user.uid)
        apiService.fetchInstance(of: workloadSearchModel, returning: WorkloadModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                self?.loadRange(from: models)
                self?.acuteLoad(from: models)
                self?.workloadModels = models
            case .failure(let error):
                print(String(describing: error))
                self?.isLoading = false
                break
            }
        }
    }
    func acuteLoad(from models: [WorkloadModel]) {
        let sevenDayModels = models.filter { $0.endTime.daysAgo() < 7 }.map { Double($0.workload) + Double($0.customAddedWorkload ?? 0) }
        let twentyEightDayModels = models.filter { $0.endTime.daysAgo() < 28 }.map { Double($0.workload) + Double($0.customAddedWorkload ?? 0) }
        acuteLoad = sevenDayModels.sum()
        chronicLoad = twentyEightDayModels.sum() / 4
    }
    func loadRange(from models: [WorkloadModel], for days: Int = 7) {
        var workloads = Array(repeating: 0.0, count: days)
        var customWorkloads = Array(repeating: 0.0, count: days)
        let filteredModels = models.filter { $0.endTime.daysAgo() < days }
        workloadsToShow = filteredModels
        let addedWorkloads = getOccurences( filteredModels.map { $0.endTime.daysAgo() }, filteredModels.map { Double($0.workload) })
        let customAddedWorkloads = getOccurences( filteredModels.map { $0.endTime.daysAgo() }, filteredModels.map { Double($0.customAddedWorkload ?? 0) })
        for (key, value) in addedWorkloads {
            workloads[key] = value
        }
        for (key, value) in customAddedWorkloads {
            customWorkloads[key] = value
        }
        getChartEntries(from: &workloads, and: &customWorkloads)
    }
    func getChartEntries(from models: inout [Double], and customModels: inout [Double]) {
        models.reverse()
        customModels.reverse()
        var chartEntries = [BarChartDataEntry]()
        for (key, value) in models.enumerated() {
            chartEntries.append(BarChartDataEntry(x: Double(key), yValues: [value, customModels[key]]))
        }
        setChartData(with: chartEntries)
    }
    func getOccurences(_ days: [Int], _ workloads: [Double]) -> [Int:Double] {
        var occureneces = [Int:Double]()
        for (index, value) in days.enumerated() {
            occureneces[value, default: 0] += workloads[index]
        }
        return occureneces
    }
    func setChartData(with entries: [BarChartDataEntry]) {
        let chartDataSet = BarChartDataSet(entries: entries)
        let chartData = BarChartData()
        chartData.append(chartDataSet)
        chartData.setDrawValues(false)
        chartDataSet.colors = [NSUIColor.lightColour, .green]
        chartDataSet.stackLabels = ["Workload", "Added Workload"]
        barCharData = chartData
        isLoading = false
    }
}
