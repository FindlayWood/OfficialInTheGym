//
//  ProfileSettingsLinks.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import Foundation

/// The outward links on the settings screen, handed in by the composition root.
///
/// They are not written here because the app already holds them, in `Constants`.
/// A second copy in the framework is the "rule in two places" this codebase keeps
/// paying for.
public struct ProfileSettingsLinks: Sendable {
    public let instagram: URL
    public let website: URL
    public let icons: URL
    public let contactEmail: String

    public init(instagram: URL, website: URL, icons: URL, contactEmail: String) {
        self.instagram = instagram
        self.website = website
        self.icons = icons
        self.contactEmail = contactEmail
    }

    var contactURL: URL? {
        URL(string: "mailto:\(contactEmail)")
    }
}
