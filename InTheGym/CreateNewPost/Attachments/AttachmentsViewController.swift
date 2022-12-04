//
//  AttachmentsViewController.swift
//  InTheGym
//
//  Created by Findlay-Personal on 28/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class AttachmentsViewController: UIViewController {
    
    // MARK: - Coordinator
    weak var coordinator: CreateNewPostCoordinator?
    
    // MARK: - View Model
    var viewModel: NewPostViewModel!
    
    // MARK: - Child View
    var childContentView: PostAttachmentSheet!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
        initNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    // MARK: - Naav bar
    func initNavBar() {
        let dismissButton = UIBarButtonItem(title: "dismiss", style: .done, target: self, action: #selector(dismissAction(_:)))
        navigationItem.leftBarButtonItem = dismissButton
        navigationItem.title = "Attachments"
        
        editNavBarColour(to: .darkColour)
    }
    func addChildView() {
        childContentView = .init(viewModel: viewModel, addWorkout: { [weak self] in
            self?.coordinator?.showSavedWorkoutPicker(completion: { [weak self] model in
                self?.viewModel.updateAttachedSavedWorkout(with: model)
            })
        }, addUser: { [weak self] in
            self?.coordinator?.showUserSelection(completion: { [weak self] model in
                self?.viewModel.updateAttachedTaggedUser(model)
            })
        }, dismiss: { [weak self] in
            self?.dismiss(animated: true)
        })
        addSwiftUIView(childContentView)
    }
    @objc func dismissAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
}
