//
//  File.swift
//  
//
//  Created by Findlay-Personal on 08/04/2023.
//

import UIKit

public protocol AccountCreationKitInterface {
    func launch()
}

public struct MainAccountCreationKitInterface: AccountCreationKitInterface {
    
    var navigationController: UINavigationController
    var networkService: NetworkService
    var userModel: AccountCreationUserModel
    var colour: UIColor
    var completedCallback: () -> Void
    var signOutCallback: () -> Void
    
    public init(navigationController: UINavigationController, networkService: NetworkService, userModel: AccountCreationUserModel, colour: UIColor, completedCallback: @escaping () -> Void, signOutCallback: @escaping () -> Void) {
        self.navigationController = navigationController
        self.networkService = networkService
        self.userModel = userModel
        self.colour = colour
        self.completedCallback = completedCallback
        self.signOutCallback = signOutCallback
    }
    
    
    public func launch() {
        let coordinator = makeBaseController()
        coordinator.start()
    }
    
    func makeBaseController() -> AccountCreationFlow {
        let flow = BasicAccountCreationFlow(navigationController: navigationController)
        
        let viewControllerFactory = BasicViewControllerFactory(
            networkService: networkService,
            userModel: userModel,
            colour: colour,
            callback: completedCallback,
            signOutCallback: signOutCallback)
        
        flow.viewControllerFactory = viewControllerFactory
        
        return flow
    }
}


public struct AccountCreationUserModel {
    let email: String
    let uid: String
    
    public init(email: String, uid: String) {
        self.email = email
        self.uid = uid
    }
}
