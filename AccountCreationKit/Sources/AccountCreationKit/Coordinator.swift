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
    
    init(navigationController: UINavigationController, networkService: NetworkService, colour: UIColor, image: UIImage, email: String, uid: String) {
        self.navigationController = navigationController
        self.networkService = networkService
        self.colour = colour
        self.image = image
        self.email = email
        self.uid = uid
    }
    
    func start() {
        let vc = AccountCreationHomeViewController()
        vc.viewModel = .init(apiService: networkService, email: email, uid: uid)
        vc.colour = colour
        vc.image = image
        navigationController.pushViewController(vc, animated: true)
    }
}

