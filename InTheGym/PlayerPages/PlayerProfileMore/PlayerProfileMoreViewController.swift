//
//  PlayerProfileMoreViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class PlayerProfileMoreViewController: UIViewController {
    
    // MARK: - Properties
    var childContentView: PlayerProfileMoreView!
    
    var viewModel = PlayerProfileMoreViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .darkColour)
//        navigationItem.title = viewModel.navigationTitle
    }


    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init(viewModel: viewModel)
        let childView = UIHostingController(rootView: childContentView)
        addChild(childView)
        childView.view.frame = view.bounds
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
    }
    
    // MARK: - View Model
    func initViewModel() {
        
        viewModel.actionPublisher
            .sink { [weak self] in self?.actionHandler($0)}
            .store(in: &subscriptions)
    }
}
// MARK: - Actions
private extension PlayerProfileMoreViewController {
    func actionHandler(_ action: PlayerProfileMoreAction) {
        switch action {
        case .myCoaches:
            let Storyboard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = Storyboard.instantiateViewController(withIdentifier: "COACHESViewController") as! COACHESViewController
            self.navigationController?.pushViewController(SVC, animated: true)
        case .requests:
            let vc = RequestsViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .exerciseStats:
            let vc = DisplayExerciseStatsViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case .measureJump:
            let vc = JumpMeasuringViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.modalPresentationStyle = .fullScreen
            navigationController?.present(vc, animated: true)
        case .breathWork:
            let vc = MethodSelectionViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case .settings:
            let vc = SettingsViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
