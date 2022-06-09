//
//  DisplayWorkoutStatsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 24/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DisplayWorkoutStatsViewController: UIViewController {
    // MARK: - Properties
    var display = DisplayWorkoutStatsView()
    var firebaseService = FirebaseAPILoader.shared
    var savedWorkoutID: String!
    var adapter: DisplayWorkoutStatsAdapter!
    var viewModel = DisplayWorkoutStatsViewModel()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        initAdapter()
        initViewModel()
    }
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: Constants.screenSize.width, height: Constants.screenSize.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
//        view.addSubview(display)
//    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = "Workout Stats"
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    // MARK: - Adapter
    func initAdapter() {
        adapter = DisplayWorkoutStatsAdapter(delegate: self)
        display.collection.delegate = adapter
        display.collection.dataSource = adapter
        display.collection.register(DisplayWorkoutStatsCell.self, forCellWithReuseIdentifier: "cell")
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.reloadCollectionViewClosure = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.display.collection.reloadData()
            }
        }
//        viewModel.updateLoadingStatusClosure = { [weak self] in
//            guard let self = self else {return}
//            DispatchQueue.main.async {
//                let isLoading = self.viewModel.isLoading
//                if isLoading {
//                    self.display.activityIndicator.startAnimating()
//                    UIView.animate(withDuration: 0.2, animations: {
//                        self.display.collection.alpha = 0.0
//                    })
//                } else {
//                    self.display.activityIndicator.stopAnimating()
//                    UIView.animate(withDuration: 0.2, animations: {
//                        self.display.collection.alpha = 1.0
//                    })
//                }
//            }
//        }
        viewModel.isLoading = false
    }
}

extension DisplayWorkoutStatsViewController: WorkoutStatsProtocol {
    func getData(at indexPath: IndexPath) -> WorkoutStatCellModel {
        return viewModel.getData(at: indexPath)
    }
    func numberOfCells() -> Int {
        return viewModel.numberOfItems
    }
}
