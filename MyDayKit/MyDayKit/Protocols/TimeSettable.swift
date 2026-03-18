//
//  TimeSettable.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/03/2026.
//

import Foundation

// MARK: - Protocols

protocol TimeSettable: AnyObject {
    var time: Int? { get set }
}

protocol DistanceSettable: AnyObject {
    var distance: Double? { get set }
    var distanceUnits: DistanceUnit? { get set }
}

// MARK: - Conformances

extension MyDayNewFitnessManager: TimeSettable, DistanceSettable {
    var time: Int? {
        get { duration == 0 ? nil : duration }
        set { duration = newValue ?? 0 }
    }
}

extension MyDayNewExerciseManager: TimeSettable {}
extension MyDayNewExerciseManager: DistanceSettable {}
