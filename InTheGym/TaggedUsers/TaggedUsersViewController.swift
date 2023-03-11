//
//  TaggedUsersViewController.swift
//  InTheGym
//
//  Created by Findlay-Personal on 11/03/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit

class TaggedUsersViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: TaggedUsersCoordinator?
    
    var childContentView: TaggedUsersView!
    
    var viewModel = TaggedUsersViewModel()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addChildView()
        initViewModel()
    }
    func addChildView() {
        childContentView = .init(viewModel: viewModel, action: { [weak self] selectedUser in
            self?.coordinator?.showUser(selectedUser)
        })
        addSwiftUIView(childContentView)
    }
    // MARK: - View Model
    func initViewModel() {
        viewModel.loadUsers()
    }
}
