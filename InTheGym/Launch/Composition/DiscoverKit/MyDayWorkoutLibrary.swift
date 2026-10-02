//
//  MyDayWorkoutLibrary.swift
//  InTheGym
//
//  Created by Findlay Wood on 02/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation
import MyDayKit

/// The parts of MyDay's workout library another tab may write through: the
/// saver every template goes through, the library manager the MyDay screens
/// show, and the local store it reads first.
///
/// **The same instances MyDay uses** — `MyDayKitComposition` builds them and
/// hands this out. A copy saved from DISCOVER through any other saver would
/// skip the sync queue, and one added to any other manager would not appear in
/// MyDay's already-loaded library until relaunch.
struct MyDayWorkoutLibrary {
    let saver: WorkoutTemplateUploading
    let manager: WorkoutLibraryManager
    let local: WorkoutTemplateFetching
}
