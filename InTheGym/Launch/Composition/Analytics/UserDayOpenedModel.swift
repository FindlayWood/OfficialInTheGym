//
//  UserDayOpenedModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 26/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// The app's one analytics write: these three fields, merged onto the
/// person's `UserDays` document for today.
///
/// **Exactly these keys.** The `UserDays` rule lets a client create the
/// document with `userId`, `date` and `openedApp` only, and update nothing
/// but `openedApp` — every other field (sets, check-ins, workouts…) is
/// recounted by Cloud Functions from what the app already writes, so it is
/// never copied here. Adding a field to this model will have every write
/// refused. If something new needs measuring, it is a server-side field.
struct UserDayOpenedModel: Codable {
    let userId: String
    let date: String
    let openedApp: Bool
}
