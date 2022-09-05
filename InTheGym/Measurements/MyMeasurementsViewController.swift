//
//  MyMeasurementsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import SwiftUI
import Combine

class MyMeasurementsViewController: UIViewController {
    // MARK: - Properties
    var childContentView: MyMeasurementsView!
    var viewModel = MyMeasurementsViewModel()
    private var subscriptions = Set<AnyCancellable>()
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        addChildView()
        initViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .darkColour)
        navigationItem.title = UserDefaults.currentUser.username
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init(viewModel: viewModel)
        addSwiftUIView(childContentView)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.$successfulUpload
            .sink { [weak self] newValue in
                if newValue {
                    self?.dismiss(animated: true)
                }
            }.store(in: &subscriptions)
        viewModel.$dismissView
            .sink { [weak self] newValue in
                if newValue {
                    self?.dismiss(animated: true)
                }
            }.store(in: &subscriptions)
    }
}
