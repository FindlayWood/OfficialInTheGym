//
//  CMJResultsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Combine
import UIKit

class CMJResultsViewController: UIViewController {
    
    // MARK: - Properties
    var childContentView: CMJResultsView!
    var viewModel = CMJResultsViewModel()
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "CMJ Results"
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init(viewModel: viewModel)
        addSwiftUIView(childContentView)
    }
}
// MARK: - Actions
extension CMJResultsViewController {
    func dismiss() {
        self.dismiss(animated: true)
    }
}
