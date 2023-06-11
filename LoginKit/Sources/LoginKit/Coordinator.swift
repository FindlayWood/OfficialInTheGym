//
//  File.swift
//  
//
//  Created by Findlay-Personal on 03/04/2023.
//

import UIKit

class Coordinator {
    
    var navigationController: UINavigationController
    var networkService: NetworkService
    var colour: UIColor
    var title: String
    var image: UIImage
    
    init(navigationController: UINavigationController, networkService: NetworkService, colour: UIColor, title: String, image: UIImage) {
        self.navigationController = navigationController
        self.networkService = networkService
        self.colour = colour
        self.title = title
        self.image = image
    }
    
    func start() {
        let vc = WelcomeViewController()
        vc.viewModel = .init(title: title)
        vc.viewModel.coordinator = self
        vc.colour = colour
        vc.image = image
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func presentLogin() {
        let vc = LoginViewController()
        vc.colour = colour
        vc.viewModel = .init(networkService: networkService, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func presentSignup() {
        let vc = SignupViewController()
        vc.colour = colour
        vc.viewModel = .init(networkService: networkService)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func forgotPassword() {
        let vc = ForgotPasswordViewController()
        let nav = UINavigationController(rootViewController: vc)
        vc.viewModel = .init(networkService: networkService)
        vc.colour = colour
        navigationController.present(nav, animated: true)
    }
}
