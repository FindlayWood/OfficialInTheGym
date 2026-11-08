//
//  MyDayFullDayModel+Sports.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/11/2026.
//

import Foundation

extension MyDayFullDayModel {

    /// The day with `session` on it. A session already on the day with the same id is replaced
    /// in place rather than added twice, so saving an edit corrects the entry instead of
    /// duplicating it — the same rule `addNewCompletion` applies to a completion.
    func addingSport(_ session: SportSessionEntry) -> MyDayFullDayModel {
        var day = self
        var sports = day.sports ?? []
        if let index = sports.firstIndex(where: { $0.id == session.id }) {
            sports[index] = session
        } else {
            sports.append(session)
        }
        day.sports = sports
        return day
    }

    /// The day without the session `id`. Unchanged if it was never there.
    func removingSport(id: String) -> MyDayFullDayModel {
        var day = self
        day.sports = day.sports?.filter { $0.id != id }
        return day
    }
}
