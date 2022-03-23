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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initViewModel()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = view.bounds
        view.addSubview(display)
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.clipPublisher
            .sink { [weak self] in self?.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        
        viewModel.fetchClipKeys()
    }
}
