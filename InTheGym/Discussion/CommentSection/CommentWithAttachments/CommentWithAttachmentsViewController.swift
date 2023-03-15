//
//  CommentWithAttachmentsViewController.swift
//  InTheGym
//
//  Created by Findlay-Personal on 22/02/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Combine
import UIKit

class CommentWithAttachmentsViewController: UIViewController {
    
    /// coordinator
    weak var coordinator: CommentSectionCoordinator?
    
    /// view model
    var viewModel: CommentSectionViewModel!
    
    /// child content view - swiftui view
    var childContentView: CommentWithAttachmentsView!
    
    // combine subscriptions
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Buttons
    var postButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
        button.setTitle("REPLY", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.titleLabel?.font = .boldSystemFont(ofSize: 15)
        button.layer.cornerRadius = 12
        button.widthAnchor.constraint(equalToConstant: 72).isActive = true
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var postNavBarButton: UIBarButtonItem = {
        let button = UIBarButtonItem(customView: postButton)
        return button
    }()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        addChildView()
        initNavBar()
        initViewModel()
    }
    
    func addChildView() {
        childContentView = .init(viewModel: viewModel,
                                 isGroup: false,
                                 post: {
            
        }, addAttachments: {
            self.coordinator?.showAttachments(self.viewModel)
        }, changePrivacy: {
//            self.coordinator?.showPrivacy(self.viewModel)
        }, cancel: {
//            self.cancelTapped()
        })
        addSwiftUIView(childContentView)
    }
    
    // MARK: - View Model
    func initViewModel() {
        viewModel.$isLoading
            .sink { [weak self] in self?.setLoading(to: $0) }
            .store(in: &subscriptions)
        
        viewModel.uploadingNewComment
            .sink { [weak self] _ in
                self?.viewModel.clearTextPublisher.send()
                self?.dismiss(animated: true, completion: nil)
            }
            .store(in: &subscriptions)
        viewModel.$text
            .map { $0.count > 0 }
            .sink { [weak self] in self?.setPostButton(to: $0) }
            .store(in: &subscriptions)
    }
    
    // MARK: - Init Nav Bar
    func initNavBar() {
        let cancelButton = UIBarButtonItem(title: "cancel", style: .done, target: self, action: #selector(cancelTappedAction))
        postButton.addTarget(self, action: #selector(postTappedAction), for: .touchUpInside)
        postNavBarButton.action = #selector(postTappedAction)
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = postNavBarButton
        editNavBarColour(to: .darkColour)
    }
    // MARK: - Actions
    @objc func postTappedAction(_ sender: UIBarButtonItem) {
        viewModel.sendPressed()
    }
    @objc func cancelTappedAction(_ sender: UIBarButtonItem) {
        viewModel.clearTextPublisher.send()
        self.dismiss(animated: true, completion: nil)
    }
    func setPostButton(to enabled: Bool) {
        postButton.isEnabled = enabled
        postButton.backgroundColor = .darkColour.withAlphaComponent(enabled ? 1 : 0.3)
    }
    func setLoading(to loading: Bool) {
        if loading {
            initLoadingNavBar(with: .darkColour)
        } else {
            navigationItem.rightBarButtonItem = postNavBarButton
        }
    }
}
