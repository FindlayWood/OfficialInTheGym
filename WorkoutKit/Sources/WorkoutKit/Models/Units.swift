//
//  File.swift
//  
//
//  Created by Findlay-Personal on 22/04/2023.
//

import Foundation

enum Units: Codable, CaseIterable, Identifiable {
    case weight
    case distance
    case time
    case restime
    case tempo
    
    var title: String {
        switch self {
        case .weight:
            return "Weight"
        case .distance:
            return "Distance"
        case .time:
            return "Time"
        case .restime:
            return "Rest Time"
        case .tempo:
            return "Tempo"
        }
    }
    
    var id: String {
        return self.title
    }
}

struct WeightModel: Codable {
    var unit: Weight
    var value: Double?
}

enum Weight: String, Codable, CaseIterable {
    case kilograms
    case pounds
    case max
    case maxPercentage
    case bodyweight
    case bodyweightPercentage
    
    var title: String {
        switch self {
        case .kilograms:
            return "kg"
        case .pounds:
            return "lbs"
        case .max:
            return "max"
        case .maxPercentage:
            return "%max"
        case .bodyweight:
            return "bw"
        case .bodyweightPercentage:
            return "%bw"
        }
    }
}

struct TimeModel: Codable {
    var unit: Time
    var value: Double
}

enum Time: String, Codable, CaseIterable {
    case seconds
    case minutes
    
    var title: String {
        switch self {
        case .seconds:
            return "seconds"
        case .minutes:
            return "minutes"
        }
    }
}

struct DistanceModel: Codable {
    var unit: Distance
    var value: Double
}
enum Distance: String, Codable, CaseIterable {
    
    case metres
    case kilometres
    case miles
    
    var title: String {
        switch self {
        case .metres:
            return "metres"
        case .kilometres:
            return "km"
        case .miles:
            return "miles"
        }
    }
}
