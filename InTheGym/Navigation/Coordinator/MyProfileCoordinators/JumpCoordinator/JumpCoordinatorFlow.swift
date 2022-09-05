//
//  JumpCoordinatorFlow.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

protocol JumpCoordinatorFlow: AnyObject {
    func recordNewJump()
    func showJump(_ outputURL: URL)
    func showResult(_ height: Double)
}
