//
//  ReminderPermissionStub.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 09/11/2026.
//

import Foundation
@testable import MyDayKit

final class ReminderPermissionStub: ReminderPermissionAsking, @unchecked Sendable {

    private let current: ReminderPermissionStatus

    init(_ current: ReminderPermissionStatus = .allowed) {
        self.current = current
    }

    func status() async -> ReminderPermissionStatus { current }
    func request() async -> Bool { current == .allowed }
}
