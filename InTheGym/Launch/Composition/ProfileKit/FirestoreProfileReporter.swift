//
//  FirestoreProfileReporter.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import Foundation
import ProfileKit

/// Reports a profile as kind `"profile"` at `Profiles/{uid}`, the shape the
/// functions' `reportTarget` accepts for a profile (**keep the two in step**),
/// through the shared `ReportDocumentWriter`. Moderation hides the
/// `Profiles` projection, never the user's own document.
struct FirestoreProfileReporter: ProfileReporter {

    let userId: String

    func report(_ reportedId: String, reason: ProfileReportReason) async throws {
        try await ReportDocumentWriter(userId: userId).file(
            targetPath: "Profiles/\(reportedId)",
            targetKind: "profile",
            reason: reason.rawValue
        )
    }
}
