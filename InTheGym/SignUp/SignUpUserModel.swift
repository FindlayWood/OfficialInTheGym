//
//  SignUpUserModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 16/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

struct SignUpUserModel {
    var email = ""
    var username = ""
    var firstName = ""
    var lastName = ""
    var password = ""
    var confirmPassword = ""
    var admin:Bool!
    
    func toObject() -> [String:AnyObject] {
        let object = ["email": email,
                      "username": username,
                      "firstName": firstName,
                      "lastName": lastName,
                      "admin": admin!] as [String:AnyObject]
        return object
    }
}
