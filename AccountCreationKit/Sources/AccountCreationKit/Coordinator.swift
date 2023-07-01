//
//  File.swift
//  
//
//  Created by Findlay-Personal on 08/04/2023.
//

import UIKit

class BasicAccountCreationFlow: AccountCreationFlow {
    
    var navigationController: UINavigationController
    var viewControllerFactory: ViewControllerFactory?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        guard let vc = viewControllerFactory?.makeAccountCreationHomeViewController() else { return }
        navigationController.setViewControllers([vc], animated: true)
    }
}

protocol AccountCreationFlow {
    func start()
}

protocol ViewControllerFactory {
    func makeAccountCreationHomeViewController() -> AccountCreationHomeViewController
}

struct BasicViewControllerFactory: ViewControllerFactory {
    
    var networkService: NetworkService
    var userModel: AccountCreationUserModel
    var colour: UIColor
    var callback: () -> Void
    var signOutCallback: () -> Void
    
    func makeAccountCreationHomeViewController() -> AccountCreationHomeViewController {
        let vc = AccountCreationHomeViewController()
        vc.viewModel = .init(apiService: networkService, email: userModel.email, uid: userModel.uid, callback: callback, signOutCallback: signOutCallback)
        vc.colour = colour
        return vc
    }
}
