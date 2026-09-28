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
enum WorkoutTag {

    static func normalized(_ raw: String) -> String {
        String(
            raw.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
                .lowercased()
                .unicodeScalars
                .filter { ("a"..."z").contains($0) || ("0"..."9").contains($0) }
                .map(Character.init)
        )
    }
}
