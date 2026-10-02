//
//  ReportWriter.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// Files a report as the signed-in user. The server counts distinct reporters
/// per target and hides it at three, or at once for an admin.
public protocol ReportWriter {
    func report(_ target: DiscoverReportTarget, reason: DiscoverReportReason) async throws
}
