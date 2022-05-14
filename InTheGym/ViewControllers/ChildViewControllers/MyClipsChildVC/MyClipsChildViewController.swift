//
//  MyClipsChildViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class MyClipsChildViewController: UIViewController {
    
    // MARK: - Properties
    var display = MyClipsChildView()
    
    var viewModel = MyClipsChildViewModel()
    
    lazy var dataSource = ExerciseClipsDataSource(collectionView: display.collectionView)
    
    private var subscriptions = Set<AnyCancellable>()

    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        display.frame = view.bounds
//        view.addSubview(display)
//    }
}
