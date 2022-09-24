//
//  EditProfileViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 13/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class EditProfileViewController: UIViewController {
    
    /// the coordinator for this view
    weak var coordinator: EditProfileCoordinator?
    
    /// the view model
    var viewModel = EditProfileViewModel()
    
    /// hold all combine subscriptions
    private var subscriptions = Set<AnyCancellable>()
    
    /// child content view - swiftui view
    var childContentView: EditProfileViewSwiftUI!
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
        initViewModel()
    }
    
    // MARK: - Add Child View
    func addChildView() {
        childContentView = .init(viewModel: viewModel)
        addSwiftUIView(childContentView)
    }
    
    // MARK: - Init View Model
    func initViewModel() {
        
        viewModel.dismiss
            .sink { [weak self] value in
                if value {
                    self?.coordinator?.dismiss()
                }
            }
            .store(in: &subscriptions)
    }
}
