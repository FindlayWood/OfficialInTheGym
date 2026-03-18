//
//  PreLiveWorkoutViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
//import SCLAlertView
import Combine

class PreLiveWorkoutViewController: UIViewController, Storyboarded {
    
    // MARK: - Coordinator
    weak var coordinator: PreLiveWorkoutFlow?
    
    // MARK: - Properties
    var apiService = FirebaseAPIWorkoutManager.shared
    
//    var display = PreLiveWorkoutView()
    lazy var display = LiveWorkoutTitleView(viewModel: viewModel)
    
    var adapter: PreLiveWorkoutAdapter!
    
    var viewModel = PreLiveWorkoutViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
//        display.titleField.delegate = self
//        hideKeyboardWhenTappedAround()
        initDisplay()
        initNavBarButton()
        initViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        display.frame = getFullViewableFrame()
//        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
    }
    
    // MARK: - Display
    func initDisplay() {
        view.backgroundColor = .systemBackground
        addSwiftUIViewWithNavBar(display)
//        adapter = PreLiveWorkoutAdapter(delegate: self)
//        display.tableview.delegate = adapter
//        display.tableview.dataSource = adapter
//        display.tableview.backgroundColor = .white
//        display.titleField.delegate = self
    }
    
    // MARK: - Nav Bar
    func initNavBarButton() {
        let barButtonItem = UIBarButtonItem(title: viewModel.navBarButtonTitle, style: .done, target: self, action: #selector(continuePressed(_:)))
        navigationItem.rightBarButtonItem = barButtonItem
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
        
        viewModel.$canContinue
            .sink { [weak self] in self?.navigationItem.rightBarButtonItem?.isEnabled = $0 }
            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .sink { [weak self] loading in
//                self?.display.setInteraction(to: !loading)
                self?.setToLoading(loading)
            }
            .store(in: &subscriptions)
        
        viewModel.workoutPublisher
            .sink { [weak self] in self?.coordinator?.showLiveWorkout($0)}
            .store(in: &subscriptions)
    }
    
    
    // MARK: - Actions
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.trimmingCharacters(in: .whitespaces) != ""{
            print("move to next with title = \(textField.text!)")
        }
    }
}

// MARK: - Actions
private extension PreLiveWorkoutViewController {
    func setToLoading(_ value: Bool) {
        navigationItem.hidesBackButton = value
        if value {
            initLoadingNavBar()
        } else {
            initNavBarButton()
        }
    }
    @objc func continuePressed(_ sender: UIBarButtonItem) {
        if viewModel.title.trimmingCharacters(in: .whitespaces) == "" {
//            let alert = SCLAlertView()
//            alert.showError("Enter a title!", subTitle: "You must enter a title to begin the workout. The title can be anything you want.")
        } else {
            viewModel.startLiveWorkout()
        }
        
    }
}
