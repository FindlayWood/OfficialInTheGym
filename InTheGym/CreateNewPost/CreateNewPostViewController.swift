//
//  CreateNewPostViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class CreateNewPostViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: CreateNewPostCoordinator?

    var display = CreateNewPostView()
    
    var viewModel = NewPostViewModel()
    
    private var subscriptions = Set<AnyCancellable>()
    
    var childContentView: NewPostView!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
        initNavBar()
        addChildView()
    }
    func initNavBar() {
        let cancelButton = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(cancelTapped))
        display.postButton.addTarget(self, action: #selector(postTapped), for: .touchUpInside)
        display.postNavBarButton.action = #selector(postTapped)
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = display.postNavBarButton
        editNavBarColour(to: .darkColour)
    }

    func addChildView() {
        childContentView = .init(
            viewModel: viewModel,
            post: {
                self.viewModel.postAction()
            }, addAttachments: {
                self.coordinator?.showAttachments(self.viewModel)
            }, changePrivacy: {
                self.coordinator?.showPrivacy(self.viewModel)
            }, cancel: {
                self.cancelTapped()
            })
        addSwiftUIView(childContentView)
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.$text
            .map { $0.count > 0 }
            .sink { [weak self] in self?.display.setPostButton(to: $0) }
            .store(in: &subscriptions)
        
        viewModel.$isPrivate
            .sink { [weak self] in self?.display.togglePrivacy(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading(to: $0)}
            .store(in: &subscriptions)
        
        viewModel.$successfullyPosted
            .compactMap { $0 }
            .sink { [weak self] in self?.successfullyPosted($0) }
            .store(in: &subscriptions)
    }
}

// MARK: - Actions
extension CreateNewPostViewController {
    @objc func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func postTapped(_ sender: UIButton) {
        viewModel.postAction()
    }
    func successfullyPosted(_ value: Bool) {
        if value {
            coordinator?.posted()
        }
    }
    func setLoading(to loading: Bool) {
        if loading {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = display.postNavBarButton
        }
    }
}
