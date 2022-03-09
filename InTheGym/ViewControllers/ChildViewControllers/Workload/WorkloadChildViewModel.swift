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
    var chartDataPublisher = PassthroughSubject<LineChartData,Never>()
    var currentlySelectedIndex = CurrentValueSubject<Int,Never>(0)
    
    @Published var isLoading: Bool = false
    
    // MARK: - Properties
    var user: Users!
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
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
            case .failure(let error):
                self?.isLoading = false
                break
            }
        }
    }
    func getChartEntries(from models: [WorkloadModel]) {
        var chartEntries = [ChartDataEntry]()
        let filteredModels = models.filter { $0.endTime.daysAgo() < 7 }
        let occurences = getOccurences(filteredModels.map { $0.endTime.daysAgo() }, filteredModels.map { $0.workload })
        for (key, value) in occurences {
            chartEntries.append(ChartDataEntry(x: Double(7 - key), y: Double(value)))
        }
//        filteredModels.forEach { model in
//            chartEntries.append(ChartDataEntry(x: Double(7 - model.endTime.daysAgo()), y: Double(model.workload)))
//        }
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
    
    func setChartData(with entries: [ChartDataEntry]) {
        let chartDataSet = LineChartDataSet(entries: entries, label: "workload")
        let chartData = LineChartData()
        chartData.addDataSet(chartDataSet)
        chartData.setDrawValues(true)
        chartDataSet.colors = [#colorLiteral(red: 0, green: 0.5, blue: 1, alpha: 1), #colorLiteral(red: 0.6332940925, green: 0.8493953339, blue: 1, alpha: 1), #colorLiteral(red: 0.7802333048, green: 1, blue: 0.5992883134, alpha: 1), #colorLiteral(red: 0.9427440068, green: 1, blue: 0.3910798373, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.8438837757, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.7074058219, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.4706228596, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.3134631849, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)]
        chartDataSet.setCircleColor(Constants.backgroundColour)
        chartDataSet.circleHoleColor = Constants.backgroundColour
        chartDataSet.circleHoleRadius = 1
        chartDataSet.circleRadius = 5
        chartDataSet.mode = .cubicBezier
        chartDataSet.cubicIntensity = 0.15
        chartDataSet.drawCirclesEnabled = true
        chartDataSet.fill = Fill.fillWithColor(Constants.lightColour)
        chartDataSet.drawFilledEnabled = true
        
        chartDataPublisher.send(chartData)
        isLoading = false
    }
}
