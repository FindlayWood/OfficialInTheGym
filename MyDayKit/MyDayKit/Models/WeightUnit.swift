//
//  WeightUnit.swift
//  MyDayKit
//
//  Created by Findlay Wood on 27/08/2025.
//

import Foundation

public enum WeightUnit: String, CaseIterable, Codable, Hashable {
    case kg = "kg"
    case lbs = "lbs"
    case percent1RM = "% of 1RM"
    case percentBW = "% of BW"
    case max = "Max"
    case bw = "BW"
}
