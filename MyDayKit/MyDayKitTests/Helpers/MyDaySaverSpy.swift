//
//  MyDaySaverSpy.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 11/11/2026.
//

import Foundation
@testable import MyDayKit

final class MyDaySaverSpy: MyDaySaver {

    /// The day is recorded as its id and the templates of its workouts, which is what adding a
    /// workout changes, since `MyDayFullDayModel` is not `Equatable`.
    enum Message: Equatable {
        case save(dayId: String, workoutTemplateIds: [String])
    }

    private(set) var receivedMessages: [Message] = []

    func save<T: Codable>(data: T) async throws {
        guard let day = data as? MyDayFullDayModel else { return }
        receivedMessages.append(.save(dayId: day.id, workoutTemplateIds: day.workouts.map(\.template.id)))
    }
}
