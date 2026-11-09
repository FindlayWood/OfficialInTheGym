//
//  ScheduleSheetTarget.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/11/2026.
//

import Foundation

/// What `ScheduleSheet` was opened for, driving a single `.sheet(item:)`.
enum ScheduleSheetTarget: Identifiable {
    case new
    case edit(Schedule)

    var id: String {
        switch self {
        case .new: return "new"
        case .edit(let schedule): return schedule.id
        }
    }

    var schedule: Schedule? {
        switch self {
        case .new: return nil
        case .edit(let schedule): return schedule
        }
    }
}
