//
//  File.swift
//  
//
//  Created by Findlay-Personal on 08/04/2023.
//

import UIKit

class Coordinator {
    
    var navigationController: UINavigationController
    var networkService: NetworkService
    var colour: UIColor
    var email: String
    var uid: String
    var callback: () -> ()
    var signOutCallback: () -> Void
    
    init(navigationController: UINavigationController, networkService: NetworkService, colour: UIColor, email: String, uid: String, callback: @escaping () -> Void, signOutCallback: @escaping () -> Void) {
        self.navigationController = navigationController
        self.networkService = networkService
        self.colour = colour
        self.email = email
        self.uid = uid
        self.callback = callback
        self.signOutCallback = signOutCallback
    }
    
    func start() {
        let vc = AccountCreationHomeViewController()
        vc.viewModel = .init(apiService: networkService, email: email, uid: uid, callback: callback, signOutCallback: signOutCallback)
        vc.colour = colour
        navigationController.setViewControllers([vc], animated: true)
    }
}

