//
//  UploadGroupWorkoutViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class UploadGroupWorkoutViewController: UIViewController {

    weak var coordinator: AddGroupWorkoutCoordinator?
    
    var display = UploadGroupWorkoutView()
    
    var workoutToUpload: UploadableWorkout!
    
    var apiService: FirebaseDatabaseWorkoutManager = FirebaseDatabaseWorkoutManager.shared
    
    lazy var viewModel: UploadGroupWorkoutViewModel = {
        return UploadGroupWorkoutViewModel(apiService: apiService)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDisplay()
        initBarButton()
        initViewModel()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = UIColor.darkColour
    }
    func initBarButton() {
        let barButton = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(upload))
        navigationItem.rightBarButtonItem = barButton
    }
    func initViewModel() {
        viewModel.uploadableWorkout = workoutToUpload
    }
 
}

extension UploadGroupWorkoutViewController {
    func initDisplay() {
        display.configureWorkoutView(with: workoutToUpload)
        let tap = UITapGestureRecognizer(target: self, action: #selector(showWorkout))
        display.workoutView.addGestureRecognizer(tap)
    }
}

extension UploadGroupWorkoutViewController {
    @objc func upload() {
        viewModel.uploadWorkout()
    }
    @objc func showWorkout() {
        coordinator?.goToWorkout(workoutToUpload.workout)
    }
}
 
enum SelectedPlayers {
    case allPlayers
    case selectedPlayers([Users])
}
