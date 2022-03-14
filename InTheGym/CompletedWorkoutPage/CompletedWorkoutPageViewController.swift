//
//  CompletedWorkoutPageViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CompletedWorkoutPageViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: WorkoutDisplayCoordinator?
    
    var display = CompletedWorkoutPageView()
    
    var viewModel = CompletedWorkoutPageViewModel()
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDisplay()
        initNavBar()
        initViewModel()
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
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel.checkCompleted()
        }
    }
    
    // MARK: - Display
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
    func initLoadingNavBar() {
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        activityIndicator.startAnimating()
        let barButton = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = barButton
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.$isLoading
            .sink { [weak self] in self?.setToLoading($0)}.store(in: &subscriptions)
        
        viewModel.errorUpload
            .sink { [weak self] _ in self?.showTopAlert(with: "Error. Please try again.")}.store(in: &subscriptions)
        
        viewModel.completedUpload
            .sink { [weak self] _ in self?.coordinator?.completedUpload()}.store(in: &subscriptions)
    }

}

// MARK: - Actions
extension CompletedWorkoutPageViewController {
    @objc func addRPEScore() {
        showWorkoutRPEAlert { [weak self] score in
            guard let self = self else {return}
            self.display.addRPE(score: score)
            self.viewModel.addRPEScore(score)
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
    
    func setToLoading(_ value: Bool) {
        navigationItem.hidesBackButton = value
        if value {
            initLoadingNavBar()
        } else {
            initNavBar()
        }
    }
}
