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
    var previews: WelcomePreviews
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactory, previews: WelcomePreviews = WelcomePreviews()) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
        self.previews = previews
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
    
    /// Signup straight from the end of the example workout. The demo's screens are replaced rather
    /// than left underneath, so back from signup is the welcome screen, not a finished workout.
    func presentSignupFromDemo() {
        let vc = viewControllerFactory.makeSignUpViewController()
        let welcome = Array(navigationController.viewControllers.prefix(1))
        navigationController.setViewControllers(welcome + [vc], animated: true)
    }
    
    func forgotPassword() {
        let vc = viewControllerFactory.makeForgotPasswordViewController()
        let nav = UINavigationController(rootViewController: vc)
        navigationController.present(nav, animated: true)
    }
    
    /// LoginKit draws the button and the app decides what it opens — the example workout is
    /// MyDayKit's session screen, which this framework does not import.
    func presentDemoWorkout() {
        previews.workout?(navigationController) { [weak self] in
            self?.presentSignupFromDemo()
        }
    }
    
    func presentStatsPreview() {
        previews.stats?(navigationController)
    }
    
    func presentPerformancePreview() {
        previews.performance?(navigationController)
    }
}

protocol LoginFlow {
    func start()
    func presentLogin()
    func presentSignup()
    func forgotPassword()
    func presentDemoWorkout()
    func presentStatsPreview()
    func presentPerformancePreview()
}

protocol ViewControllerFactory {
    func makeWelcomeViewController() -> WelcomeViewController
    func makeLoginViewController() -> LoginViewController
    func makeSignUpViewController() -> SignupViewController
    func makeForgotPasswordViewController() -> ForgotPasswordViewController
}

struct BasicViewControllerFactory: ViewControllerFactory {
    
    var networkService: NetworkService
    var title: String
    var image: UIImage
    var features: [WelcomeFeature]
    var completion: () -> Void
        
    func makeWelcomeViewController() -> WelcomeViewController {
        let vc = WelcomeViewController()
        vc.viewModel = .init(title: title, features: features)
        vc.image = image
        return vc
    }
    
    func makeLoginViewController() -> LoginViewController {
        let vc = LoginViewController()
        vc.viewModel = .init(networkService: networkService, completion: completion)
        return vc
    }
    
    func makeSignUpViewController() -> SignupViewController {
        let vc = SignupViewController()
        vc.viewModel = .init(networkService: networkService, completion: completion)
        return vc
    }
    
    func makeForgotPasswordViewController() -> ForgotPasswordViewController {
        let vc = ForgotPasswordViewController()
        vc.viewModel = .init(networkService: networkService)
        return vc
    }
}
