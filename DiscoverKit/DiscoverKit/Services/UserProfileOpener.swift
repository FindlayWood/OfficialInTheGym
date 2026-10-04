//
//  UserProfileOpener.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 04/10/2026.
//

import Foundation

/// Opens someone's profile from DISCOVER: a workout's author, a clip's owner,
/// a commenter. Profiles are ProfileKit's, which DiscoverKit does not import,
/// so the composition root answers this. It pushes ProfileKit's profile screen
/// onto DISCOVER's own navigation controller, so back returns to the workout,
/// clip or thread (`PROFILE_PLAN.md` step 7).
///
/// **Optional on the router.** With no opener, names are plain text, not
/// buttons that do nothing.
///
/// Called from button actions, so always on the main thread. It is not marked
/// `@MainActor` because the screens' closures are not isolated, and the
/// conformer asserts it instead.
public protocol UserProfileOpener {
    func openProfile(_ userId: String)
}
