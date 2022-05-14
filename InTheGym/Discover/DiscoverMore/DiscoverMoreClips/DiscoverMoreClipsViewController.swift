//
//  DiscoverMoreClipsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class DiscoverMoreClipsViewController: UIViewController {
    
    var childVC = MyClipsChildViewController()
    
    var viewModel = DiscoverMoreClipsViewModel()
    
    private var subscriptions = Set<AnyCancellable>()

    override func loadView() {
        view = childVC.display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        editNavBarColour(to: .darkColour)
    }
    func addChildVC() {
        addChild(childVC)
        childVC.didMove(toParent: self)
    }
    func initViewModel() {
        viewModel.$clips
            .sink { [weak self] in self?.childVC.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        viewModel.loadClips()
    }

}
