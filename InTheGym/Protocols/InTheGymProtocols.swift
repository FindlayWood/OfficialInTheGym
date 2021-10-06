//
//  InTheGymProtocols.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

// This file contains all the project wide protocols

import Foundation

/// this protocol allows a model to be given an autoID by firebase and assign in to self.id
protocol AutoIDable {
    var id: String { get set }
}
