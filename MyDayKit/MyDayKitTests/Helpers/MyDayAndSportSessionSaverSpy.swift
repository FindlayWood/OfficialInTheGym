//
//  MyDayAndSportSessionSaverSpy.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 05/11/2026.
//

import Foundation
@testable import MyDayKit

final class MyDayAndSportSessionSaverSpy: MyDayAndSportSessionSaver {

    /// The day is recorded as the ids of the sport sessions on it — what these writes change —
    /// since `MyDayFullDayModel` is not `Equatable`.
    enum Message: Equatable {
        case add(daySportIds: [String], session: SportSessionEntry)
        case remove(daySportIds: [String], sessionId: String)
    }

    private(set) var receivedMessages: [Message] = []
    var error: Error?

    func save(day: MyDayFullDayModel, adding session: SportSessionEntry) async throws {
        receivedMessages.append(.add(daySportIds: day.sports?.map(\.id) ?? [], session: session))
        if let error { throw error }
    }

    func save(day: MyDayFullDayModel, removing sessionId: String) async throws {
        receivedMessages.append(.remove(daySportIds: day.sports?.map(\.id) ?? [], sessionId: sessionId))
        if let error { throw error }
    }
}
