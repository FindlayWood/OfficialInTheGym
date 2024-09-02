//
//  File.swift
//  
//
//  Created by Findlay Wood on 25/11/2023.
//

import UIKit

protocol StaffFlow: Coordinator {
    func addNewStaffMember()
}


class BasicStaffFlow: StaffFlow {
    
    var navigationController: UINavigationController
    var viewControllerFactory: StaffViewControllerFactory
    var clubModel: RemoteClubModel
    
    init(navigationController: UINavigationController, viewControllerFactory: StaffViewControllerFactory, clubModel: RemoteClubModel) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
        self.clubModel = clubModel
    }
    
    func start() {
        let vc = viewControllerFactory.makeStaffViewController(with: clubModel)
        vc.coordinator = self
        vc.viewModel.loadFromClub()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addNewStaffMember() {
        let vc = viewControllerFactory.makeCreateStaffViewController(with: clubModel)
        navigationController.present(vc, animated: true)
    }
}
