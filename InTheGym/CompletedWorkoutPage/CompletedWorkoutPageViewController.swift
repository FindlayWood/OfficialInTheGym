//
//  CompletedWorkoutPageViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class CompletedWorkoutPageViewController: UIViewController {
    
    // MARK: - Properties
    var display = CompletedWorkoutPageView()
    
    var viewModel = CompletedWorkoutPageViewModel()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDisplay()
        initNavBar()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Summary"
        editNavBarColour(to: .darkColour )
    }
    func initDisplay() {
        display.configure(with: viewModel.workout)
        display.newView.scoreLabelButton.addTarget(self, action: #selector(addRPEScore), for: .touchUpInside)
        display.addSummaryButton.addTarget(self, action: #selector(addSummary), for: .touchUpInside)
    }
    func initNavBar() {
        let barButton = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(upload))
        navigationItem.rightBarButtonItem = barButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

}

// MARK: - Actions
extension CompletedWorkoutPageViewController {
    @objc func addRPEScore() {
        showWorkoutRPEAlert { [weak self] score in
            guard let self = self else {return}
            self.display.addRPE(score: score)
            self.viewModel.workout.score = score
            self.viewModel.workout.workload = self.viewModel.workout.getWorkload()
            self.display.addWorkload(with: self.viewModel.workout.getWorkload())
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    @objc func addSummary() {
        display.addSummary()
    }
    
    
    @objc func upload() {
        viewModel.upload()
    }
}
