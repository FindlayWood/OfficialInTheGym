//
//  WorkoutTagNormalizer.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import Foundation
import MyDayKit

/// DiscoverKit's `TagNormalizer`, answered by MyDayKit's `WorkoutTag` — the
/// one definition of a tag. The frameworks do not import each other; this is
/// the only place the two meet.
struct WorkoutTagNormalizer: TagNormalizer {

    var maxLength: Int { WorkoutTag.maxLength }

    func normalized(_ raw: String) -> String {
        WorkoutTag.normalized(raw)
    }
}
