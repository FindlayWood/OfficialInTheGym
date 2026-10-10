//
//  DiscoverSearchPrefix.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import FirebaseFirestore

/// **The one definition of a prefix match**: `field >= query` and
/// `field < query + "\u{f8ff}"`. Only the username half of people search uses
/// it now — words are matched through `searchTokens` — but a prefix range
/// written anywhere else must come through here. `\u{f8ff}` is
/// the highest code point in common use, so the range covers every string
/// that starts with `query` and nothing after it. Firestore has no
/// "starts with", and this range is the documented way to ask for one.
///
/// Case-sensitive like every Firestore comparison, which is why it is always
/// run against a lowercase copy of the field and a query already normalised by
/// DiscoverKit's `DiscoverSearchQuery`.
enum DiscoverSearchPrefix {

    static func matching(_ query: String, on field: String, in base: Query) -> Query {
        base
            .whereField(field, isGreaterThanOrEqualTo: query)
            .whereField(field, isLessThan: query + "\u{f8ff}")
    }
}
