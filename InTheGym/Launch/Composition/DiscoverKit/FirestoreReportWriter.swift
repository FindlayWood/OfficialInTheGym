//
//  FirestoreReportWriter.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import Foundation

/// Files a DISCOVER report through `ReportDocumentWriter`, naming the target by
/// `DiscoverReportTarget+Firestore`.
struct FirestoreReportWriter: ReportWriter {

    let userId: String

    func report(_ target: DiscoverReportTarget, reason: DiscoverReportReason) async throws {
        try await ReportDocumentWriter(userId: userId).file(
            targetPath: target.targetPath,
            targetKind: target.targetKind,
            reason: reason.rawValue
        )
    }
}
