//
//  File.swift
//  
//
//  Created by Findlay-Personal on 03/04/2023.
//

import UIKit

class BasicLoginFlow: LoginFlow {
    
    var navigationController: UINavigationController
    var viewControllerFactory: ViewControllerFactory
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactory) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
    }
    
    func start() {
        let vc = viewControllerFactory.makeWelcomeViewController()
        vc.viewModel.coordinator = self
        navigationController.setViewControllers([vc], animated: true)
    }
    
    func presentLogin() {
        let vc = viewControllerFactory.makeLoginViewController()
        vc.viewModel.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func presentSignup() {
        let vc = viewControllerFactory.makeSignUpViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func forgotPassword() {
        let vc = viewControllerFactory.makeForgotPasswordViewController()
        let nav = UINavigationController(rootViewController: vc)
        navigationController.present(nav, animated: true)
    }
}

protocol LoginFlow {
    func start()
    func presentLogin()
    func presentSignup()
    func forgotPassword()
}

protocol ViewControllerFactory {
    func makeWelcomeViewController() -> WelcomeViewController
    func makeLoginViewController() -> LoginViewController
    func makeSignUpViewController() -> SignupViewController
    func makeForgotPasswordViewController() -> ForgotPasswordViewController
}

struct BasicViewControllerFactory: ViewControllerFactory {
    
    var networkService: NetworkService
    var colour: UIColor
    var title: String
    var image: UIImage
    var completion: () -> Void
        
    func makeWelcomeViewController() -> WelcomeViewController {
        let vc = WelcomeViewController()
        vc.viewModel = .init(title: title)
        vc.colour = colour
        vc.image = image
        return vc
    }
    
    func makeLoginViewController() -> LoginViewController {
        let vc = LoginViewController()
        vc.colour = colour
        vc.viewModel = .init(networkService: networkService, completion: completion)
        return vc
    }
    
    func makeSignUpViewController() -> SignupViewController {
        let vc = SignupViewController()
        vc.colour = colour
        vc.viewModel = .init(networkService: networkService, completion: completion)
        return vc
    }
    
    func makeForgotPasswordViewController() -> ForgotPasswordViewController {
        let vc = ForgotPasswordViewController()
        vc.viewModel = .init(networkService: networkService)
        vc.colour = colour
        return vc
    }
}
