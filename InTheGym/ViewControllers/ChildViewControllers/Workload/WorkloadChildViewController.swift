//
//  WorkloadChildViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class WorkloadChildViewController: UIViewController {
    
    // MARK: - Properties
    var display = WorkloadChildView()
    
    var viewModel = WorkloadChildViewModel()
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
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
    
    // MARK: - ViewModel
    func initViewModel() {
        
        viewModel.chartDataPublisher
            .sink { [weak self] in self?.display.lineChart.data = $0 }
            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading(to: $0)}
            .store(in: &subscriptions)
        
        
        viewModel.loadWorkloads()
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
