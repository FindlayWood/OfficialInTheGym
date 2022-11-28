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
    }
    
    func addChildView() {
        childContentView = .init(viewModel: viewModel) {
            self.dismiss(animated: true)
        }
        addSwiftUIView(childContentView)
    }
}
