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
    
    @Published var isLoading: Bool = false
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    var user: Users!
    
    var workloadModels: [WorkloadModel] = []
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func loadWorkloads() {
        isLoading = true
        let workloadSearchModel = WorkloadSearchModel(id: user.uid)
        apiService.fetchInstance(of: workloadSearchModel, returning: WorkloadModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                self?.getChartEntries(from: models)
                self?.workloadModels = models
            case .failure(_):
                self?.isLoading = false
                break
            }
        }
    }
    func getChartEntries(from models: [WorkloadModel]) {
        var chartEntries = [BarChartDataEntry]()
        let filteredModels = models.filter { $0.endTime.daysAgo() < 7 }
        let occurences = getOccurences(filteredModels.map { $0.endTime.daysAgo() }, filteredModels.map { $0.workload })
        for (key, value) in occurences {
            chartEntries.append(BarChartDataEntry(x: Double(7 - key), y: Double(value)))
        }
        chartEntries.sort { $0.x < $1.x }
        setChartData(with: chartEntries)
    }
    
    func getOccurences(_ days: [Int], _ workloads: [Int]) -> [Int:Int] {
        var occureneces = [Int:Int]()
        for (index, value) in days.enumerated() {
            occureneces[value, default: 0] += workloads[index]
        }
        return occureneces
    }
    
    func setChartData(with entries: [BarChartDataEntry]) {
        let chartDataSet = BarChartDataSet(entries: entries, label: "workload")
        let chartData = BarChartData()
        chartData.append(chartDataSet)
        chartData.setDrawValues(true)
        let colors = entries.map { setBarColour(for: $0.y) }
        chartDataSet.colors = colors
        
        chartDataPublisher.send(chartData)
        isLoading = false
    }
    func setBarColour(for value: Double?) -> UIColor {
        guard let value = value else {
            return .lightColour
        }
        if value > 500 {
            return UIColor.red
        } else if value > 400 {
            return .orange
        } else {
            return .green
        }
    }
}
