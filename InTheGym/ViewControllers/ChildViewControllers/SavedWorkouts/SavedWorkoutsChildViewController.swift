//
//  SavedWorkoutsChildViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class SavedWorkoutsChildViewController: UIViewController {
    
    // MARK: - Publishers
    var workoutSelected = PassthroughSubject<SavedWorkoutModel,Never>()
    
    // MARK: - Properties
    var display = SavedWorkoutsChildView()
    
    lazy var dataSource = SavedWorkoutsCollectionDataSource(collectionView: display.collectionView)
    
    private var subscriptions = Set<AnyCancellable>()

    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}
