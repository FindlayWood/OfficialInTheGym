//
//  File.swift
//  
//
//  Created by Findlay Wood on 26/11/2023.
//

import Foundation

class AddPlayerQRViewModel: ObservableObject {
    
    private let userService: CurrentUserService
    
    var userID: String {
        userService.currentUserUID
    }
    
    init(userService: CurrentUserService) {
        self.userService = userService
    }
}
