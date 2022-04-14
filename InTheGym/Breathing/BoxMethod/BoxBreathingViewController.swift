//
//  BoxBreathingViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class BoxBreathingViewController: UIViewController {
    
    // MARK: - Properties
    var display = BoxBreathingView()
    
    var viewModel = BoxBreathingViewModel()
    
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
        
        
        viewModel.$currentStage
            .dropFirst()
            .sink { [weak self] in self?.display.setDisplay(to: $0?.value ?? .ready) }
            .store(in: &subscriptions)
    }

}

// MARK: - Actions
private extension BoxBreathingViewController {
    
    @objc func start(_ sender: Any) {
        display.setDisplay(to: .ready)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.viewModel.start()
//            self.display.setDisplay(to: .breatheIn)
        }
    }
}
