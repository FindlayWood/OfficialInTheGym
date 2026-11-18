//
//  MyDayHomeFocus.swift
//  MyDayKit
//
//  Created by Findlay Wood on 18/11/2026.
//

import Foundation

/// A `MyDayScrollTarget` the home screen is bringing to the middle, with a fresh `token` each time
/// so focusing the same thing twice (two sets edited in turn on one card) still scrolls.
struct MyDayHomeFocus: Equatable {
    let target: MyDayScrollTarget
    let token = UUID()
}
