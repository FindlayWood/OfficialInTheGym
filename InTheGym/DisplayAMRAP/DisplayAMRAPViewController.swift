//
//  DisplayAMRAPViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView

@available(iOS 13.0, *)
class DisplayAMRAPViewController: UIViewController {
    
    var amrap: AMRAP!
    var workout: workout!
    var amrapPosition: Int!
    var displayView = DisplayAMRAPView()
    var flashView = FlashView()
    var adapter: DisplayAMRAPAdapter!
    var APIService = AMRAPFirebaseAPIService.shared
    
    var displayAllExercises = DisplayAMRAPShowAllExercisesView()
    var allExercisesAdapter: DisplayAMRAPShowAllExercisesAdapter!
    
    lazy var viewModel: DisplayAMRAPViewModel = {
        return DisplayAMRAPViewModel(APIService: APIService,
                                     amrap: amrap,
                                     display: displayView,
                                     workout: workout,
                                     position: amrapPosition)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addStartButton()
        setup()
        initViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        displayView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        displayAllExercises.frame = displayView.frame.insetBy(dx: 20, dy: 40)
        view.insertSubview(displayView, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "AMRAP"
        editNavBarColour(to: .darkColour)
    }
    override func viewDidAppear(_ animated: Bool) {
        viewModel.scrollToBeginningPosition()
    }
    
    func setup() {
//        adapter = DisplayAMRAPAdapter(delegate: self)
//        displayView.collection.delegate = adapter
//        displayView.collection.dataSource = adapter
        
        allExercisesAdapter = DisplayAMRAPShowAllExercisesAdapter(delegate: self)
        displayAllExercises.tableview.dataSource = allExercisesAdapter
        
        displayView.helpIcon.addTarget(self, action: #selector(displayAllExercisesView), for: .touchUpInside)
        viewModel.setup()
        guard let firstExercise = amrap.exercises?[0] else {return}
        displayView.amrapExerciseView.configure(with: firstExercise)
        guard let initialTime = amrap.timeLimit else {return}
        displayView.initialTimeLabel.text = (initialTime * 60).convertToTime()
        displayView.amrapExerciseView.doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
    }
    
    func addStartButton() {
        let startTimerButton = UIBarButtonItem(title: "Start", style: .done, target: self, action: #selector(startTimer))
        navigationItem.rightBarButtonItem = startTimerButton
        if workoutIsCompleted() {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else if workoutIsInProgress() {
            if amrapHasStarted() {
                navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            flashView.frame = view.frame
            view.addSubview(flashView)
            //displayView.addSubview(flashView)
        }
    }
    
    func initViewModel() {
        viewModel.updateTimeLabelHandler = { [weak self] newValue in
            guard let self = self else {return}
            self.displayView.timeLabel.text = newValue
        }
        viewModel.updateRoundsLabelHandler = { [weak self] newValue in
            guard let self = self else {return}
            self.displayView.roundsLabel.text = newValue
        }
        viewModel.updateExercisesLabelHandler = { [weak self] newValue in
            guard let self = self else {return}
            self.displayView.exerciseLabel.text = newValue
        }
        viewModel.updateTimeLabelToRedHandler = { [weak self] in
            guard let self = self else {return}
            self.displayView.timeLabel.textColor = .red
        }
        viewModel.timerCompleted = { [weak self] in
            guard let self = self else {return}
            self.navigationItem.hidesBackButton = false
        }
    }
}
@available(iOS 13.0, *)
extension DisplayAMRAPViewController {
    @objc func startTimer() {
        viewModel.startTimer()
        navigationItem.rightBarButtonItem?.isEnabled = isStartButtonEnabled()
        navigationItem.hidesBackButton = true
    }
    @objc func displayAllExercisesView() {
        view.addSubview(displayAllExercises)
    }
    @objc func doneButtonTapped(_ sender: UIButton) {
        exerciseCompleted()
    }
    func isStartButtonEnabled() -> Bool {
        return viewModel.isStartButtonEnabled()
    }
    func workoutIsInProgress() -> Bool {
        return viewModel.isWorkoutInProgress()
    }
    func workoutIsCompleted() -> Bool {
        return viewModel.isWorkoutCompleted()
    }
    func amrapHasStarted() -> Bool {
        return viewModel.amrapHasStarted()
    }
    func showRPEAlert() {
        let alert = SCLAlertView()
        let rpe = alert.addTextField()
        rpe.placeholder = "enter rpe 1-10..."
        rpe.keyboardType = .numberPad
        rpe.becomeFirstResponder()
        alert.addButton("Save") {
            guard let scoreString = rpe.text else {return}
            guard let scoreInt = Int(scoreString) else {return}
            self.viewModel.rpeScoreGiven(rpe: scoreInt)
        }
        alert.showSuccess("RPE", subTitle: "Enter RPE for AMRAP(1-10).",closeButtonTitle: "cancel")
    }
}
@available(iOS 13.0, *)
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
