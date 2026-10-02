//
//  FirestoreReportWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import CryptoKit
import DiscoverKit
import FirebaseFirestore
import Foundation

/// Files a report at `Reports/{userId}_{sha256(targetPath)}`.
///
/// The id makes a second report of the same thing by the same user the same
/// document, which the rules then refuse as an update — one report per user
/// per target. The server does not rely on it: it counts distinct reporters by
/// querying `targetPath`, since a client could choose any id.
struct FirestoreReportWriter: ReportWriter {

    let userId: String

    func report(_ target: DiscoverReportTarget, reason: DiscoverReportReason) async throws {
        let path = target.targetPath
        let key = SHA256.hash(data: Data(path.utf8)).map { String(format: "%02x", $0) }.joined()
        try await Firestore.firestore().collection("Reports").document("\(userId)_\(key)").setData([
            "reporterId": userId,
            "targetPath": path,
            "targetKind": target.targetKind,
            "reason": reason.rawValue,
            "createdAt": FieldValue.serverTimestamp()
        ])
    }
}
