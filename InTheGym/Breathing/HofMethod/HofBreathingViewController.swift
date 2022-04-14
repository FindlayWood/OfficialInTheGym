//
//  HofBreathingViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class HofBreathingViewController: UIViewController {

    // MARK: - Properties
    var display = HofBreathingView()
    
    var viewModel = HofBreathingViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDisplay()
        initViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    
    // MARK: - Display
    func initDisplay() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(start(_:)))
        display.centerCircle.addGestureRecognizer(tap)
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.$stage
            .dropFirst()
            .sink { [weak self] in self?.display.setDisplay(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.$holdingTime
            .dropFirst()
            .sink { [weak self] in self?.display.updateHoldTimer(with: $0 ?? 0)}
            .store(in: &subscriptions)
        
        viewModel.$roundsComplete
            .dropFirst()
            .sink { [weak self] in self?.display.roundComplete($0)}
            .store(in: &subscriptions)
        
        viewModel.$hideTimeLabel
            .sink { [weak self] in self?.display.holdTimerLabel.isHidden = $0 }
            .store(in: &subscriptions)
        
        viewModel.$fullBreath
            .sink { [weak self] in self?.display.showFully($0 ?? .ready)}
            .store(in: &subscriptions)
        
        viewModel.$completed
            .sink { [weak self] _ in self?.display.completed()}
            .store(in: &subscriptions)
    }
}

// MARK: - Actions
private extension HofBreathingViewController {
    
    @objc func start(_ sender: Any) {
        display.setDisplay(to: .ready)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.viewModel.start()
            self.display.setDisplay(to: .breatheIn)
        }
//        viewModel.start()
//        display.setDisplay(to: .breatheIn)
    }
}
