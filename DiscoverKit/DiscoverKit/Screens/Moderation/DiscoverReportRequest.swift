//
//  DiscoverReportRequest.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Foundation

/// A report sheet waiting to be shown — `Identifiable` so a screen can drive
/// `.sheet(item:)` with it, one sheet for whatever was chosen to report.
struct DiscoverReportRequest: Identifiable {
    let id = UUID()
    let target: DiscoverReportTarget
}
