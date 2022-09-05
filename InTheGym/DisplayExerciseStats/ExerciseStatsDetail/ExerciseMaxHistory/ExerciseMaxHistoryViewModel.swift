//
//  ExerciseMaxHistory.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine
import Charts

class ExerciseMaxHistoryViewModel {
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var chartDataPublisher: LineChartData?
    @Published var models: [ExerciseMaxHistoryModel] = []
    var error = CurrentValueSubject<Error?,Never>(nil)
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    var navigationTitle: String {
        "Max History"
    }
    
    var exerciseName: String!
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
    func loadData() {
        isLoading = true
        let searchModel = ExerciseMaxHistorySearchModel(exerciseName: exerciseName)
        apiService.fetchInstance(of: searchModel, returning: ExerciseMaxHistoryModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                self?.loadChartEntries(from: models)
                self?.models = models
            case .failure(let error):
                print(String(describing: error))
                self?.error.send(error)
                self?.isLoading = false
            }
        }
    }
    private func loadChartEntries(from models: [ExerciseMaxHistoryModel]) {
        let sortedModels = models.sorted { $0.time < $1.time }
        var entries: [ChartDataEntry] = []
        for (index, value) in sortedModels.enumerated() {
            let newEntry = ChartDataEntry(x: Double(index), y: value.weight)
            entries.append(newEntry)
        }
        let chartDataSet = LineChartDataSet(entries: entries, label: "max")
        chartDataSet.lineWidth = 3
        chartDataSet.mode = .horizontalBezier
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.setColor(.lightColour)
        let chartData = LineChartData()
        chartData.append(chartDataSet)
        chartData.setDrawValues(false)
        chartDataPublisher = chartData
        isLoading = false
    }
}
