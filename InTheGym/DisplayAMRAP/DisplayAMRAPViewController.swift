//
//  DisplayAMRAPViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class DisplayAMRAPViewController: UIViewController {
    
    var amrap: AMRAP!
    var workout: workout!
    var amrapPosition: Int!
    var displayView = DisplayAMRAPView()
    var flashView = FlashView()
    var adapter: DisplayAMRAPAdapter!
    var APIService = AMRAPFirebaseAPIService.shared
    
    lazy var viewModel: DisplayAMRAPViewModel = {
        return DisplayAMRAPViewModel(APIService: APIService,
                                     amrap: amrap,
                                     display: displayView,
                                     workout: workout,
                                     position: amrapPosition)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.lightColour
        addStartButton()
        setup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        displayView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        view.addSubview(displayView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "AMRAP"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = .white
    }
    override func viewDidAppear(_ animated: Bool) {
        viewModel.scrollToBeginningPosition()
    }
    
    func setup() {
        adapter = DisplayAMRAPAdapter(delegate: self)
        displayView.collection.delegate = adapter
        displayView.collection.dataSource = adapter
        viewModel.setup()
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
            displayView.addSubview(flashView)
        }
    }
}
@available(iOS 13.0, *)
extension DisplayAMRAPViewController {
    @objc func startTimer() {
        viewModel.startTimer()
        navigationItem.rightBarButtonItem?.isEnabled = isStartButtonEnabled()
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
