//
//  PlayerInfoDetailSubviewViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class PlayerInfoDetailSubviewViewController: UIViewController {
    // MARK: - Properties
    var display = PlayerInfoDetailSubviewView()
    var viewModel = PlayerInfoDetailSubviewViewModel()
    private var subscriptions = Set<AnyCancellable>()
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        display.infoView.configure(with: viewModel.user)
        initViewModel()
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$followerCount
            .sink { [weak self] in self?.display.infoView.setFollowerCount(to: $0)}
            .store(in: &subscriptions)
        viewModel.$followingCount
            .sink { [weak self] in self?.display.infoView.setFollowingCount(to: $0)}
            .store(in: &subscriptions)
        viewModel.getFollowerCount()
        viewModel.getFollowingCount()
    }
}
