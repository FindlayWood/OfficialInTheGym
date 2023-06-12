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
    var image: UIImage
    var email: String
    var uid: String
    var callback: () -> ()
    
    init(navigationController: UINavigationController, networkService: NetworkService, colour: UIColor, image: UIImage, email: String, uid: String, callback: @escaping () -> Void) {
        self.navigationController = navigationController
        self.networkService = networkService
        self.colour = colour
        self.image = image
        self.email = email
        self.uid = uid
        self.callback = callback
    }
    
    func start() {
        let vc = AccountCreationHomeViewController()
        vc.viewModel = .init(apiService: networkService, email: email, uid: uid, callback: callback)
        vc.colour = colour
        vc.image = image
        navigationController.setViewControllers([vc], animated: true)
    }
}

