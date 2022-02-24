//
//  ProgramsChildViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class ProgramsChildViewController: UIViewController {
    
    // MARK: - Properties
    var display = ProgramsChildView()
    
    var weeksDataSource: NumberCircleDataSource!
    
    var workoutsDataSource: ProgramCreationWorkoutsDataSource!

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDataSource()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Data Source
    func initDataSource() {
        weeksDataSource = .init(collectionView: display.weeksCollectionView)
        workoutsDataSource = .init(collectionView: display.collectionView)
    }

}
