//
//  BaseFlow.swift
//  InTheGym
//
//  Created by Findlay-Personal on 17/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

protocol BaseFlow {
    func showLogin()
    func showLoggedInPlayer()
    func showLoggedInCoach()
    func showVerifyEmail()
    func showAccountCreation(email: String, uid: String)
    func showAccountCreated(for user: Users)
}
