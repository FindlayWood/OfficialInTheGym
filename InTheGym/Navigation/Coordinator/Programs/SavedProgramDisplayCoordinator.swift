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
    var listener: CurrentValueSubject<CurrentProgramModel?,Never>
    
    init(navigationController: UINavigationController, program: SavedProgramModel, listener: CurrentValueSubject<CurrentProgramModel?,Never>) {
        self.navigationController = navigationController
        self.savedProgram = program
        self.listener = listener
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
    func showOptions(_ model: SavedProgramModel) {
        let vc = SavedProgramOptionsDisplayViewController()
        vc.coordinator = self
//        vc.options = options
        vc.viewModel.savedProgram = model
        vc.viewModel.makedCurrentProgram = listener
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
