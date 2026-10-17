//
//  TrialReminderPermission.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// Whether a trial reminder can be delivered — the three answers the reminder screen draws
/// differently. `notAsked` gets "Remind me", which shows the system prompt; `denied` gets "Open
/// Settings", because iOS never shows that prompt a second time.
enum TrialReminderPermission: Equatable {
    case allowed
    case notAsked
    case denied
}
