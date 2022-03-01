//
//  SavedProgramDisplayCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class SavedProgramDisplayCoordinator: NSObject, Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var savedProgram: SavedProgramModel
    var optionSelected = PassthroughSubject<Options,Never>()
    
    init(navigationController: UINavigationController, program: SavedProgramModel) {
        self.navigationController = navigationController
        self.savedProgram = program
    }
    
    func start() {
        let vc = SavedProgramDisplayViewController()
        vc.coordinator = self
        vc.viewModel.savedProgramModel = savedProgram
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}

extension SavedProgramDisplayCoordinator {
    func showOptions(_ options: [Options]) {
        let vc = OptionsChildViewController()
        vc.coordinator = self
        vc.options = options
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        navigationController.present(vc, animated: true, completion: nil)
    }
}
extension SavedProgramDisplayCoordinator: OptionsFlow {
    func optionSelected(_ option: Options) {
        optionSelected.send(option)
        navigationController.dismiss(animated: true)
    }
}

// MARK: - Custom Transition Delegate
extension SavedProgramDisplayCoordinator: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = BottomViewPresentationController(presentedViewController: presented, presenting: presenting)
        controller.viewHeightPrecentage = 0.6
        return controller
    }
}

protocol OptionsFlow: AnyObject {
    func optionSelected(_ option: Options)
}
