//
//  FirebaseFunctionsViewClipRecorder+ClipWatchRecorder.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/09/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import DiscoverKit
import Foundation

/// The one clip-watch recorder serves both frameworks: MyDayKit's
/// `ViewClipRecorder` and DiscoverKit's `ClipWatchRecorder` declare the same
/// method, so a watch from either tab reaches `recordClipWatch` the same way.
extension FirebaseFunctionsViewClipRecorder: ClipWatchRecorder {}
