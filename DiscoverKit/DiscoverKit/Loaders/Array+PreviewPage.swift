//
//  Array+PreviewPage.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import Foundation

extension Array where Element: Identifiable {

    /// The page after `last` in an already-ordered list — how the preview
    /// loaders page for real rather than returning one page and stopping, so a
    /// preview of a "see all" list exercises loading more.
    func previewPage(limit: Int, after last: Element?) -> [Element] {
        let start = last.flatMap { last in firstIndex { $0.id == last.id } }.map { $0 + 1 } ?? 0
        return Array(dropFirst(start).prefix(limit))
    }
}
