//
//  DisplayNotificationsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class DisplayNotificationsViewModel {
    
    // MARK: - Publishers
    var notificationsPublisher = CurrentValueSubject<[NotificationModel],Never>([])

    var errorPublisher = PassthroughSubject<Error,Never>()
    
    // MARK: - Properties
    
    let navigationTitle = "Notifications"
    
    var apiService: FirebaseDatabaseManagerService

    
    // MARK: - Constructor
    
    // Note: apiService has a default value in case this constructor is executed without passing parameters
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
 
    
    // MARK: - Fetching functions
    func fetchNotifications() {
        apiService.fetch(NotificationModel.self) { [weak self] result in
            switch result {
            case .success(let models):
                self?.notificationsPublisher.send(models)
            case .failure(let error):
                self?.errorPublisher.send(error)
            }
        }
    }
}
