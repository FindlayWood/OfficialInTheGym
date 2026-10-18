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
    /// What the welcome screen's feature cards open. A card whose launcher is `nil` is not drawn.
    var previews: WelcomePreviews
    
    public init(navigationController: UINavigationController, networkService: NetworkService, title: String, image: UIImage, previews: WelcomePreviews = WelcomePreviews(), completion: @escaping () -> Void) {
        self.navigationController = navigationController
        self.networkService = networkService
        self.title = title
        self.image = image
        self.previews = previews
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
            features: previews.features,
            completion: completion)
        
        let flow = BasicLoginFlow(navigationController: navigationController, viewControllerFactory: viewControllerFactory, previews: previews)
        
        
        return flow
    }
}


public protocol NetworkService {
    func login(with email: String, password: String) async throws
    func signup(with email: String, password: String) async throws
    func forgotPassword(for email: String) async throws
}
