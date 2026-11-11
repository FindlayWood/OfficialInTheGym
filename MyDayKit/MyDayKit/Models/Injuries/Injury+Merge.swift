//
//  Injury+Merge.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

extension Injury {

    /// The one rule for reconciling two copies of the user's injuries — this device's files and
    /// Firestore, or what is held and what was just read.
    ///
    /// **Unions by id; for the same id, the later `updatedAt` decides the injury's own fields and
    /// local wins a tie**, exactly as `Schedule.merged`. **Check-ins are then unioned day by day**,
    /// the later check-in winning each day, local winning a tie. A check-in made on the phone and
    /// another made on the iPad on a different day are both kept, whichever copy of the injury was
    /// written last — without this, each device's upload would wipe the other's days.
    public static func merged(local: [Injury], remote: [Injury]) -> [Injury] {
        var byId: [String: Injury] = [:]
        for injury in remote {
            byId[injury.id] = injury
        }
        for injury in local {
            guard let other = byId[injury.id] else {
                byId[injury.id] = injury
                continue
            }
            var winner = injury.updatedAt >= other.updatedAt ? injury : other
            winner.checkIns = mergedCheckIns(local: injury.checkIns, remote: other.checkIns)
            byId[injury.id] = winner
        }
        return byId.values.sorted { lhs, rhs in
            lhs.startedOn != rhs.startedOn ? lhs.startedOn > rhs.startedOn : lhs.createdAt > rhs.createdAt
        }
    }

    private static func mergedCheckIns(
        local: [String: InjuryCheckIn],
        remote: [String: InjuryCheckIn]
    ) -> [String: InjuryCheckIn] {
        local.merging(remote) { localCheckIn, remoteCheckIn in
            localCheckIn.updatedAt >= remoteCheckIn.updatedAt ? localCheckIn : remoteCheckIn
        }
    }
}
