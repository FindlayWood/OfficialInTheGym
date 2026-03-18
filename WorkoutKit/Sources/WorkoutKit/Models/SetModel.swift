//
//  File.swift
//  
//
//  Created by Findlay-Personal on 22/04/2023.
//

import Foundation

struct SetModel: Codable, Identifiable, Equatable {
    
    var id: String
    var setNumber: Int
    var reps: Int
    var completed: Bool
    var weight: WeightModel?
    var distance: DistanceModel?
    var time: TimeModel?
    var restTime: TimeModel?
    var tempo: TempoModel? = nil
    
    init(setNumber: Int) {
        self.id = UUID().uuidString
        self.setNumber = setNumber
        self.reps = 1
        self.completed = false
    }
    
    static func == (lhs: SetModel, rhs: SetModel) -> Bool {
        lhs.id == rhs.id
    }
}
extension SetModel {
    static let example = SetModel(setNumber: 0)
}
