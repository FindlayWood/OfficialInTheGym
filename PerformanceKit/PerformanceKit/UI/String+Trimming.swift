//
//  String+Trimming.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import Foundation

extension String {

    /// PerformanceKit's copy of the app target's `trimTrailingWhiteSpaces()`,
    /// which the journal used and a framework cannot see. Only **trailing**
    /// whitespace goes. A leading indent is the writer's.
    func trimmingTrailingWhitespace() -> String {
        replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    }
}
