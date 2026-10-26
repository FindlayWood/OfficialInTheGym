//
//  AppOpenRecorder.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// Records that the signed-in user opened the app today — the only analytics
/// the app writes itself. Everything else the dashboard measures (check-ins,
/// sets, workouts, comments) is derived on the server from data the app
/// already saves; opening the app and doing nothing leaves no other trace.
///
/// Composed in `SceneDelegate`: `FirestoreAppOpenRecorder` makes the write,
/// `OncePerDayAppOpenRecorder` keeps it to one a day.
protocol AppOpenRecorder {
    func recordOpen() async throws
}
