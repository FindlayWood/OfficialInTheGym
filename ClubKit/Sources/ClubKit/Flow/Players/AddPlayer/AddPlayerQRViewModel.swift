//
//  File.swift
//  
//
//  Created by Findlay Wood on 26/11/2023.
//

import Foundation

class AddPlayerQRViewModel: ObservableObject {
    
    private let userService: CurrentUserService
    
    private var userID: String {
        userService.currentUserUID
    }
    
    var displayName: String {
        userService.displayName
    }
    
    var username: String {
        userService.username
    }
    
    var qrCodeString: String {
        QRConstants.startCode + QRConstants.separatingCode + userID + QRConstants.separatingCode + displayName + QRConstants.separatingCode + username + QRConstants.separatingCode + QRConstants.endCode
    }
    
    init(userService: CurrentUserService) {
        self.userService = userService
    }
}
