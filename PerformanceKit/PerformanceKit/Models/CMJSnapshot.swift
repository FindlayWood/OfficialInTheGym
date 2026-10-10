//
//  CMJSnapshot.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The athlete's CMJ summary, as a tracked session stores it. Every field of
/// the app target's `CMJModel` is here so a record keeps the shape it has always
/// had. The CMJ tool itself stays in the app.
///
/// `fatigueLevel` is the stored raw value; `fatigueLevelTitle` is what it reads
/// as, filled by the composition root from the app's `CMJFatigueLevel`.
public struct CMJSnapshot: Equatable, Sendable {
    public let mostRecentData: Date
    public let jumpNumber: Int
    public let peakPower: Double
    public let averagePower: Double
    public let fatigueLevel: String
    public let fatigueLevelTitle: String
    public let maxHeight: Double
    public let maxDate: Date

    public init(mostRecentData: Date, jumpNumber: Int, peakPower: Double, averagePower: Double, fatigueLevel: String, fatigueLevelTitle: String, maxHeight: Double, maxDate: Date) {
        self.mostRecentData = mostRecentData
        self.jumpNumber = jumpNumber
        self.peakPower = peakPower
        self.averagePower = averagePower
        self.fatigueLevel = fatigueLevel
        self.fatigueLevelTitle = fatigueLevelTitle
        self.maxHeight = maxHeight
        self.maxDate = maxDate
    }
}
