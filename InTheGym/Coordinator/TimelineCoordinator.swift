//
//  TimelineCoordinator.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/05/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

protocol TimelineFlow {
    func showDiscussion()
    func showWorkouts()
    func showUser()
}


protocol NewsFeedFlow: TimelineFlow {
    func makePost()
}

class TimelineCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController){
        self.navigationController = navigationController
        self.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController.navigationBar.shadowImage = UIImage()
        self.navigationController.navigationBar.tintColor = .white
    }
    
    func start() {
        let playerTimeline = PlayerTimelineViewController.instantiate()
        playerTimeline.coordinator = self
        navigationController.pushViewController(playerTimeline, animated: false)
    }
    
}

  //MARK: - Flow Methods
extension TimelineCoordinator: NewsFeedFlow {
    func showDiscussion() {
        
    }
    
    func showWorkouts() {
        
    }
    
    func showUser() {
        
    }
    
    func makePost(){
        
    }
    
}
