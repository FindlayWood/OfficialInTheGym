//
//  MyProgramsCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class MyProgramsCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = MyProgramsViewController()
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

extension MyProgramsCoordinator {
    func addNewProgram(_ assignTo: Users?) {
        let child = ProgramCreationCoordinator(navigationController: navigationController)
        childCoordinators.append(child)
        child.start()
    }
    func showSavedProgram(_ program: SavedProgramModel) {
         let child = SavedProgramDisplayCoordinator(navigationController: navigationController, program: program)
        childCoordinators.append(child)
        child.start()
    }
}
