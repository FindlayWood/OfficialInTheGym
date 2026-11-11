//
//  InjuryUploaderSpy.swift
//  MyDayKitTests
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation
@testable import MyDayKit

final class InjuryUploaderSpy: InjuryUploading {

    enum Message: Equatable {
        case upload(Injury)
    }

    private(set) var receivedMessages: [Message] = []
    var error: Error?

    var uploaded: [Injury] {
        receivedMessages.map { message in
            switch message {
            case .upload(let injury): return injury
            }
        }
    }

    func upload(_ injury: Injury) async throws {
        receivedMessages.append(.upload(injury))
        if let error { throw error }
    }
}
