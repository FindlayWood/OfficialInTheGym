//
//  ReportDocumentWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import CryptoKit
import FirebaseFirestore
import Foundation

/// Files a report at `Reports/{userId}_{sha256(targetPath)}`. **The one
/// definition of a report document**, shared by DISCOVER's reports
/// (`FirestoreReportWriter`) and profile reports (`FirestoreProfileReporter`),
/// so the shape the `Reports` create rule checks is written in one place.
///
/// The id makes a second report of the same thing by the same user the same
/// document, which the rules then refuse as an update: one report per user
/// per target. The server does not rely on it. It counts distinct reporters
/// by querying `targetPath`, since a client could choose any id.
struct ReportDocumentWriter {

    let userId: String

    func file(targetPath: String, targetKind: String, reason: String) async throws {
        let key = SHA256.hash(data: Data(targetPath.utf8)).map { String(format: "%02x", $0) }.joined()
        try await Firestore.firestore().collection("Reports").document("\(userId)_\(key)").setData([
            "reporterId": userId,
            "targetPath": targetPath,
            "targetKind": targetKind,
            "reason": reason,
            "createdAt": FieldValue.serverTimestamp()
        ])
    }
}
