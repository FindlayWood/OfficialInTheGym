//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import UIKit

class CreationCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    var viewControllerFactoy: ViewControllerFactory
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactory) {
        self.navigationController = navigationController
        self.viewControllerFactoy = viewControllerFactory
    }
    
    func start() {

    }
}
