//
//  OptimalWorkloadRationViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine
import Charts

class OptimalWorkloadRatioViewModel {
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var currentACWR: Double = 0.0
    @Published var acuteLoad: Double = 0.0
    @Published var chronicLoad: Double = 0.0
    @Published var acwrChartData: LineChartData?
    @Published var freshnessIndexData: LineChartData?
    @Published var monotonyLineChartData: LineChartData?
    @Published var trainingStrainLineChartData: LineChartData?
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var user: Users!
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Functions
    func loadWorkloads() {
        isLoading = true
        let workloadSearchModel = WorkloadSearchModel(id: user.uid)
        apiService.fetchInstance(of: workloadSearchModel, returning: WorkloadModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                self?.loadData(from: models)
            case .failure(_):
                self?.isLoading = false
                break
            }
        }
    }
    func loadData(from models: [WorkloadModel]) {
        var ratioModels: [RatioModel] = [RatioModel]()
        for i in 0..<28 {
            let shortModels = loadModelRanges(from: i, to: i + 7, from: models, with: 7)
            let longModels = loadModelRanges(from: i, to: i + 28, from: models, with: 28)
            ratioModels.append(calculateData(from: shortModels, compared: longModels))
        }
        if let firstModel = ratioModels.first {
            currentACWR = firstModel.getACWR()
            acuteLoad = firstModel.getAcuteLoad()
            chronicLoad = firstModel.getChronicLoad()
        }
        getChartEntries(from: &ratioModels)
    }
    func loadModelRanges(from startDay: Int, to endDay: Int, from models: [WorkloadModel], with size: Int) -> [Double] {
        var workloads = Array(repeating: 0.0, count: size)
        let models = models.filter { $0.endTime.daysAgo() >= startDay && $0.endTime.daysAgo() < endDay }
        let addedWorkloads = getOccurences( models.map { $0.endTime.daysAgo() }, models.map { Double($0.workload) + Double($0.customAddedWorkload ?? 0) + Double($0.matchWorkload ?? 0) })
        for (key, value) in addedWorkloads {
            workloads[key - startDay] = value
        }
        return workloads
    }
    func calculateData(from sevenDayModels: [Double], compared twentyEightDayModels: [Double]) -> RatioModel {
        let acwr = sevenDayModels.sum() / (twentyEightDayModels.sum() / 4)
        let monotony = sevenDayModels.avg() / sevenDayModels.stdev()
        let trainingStrain = sevenDayModels.sum() * monotony
        let acuteLoad = sevenDayModels.sum()
        let chronicLoad = twentyEightDayModels.sum() / 4
        let freshnessIndex = chronicLoad - acuteLoad
        return RatioModel(acwr: acwr, monotony: monotony, trainingStrain: trainingStrain, acuteLoad: acuteLoad, chronicLoad: chronicLoad, freshnessIndex: freshnessIndex)
    }
    func getOccurences(_ days: [Int], _ workloads: [Double]) -> [Int:Double] {
        var occureneces = [Int:Double]()
        for (index, value) in days.enumerated() {
            occureneces[value, default: 0] += workloads[index]
        }
        return occureneces
    }
    func getChartEntries(from ratioModels: inout [RatioModel]) {
        ratioModels.reverse()
        var chartEntries = [ChartDataEntry]()
        var freshnessEntries = [ChartDataEntry]()
        var secondChartEntries = [ChartDataEntry]()
        var strainEntries = [ChartDataEntry]()
        for (index, value) in ratioModels.enumerated() {
            chartEntries.append(ChartDataEntry(x: Double(index), y: value.acwr))
            freshnessEntries.append(ChartDataEntry(x: Double(index), y: value.freshnessIndex))
            secondChartEntries.append(ChartDataEntry(x: Double(index), y: value.monotony))
            strainEntries.append(ChartDataEntry(x: Double(index), y: value.trainingStrain))
        }
        let chartDataSet = LineChartDataSet(entries: chartEntries, label: "ACWR")
        let freshnessDataSet = LineChartDataSet(entries: freshnessEntries, label: "Freshness Index")
        let secondChartDataSet = LineChartDataSet(entries: secondChartEntries, label: "Monotony")
        let thirdChartDataSet = LineChartDataSet(entries: strainEntries, label: "Training Strain")
        secondChartDataSet.lineWidth = 3
        secondChartDataSet.drawCirclesEnabled = false
        secondChartDataSet.setColor(.lightColour)
        thirdChartDataSet.mode = .cubicBezier
        thirdChartDataSet.lineWidth = 3
        thirdChartDataSet.drawCirclesEnabled = false
        thirdChartDataSet.setColor(.lightColour)
        thirdChartDataSet.fillColor = .lightColour.withAlphaComponent(0.6)
        thirdChartDataSet.mode = .cubicBezier
        thirdChartDataSet.drawFilledEnabled = true
        freshnessDataSet.mode = .cubicBezier
        freshnessDataSet.lineWidth = 3
        freshnessDataSet.drawCirclesEnabled = false
        freshnessDataSet.setColor(.lightColour)
        freshnessDataSet.fillColor = .lightColour.withAlphaComponent(0.6)
        freshnessDataSet.mode = .cubicBezier
        freshnessDataSet.drawFilledEnabled = true
        let chartData = LineChartData(dataSets: [chartDataSet])
        chartData.setDrawValues(false)
        chartDataSet.lineWidth = 3
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.setColor(.darkColour)
        chartDataSet.mode = .horizontalBezier
        acwrChartData = chartData
        let monotonyChartData = LineChartData(dataSets: [secondChartDataSet])
        monotonyChartData.setDrawValues(false)
        monotonyLineChartData = monotonyChartData
        let strainChartData = LineChartData(dataSets: [thirdChartDataSet])
        strainChartData.setDrawValues(false)
        trainingStrainLineChartData = strainChartData
        let freshnessLineChartData = LineChartData(dataSets: [freshnessDataSet])
        freshnessLineChartData.setDrawValues(false)
        freshnessIndexData = freshnessLineChartData
    }
}

// TODO: - Move Struct
struct RatioModel: Codable {
    var acwr: Double
    var monotony: Double
    var trainingStrain: Double
    var acuteLoad: Double
    var chronicLoad: Double
    var freshnessIndex: Double
    
    func getACWR() -> Double {
        acwr.isNaN ? 0.0 : acwr
    }
    func getAcuteLoad() -> Double {
        acuteLoad.isNaN ? 0.0 : acuteLoad
    }
    func getChronicLoad() -> Double {
        chronicLoad.isNaN ? 0.0 : chronicLoad
    }
}
