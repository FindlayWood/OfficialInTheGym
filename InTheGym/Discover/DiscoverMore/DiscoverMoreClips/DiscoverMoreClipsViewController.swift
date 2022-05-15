//
//  DiscoverMoreClipsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 14/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class DiscoverMoreClipsViewController: UIViewController, CustomAnimatingClipFromVC {
    
    weak var coordinator: DiscoverCoordinator?
    
    var childVC = MyClipsChildViewController()
    
    var viewModel = DiscoverMoreClipsViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Custom Clip Variables
    var selectedCell: ClipCollectionCell?
    var selectedCellImageViewSnapshot: UIView?

    override func loadView() {
        view = childVC.display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC()
        initViewModel()
        initDataSource()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = viewModel.navigationTitle
        editNavBarColour(to: .darkColour)
    }
    func addChildVC() {
        addChild(childVC)
        childVC.didMove(toParent: self)
    }
    func initDataSource() {
        childVC.dataSource.selectedCell
            .sink { [weak self] selectedCell in
                self?.selectedCell = selectedCell.selectedCell
                self?.selectedCellImageViewSnapshot = selectedCell.snapshot
            }
            .store(in: &subscriptions)
        childVC.dataSource.clipSelected
            .sink { [weak self] in self?.showClip($0)}
            .store(in: &subscriptions)
    }
    func initViewModel() {
        viewModel.$clips
            .sink { [weak self] in self?.childVC.dataSource.updateTable(with: $0)}
            .store(in: &subscriptions)
        viewModel.loadClips()
    }
    func showClip(_ clipModel: ClipModel) {
        coordinator?.clipSelected(clipModel, fromViewControllerDelegate: self)
    }
}
