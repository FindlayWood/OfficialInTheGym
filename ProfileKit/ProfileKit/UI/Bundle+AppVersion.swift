//
//  Bundle+AppVersion.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import Foundation

extension Bundle {

    /// "1.4 (212)". Read from `Bundle.main`, which inside a framework is still
    /// the app's bundle, so it reports the app's version rather than ProfileKit's.
    var profileAppVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        guard let build = infoDictionary?["CFBundleVersion"] as? String else { return version }
        return "\(version) (\(build))"
    }
}
