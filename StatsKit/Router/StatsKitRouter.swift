//
//  StatsKitRouter.swift
//  StatsKit
//
//  Created by Findlay Wood on 19/03/2026.
//

import UIKit
import SwiftUI

public final class StatsKitRouter {

    // MARK: - Navigation

    let navigationController: UINavigationController

    // MARK: - Dependencies


    // MARK: - Init

    public init(
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
    }

    // MARK: - Root

    public func start() {
        let rootVC = viewController(for: .home)
        navigationController.setViewControllers([rootVC], animated: false)
    }
    
    
    func viewController(for route: StatsKitRoutes) -> UIViewController {
        switch route {
        case .home:
            let vc = UIHostingController(
                rootView: StatsKitHomeScreen()
            )
            return vc
        }
    }
}
