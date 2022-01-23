//
//  DisplayAMRAPViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView


class DisplayAMRAPViewController: UIViewController {
    
    // MARK: - Properties
    
    var display = DisplayAMRAPView()
    var flashView = FlashView()
    
    var displayAllExercises = DisplayAMRAPShowAllExercisesView()
    var allExercisesAdapter: DisplayAMRAPShowAllExercisesAdapter!
    
    var viewModel = DisplayAMRAPViewModel()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addStartButton()
        setup()
        initViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
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
    }
    
    func initDisplay() {
        navigationItem.rightBarButtonItem?.isEnabled = !viewModel.amrapModel.completed
        let firstExercise = viewModel.amrapModel.exercises[0]
        display.amrapExerciseView.configure(with: firstExercise)
        let initialTime = viewModel.amrapModel.timeLimit
        display.initialTimeLabel.text = (initialTime * 60).convertToTime()
        display.amrapExerciseView.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
    }
    
    func setup() {
        
        allExercisesAdapter = .init(delegate: self)
        displayAllExercises.tableview.dataSource = allExercisesAdapter
        
        display.helpIcon.addTarget(self, action: #selector(displayAllExercisesView), for: .touchUpInside)

    }
    
    func initViewModel() {
        viewModel.updateTimeLabelHandler = { [weak self] newValue in
            guard let self = self else {return}
            self.display.timeLabel.text = newValue
        }
        viewModel.updateRoundsLabelHandler = { [weak self] newValue in
            guard let self = self else {return}
            self.display.roundsLabel.text = newValue
        }
        viewModel.updateExercisesLabelHandler = { [weak self] newValue in
            guard let self = self else {return}
            self.display.exerciseLabel.text = newValue
        }
        viewModel.updateTimeLabelToRedHandler = { [weak self] in
            guard let self = self else {return}
            self.display.timeLabel.textColor = .red
        }
        viewModel.timerCompleted = { [weak self] in
            guard let self = self else {return}
            self.navigationItem.hidesBackButton = false
        }
    }
}

extension DisplayAMRAPViewController {
    @objc func startTimer() {
        viewModel.startTimer()
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.hidesBackButton = true
    }
    @objc func displayAllExercisesView() {
        view.addSubview(displayAllExercises)
    }
    @objc func doneButtonTapped(_ sender: UIButton) {
        exerciseCompleted()
    }

}

extension DisplayAMRAPViewController: DisplayAMRAPProtocol {
    func getExercise(at indexPath: IndexPath) -> exercise {
        return viewModel.getExercises(at: indexPath)
    }
    func numberOfExercises() -> Int {
        return viewModel.numberOfExercises()
    }
    func exerciseCompleted() {
        viewModel.exerciseCompleted()
    }
}
