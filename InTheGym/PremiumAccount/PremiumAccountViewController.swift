//
//  PremiumAccountViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class PremiumAccountViewController: UIViewController {
    // MARK: - Properties
    var childContentView: PremiumAccountViewSwiftUI!
//    var display = PremiumAccountView()
//    var viewModel = PremiumAccountViewModel()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
//    override func loadView() {
//        view = display
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
//        initViewModel()
//        initTargets()
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init()
        addSwiftUIView(childContentView)
    }
}
// MARK: - View Model
private extension PremiumAccountViewController {
//    func initViewModel() {
//        viewModel.$selectedSubscription
//            .sink { [weak self] in self?.display.setSelection(to: $0)}
//            .store(in: &subscriptions)
//        Task {
//            await viewModel.fetchIAPOfferings()
//        }
//    }
}
// MARK: - Targets
private extension PremiumAccountViewController {
//    func initTargets() {
//        display.monthlyView.selectionButton.addTarget(self, action: #selector(monthlyAction(_:)), for: .touchUpInside)
//        display.yearlyView.selectionButton.addTarget(self, action: #selector(yearlyActions(_:)), for: .touchUpInside)
//    }
}
// MARK: - Actions
private extension PremiumAccountViewController {
    @objc func monthlyAction(_ sender: UIButton) {
//        viewModel.selectedSubscription = .monthly
    }
    @objc func yearlyActions(_ sender: UIButton) {
//        viewModel.selectedSubscription = .yearly
    }
}
