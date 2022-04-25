//
//  DisplayAMRAPViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView
import Combine


class DisplayAMRAPViewController: UIViewController {
    
    // MARK: - Properties
    
    var display = DisplayAMRAPView()
    var flashView = FlashView()
    
    var displayAllExercises = DisplayAMRAPShowAllExercisesView()
    var allExercisesAdapter: DisplayAMRAPShowAllExercisesAdapter!
    
    var viewModel = DisplayAMRAPViewModel()
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initNavBar()
        setup()
        initViewModel()
        initDisplay()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
        displayAllExercises.frame = display.frame.insetBy(dx: 20, dy: 40)
        view.insertSubview(display, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "AMRAP"
        editNavBarColour(to: .darkColour)
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func initNavBar() {
        let barButton = UIBarButtonItem(title: "Start", style: .done, target: self, action: #selector(startTimer))
        navigationItem.rightBarButtonItem = barButton
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.isStartButtonEnabled()
    }
    
    func initDisplay() {
        display.amrapExerciseView.configure(with: viewModel.getCurrentExercise())
        let initialTime = viewModel.amrapModel.timeLimit
        display.initialTimeLabel.text = initialTime.convertToTime()
        display.updateRounds(with: viewModel.amrapModel.roundsCompleted)
        display.updateExercises(with: viewModel.amrapModel.exercisesCompleted)
        display.amrapExerciseView.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        display.amrapExerciseView.doneButton.isEnabled = viewModel.isDoneButtonEnabled()
    }
    
    func setup() {
        
        allExercisesAdapter = .init(delegate: self)
        displayAllExercises.tableview.dataSource = allExercisesAdapter
        
        display.helpIcon.addTarget(self, action: #selector(displayAllExercisesView), for: .touchUpInside)

    }
    
    // MARK: - Init View Model
    func initViewModel() {
        viewModel.updateTimeLabelHandler = { [weak self] newValue in
            guard let self = self else {return}
            self.display.updateTimeLabel(with: newValue)
            self.display.updateTimerProgress(with: CGFloat(self.viewModel.getProgress(for: newValue)))
        }
        viewModel.updateRoundsLabelHandler = { [weak self] newValue in
            guard let self = self else {return}
            self.display.updateRounds(with: newValue)
        }
        viewModel.updateExercisesLabelHandler = { [weak self] newValue in
            guard let self = self else {return}
            self.display.updateExercises(with: newValue)
        }
        viewModel.updateCurrentExercise = { [weak self] newValue in
            guard let self = self else {return}
            self.display.amrapExerciseView.configure(with: newValue)
        }
        viewModel.timerCompleted = { [weak self] in
            guard let self = self else {return}
            self.navigationItem.hidesBackButton = false
            self.display.amrapExerciseView.doneButton.isEnabled = false
            self.showRPEAMRAP(completion: self.viewModel.rpeScoreGiven(_:))
        }
        viewModel.connectionError = { [weak self] in
            guard let self = self else {return}
            self.displayTopMessage(with: "Connection Error!")
        }
    }
}

// MARK: - Actions
extension DisplayAMRAPViewController {
    @objc func startTimer() {
        display.initialTimeLabel.removeFromSuperview()
        display.amrapExerciseView.doneButton.isEnabled = true
        viewModel.startTimer()
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.hidesBackButton = true
    }
    @objc func displayAllExercisesView() {
        view.addSubview(displayAllExercises)
    }
    @objc func doneButtonTapped(_ sender: UIButton) {
        viewModel.exerciseCompleted()
    }

}

// MARK: - Display All Exercises Delegate
extension DisplayAMRAPViewController: DisplayAMRAPProtocol {
    func getExercise(at indexPath: IndexPath) -> ExerciseModel {
        return viewModel.getExercises(at: indexPath)
    }
    func numberOfExercises() -> Int {
        return viewModel.numberOfExercises()
    }
}
