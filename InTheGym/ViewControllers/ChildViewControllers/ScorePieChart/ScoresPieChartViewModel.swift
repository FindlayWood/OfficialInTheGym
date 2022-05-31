//
//  ScoresPieChartViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine
import Charts
import UIKit

class ScoresPieChartViewModel {
    
    // MARK: - Publishers
    var chartDataPublisher = PassthroughSubject<PieChartData,Never>()
    var centerStringPublihser = PassthroughSubject<NSAttributedString,Never>()
    var errorPublisher = PassthroughSubject<Error,Never>()
    var lastThreePublisher = PassthroughSubject<[Int],Never>()
    
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
    func loadScores() {
        isLoading = true
        let searchModel = ScoreSearchModel(id: user.uid)
        apiService.fetchInstance(of: searchModel, returning: ScoresModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                self?.prepareChartData(from: models)
                self?.lastThreeScores(models)
            case .failure(let error):
                self?.errorPublisher.send(error)
                self?.isLoading = false
            }
        }
    }
    
    func lastThreeScores(_ models: [ScoresModel]) {
        let numbers = models.map { $0.score }
        let firsts = numbers.prefix(3)
        lastThreePublisher.send(Array(firsts))
    }
    
    func prepareChartData(from models: [ScoresModel]) {
        let scores = models.map { $0.score }
        let average = scores.average()
        setAverage(with: average)
        let occurences = scores.countOccurences()
        var chartEntries: [PieChartDataEntry] = []
        for num in 1...10 {
            chartEntries.append(PieChartDataEntry(value: Double(occurences[num] ?? 0), label: num.description))
        }
        setChartData(with: chartEntries)
    }
    
    func setAverage(with average: Double) {
        let myAttribute = [NSAttributedString.Key.font: UIFont(name: "Menlo-Bold", size: 15)!, NSAttributedString.Key.foregroundColor: UIColor.label]
        let myAttrString = NSAttributedString(string: average.rounded(toPlaces: 1).description, attributes: myAttribute)
        centerStringPublihser.send(myAttrString)
    }
    
    func setChartData(with entries: [PieChartDataEntry]) {
        let chartDataSet = PieChartDataSet(entries: entries, label: "")
        
        let noZeroFormatter = NumberFormatter()
        noZeroFormatter.zeroSymbol = ""
        chartDataSet.valueFormatter = DefaultValueFormatter(formatter: noZeroFormatter)
        
        let chartData = PieChartData(dataSet: chartDataSet)
        
        chartDataSet.colors = Constants.rpeColors
        
    
        chartDataSet.drawValuesEnabled = false
        chartDataSet.valueFont = UIFont(name: "Menlo-Bold", size: 15)!
        chartDataSet.valueTextColor = .black
        
        chartDataPublisher.send(chartData)
        self.isLoading = false
    }
}
