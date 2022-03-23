//
//  ScoresPieChartChildViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class ScoresPieChartChildViewController: UIViewController {
    
    
    // MARK: - Properties
    var display = ScoresPieChartView()
    
    var viewModel = ScoresPieChartViewModel()
    
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        initViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = view.bounds
        view.addSubview(display)
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.chartDataPublisher
            .sink { [weak self] in self?.display.pieChartView.data = $0 }
            .store(in: &subscriptions)
        
        viewModel.centerStringPublihser
            .sink { [weak self] in self?.display.pieChartView.centerAttributedText = $0}
            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.loadScores()
        
    }
    
    // MARK: - Actions
    func setLoading(to loading: Bool) {
        if loading {
            display.activitiyIndicator.startAnimating()
            display.pieChartView.isHidden = true
        } else {
            display.activitiyIndicator.stopAnimating()
            display.pieChartView.isHidden = false
        }
    }
}
