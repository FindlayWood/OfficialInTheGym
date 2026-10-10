//
//  WellnessSnapshot.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// The athlete's last wellness check-in, as a tracked session stores it. Every
/// field of the app target's `WellnessAnswersModel` is here so a record keeps
/// the shape it has always had. The Wellness tool itself stays in the app.
///
/// `status` is the stored raw value; `statusTitle` is what it reads as, filled
/// by the composition root from the app's `WellnessStatus`, so the wording has
/// one definition.
public struct WellnessSnapshot: Equatable, Sendable {
    public let time: Date
    public let sleepAmount: Double
    public let sleepQuality: Int
    public let bodyFeeling: Int
    public let mindFeeling: Int
    public let happyFeeling: Int
    public let motivationFeeling: Int
    public let status: String
    public let statusTitle: String

    public init(time: Date, sleepAmount: Double, sleepQuality: Int, bodyFeeling: Int, mindFeeling: Int, happyFeeling: Int, motivationFeeling: Int, status: String, statusTitle: String) {
        self.time = time
        self.sleepAmount = sleepAmount
        self.sleepQuality = sleepQuality
        self.bodyFeeling = bodyFeeling
        self.mindFeeling = mindFeeling
        self.happyFeeling = happyFeeling
        self.motivationFeeling = motivationFeeling
        self.status = status
        self.statusTitle = statusTitle
    }
}
