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
    
    var dataSource: SavedWorkoutsCollectionDataSource!
    
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightColour
        initDataSource()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
        
        dataSource.workoutSelected
            .sink { [weak self] in self?.workoutSelected.send($0)}
            .store(in: &subscriptions)
    }
}