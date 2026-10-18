//
//  File.swift
//  
//
//  Created by Findlay-Personal on 03/04/2023.
//

import Foundation
import UIKit

public protocol LoginKitInterface {
    func launch()
}

public struct MainLoginKitInterface: LoginKitInterface {
    
    var navigationController: UINavigationController
    var networkService: NetworkService
    var title: String
    var image: UIImage
    var completion: () -> Void
    /// Opens the example workout from the welcome screen, pushed onto the stack it is handed.
    /// `nil` hides the button.
    var tryWorkout: DemoWorkoutLauncher?
    
    public init(navigationController: UINavigationController, networkService: NetworkService, title: String, image: UIImage, tryWorkout: DemoWorkoutLauncher? = nil, completion: @escaping () -> Void) {
        self.navigationController = navigationController
        self.networkService = networkService
        self.title = title
        self.image = image
        self.tryWorkout = tryWorkout
        self.completion = completion
    }
    
    
    public func launch() {
        let coordinator = makeBaseController()
        coordinator.start()
    }
    
    func makeBaseController() -> LoginFlow {
        
        let viewControllerFactory = BasicViewControllerFactory(
            networkService: networkService,
            title: title,
            image: image,
            canTryWorkout: tryWorkout != nil,
            completion: completion)
        
        let flow = BasicLoginFlow(navigationController: navigationController, viewControllerFactory: viewControllerFactory, tryWorkout: tryWorkout)
        
        
        return flow
    }
}


/// Opens the example workout on the given stack. `signUp` is what its "Create Account" calls —
/// LoginKit owns signup, so the app hands the intent back rather than building the screen itself.
public typealias DemoWorkoutLauncher = (_ navigationController: UINavigationController, _ signUp: @escaping () -> Void) -> Void

public protocol NetworkService {
    func login(with email: String, password: String) async throws
    func signup(with email: String, password: String) async throws
    func forgotPassword(for email: String) async throws
}
