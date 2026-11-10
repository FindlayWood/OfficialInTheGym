//
//  Injury+TestHelpers.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation
@testable import MyDayKit

extension Injury {

    static func fixture(
        id: String = "injury",
        region: InjuryRegion = .hamstring,
        side: InjurySide? = .left,
        startedOn: String = "2026-11-08",
        resolvedOn: String? = nil,
        checkIns: [String: InjuryCheckIn] = [:],
        updatedAt: Date = Date(timeIntervalSince1970: 1_800_000_000),
        removedAt: Date? = nil
    ) -> Injury {
        Injury(
            id: id,
            region: region,
            side: side,
            startedOn: .fixture(startedOn),
            resolvedOn: resolvedOn.map { .fixture($0) },
            checkIns: checkIns,
            createdAt: Date(timeIntervalSince1970: 1_800_000_000),
            updatedAt: updatedAt,
            removedAt: removedAt
        )
    }
}

extension InjuryCheckIn {

    static func fixture(pain: Int = 3, impact: InjuryImpact = .modified, at seconds: TimeInterval = 1_800_000_000) -> InjuryCheckIn {
        InjuryCheckIn(pain: pain, impact: impact, updatedAt: Date(timeIntervalSince1970: seconds))
    }
}
