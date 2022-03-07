//
//  WorkoutChildViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class WorkoutChildViewController: UIViewController {

    // MARK: - Properties
    var display = WorkoutChildView()
    
    lazy var dataSource: WorkoutExerciseCollectionDataSource = WorkoutExerciseCollectionDataSource(collectionView: display.exerciseCollection)
    
    lazy var clipDataSource: ClipCollectionDataSource = ClipCollectionDataSource(collectionView: display.clipCollection)
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        initDataSource()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = view.bounds
        view.addSubview(display)
    }
    
    // MARK: - Data Source
    func initDataSource() {
        
        
    }

}
