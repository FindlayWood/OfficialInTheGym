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
    
    public init(navigationController: UINavigationController, networkService: NetworkService, title: String, image: UIImage, completion: @escaping () -> Void) {
        self.navigationController = navigationController
        self.networkService = networkService
        self.title = title
        self.image = image
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
            completion: completion)
        
        let flow = BasicLoginFlow(navigationController: navigationController, viewControllerFactory: viewControllerFactory)
        
        
        return flow
    }
}


public protocol NetworkService {
    func login(with email: String, password: String) async throws
    func signup(with email: String, password: String) async throws
    func forgotPassword(for email: String) async throws
}
