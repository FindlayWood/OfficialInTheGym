//
//  MeasurementsModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct MeasurementModel {
    var userID: String
    var height: Double
    var weight: Double
    var isPrivate: Bool
    var time: Date
}
extension MeasurementModel: FirebaseInstance {
    var internalPath: String {
        "AthleteMeasurements/\(userID)"
    }
}

struct LoadMeasurementsModel {
    var userID: String
}
extension LoadMeasurementsModel: FirebaseInstance {
    var internalPath: String {
        "AthleteMeasurements/\(userID)"
    }
}
