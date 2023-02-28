//
//  CommentAttachmentSheetViewController.swift
//  InTheGym
//
//  Created by Findlay-Personal on 25/02/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit

class CommentAttachmentSheetViewController: UIViewController {
    
    /// coordinator
    weak var coordinator: CommentSectionCoordinator?
    
    /// viewModel
    var viewModel: CommentSectionViewModel!
    
    /// content view from swiftui
    var childContentView: CommentAttachmentSheet!

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavBar()
        addChildView()
        // Do any additional setup after loading the view.
    }
    // MARK: - Nav bar
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
