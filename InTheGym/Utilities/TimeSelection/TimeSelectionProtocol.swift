//
//  TimeSelectionProtocol.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation

protocol TimeSelectionProtocol: AnyObject {
    func getCurrentTime() -> Int
    func newTimeSelected(_ time: Int)
}

protocol TimeSelectionParentDelegate: AnyObject {
    func timeSelected(newTime: Int)
}
