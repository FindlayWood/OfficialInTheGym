//
//  WorkoutTag.swift
//  MyDayKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Foundation

/// The one definition of what a template tag may contain: **lowercase ASCII
/// letters and digits, nothing else** — no spaces, no punctuation, no accents.
///
/// Tags are for finding templates across users, and a Firestore
/// `array-contains` match is exact. Left as typed, "Legs", "legs" and "legs!"
/// are three different tags and a search for one misses the other two — the
/// same failure as the case-sensitive `Usernames/{username}` ids. Accents are
/// folded off first, so "Café" becomes "cafe" rather than "caf" — keeping them
/// would make "café" and "cafe" two tags with nothing on screen to tell them
/// apart. Anything still outside a–z / 0–9 after that (emoji, non-Latin
/// scripts) is dropped.
///
/// The tag field runs every keystroke through this, so what the user sees is
/// what gets stored; `WorkoutBuilderManager.addTag` runs it again so a tag
/// cannot reach a template any other way unnormalised.
///
/// **Capped at `maxLength`, which must stay in step with `MAX_TAG_LENGTH` in the
/// Cloud Functions' `Tags/TagRejection.ts`.** The server re-checks every tag
/// before indexing it and drops anything longer, so without the cap here a
/// long tag would be shown and stored on the template yet never be findable.
///
/// **Public because DISCOVER needs the same rule** for the tags people vote
/// onto exercises and workouts. DiscoverKit does not import MyDayKit; it
/// declares a `TagNormalizer`, and the composition root's `WorkoutTagNormalizer`
/// answers it with this — so the rule still has exactly one definition.
public enum WorkoutTag {

    public static let maxLength = 32

    public static func normalized(_ raw: String) -> String {
        String(
            raw.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
                .lowercased()
                .unicodeScalars
                .filter { ("a"..."z").contains($0) || ("0"..."9").contains($0) }
                .prefix(maxLength)
                .map(Character.init)
        )
    }
}
