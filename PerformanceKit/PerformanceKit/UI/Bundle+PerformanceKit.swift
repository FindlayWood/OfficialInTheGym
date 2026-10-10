//
//  Bundle+PerformanceKit.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

/// PerformanceKit's own bundle, which holds its asset catalog. It is the first
/// framework in the project with images of its own. `Image("x")` with no
/// bundle looks in the **app's** catalog, so every image here must name this
/// bundle, or it silently draws nothing.
extension Bundle {
    static let performanceKit = Bundle(for: PerformanceKitRouter.self)
}
