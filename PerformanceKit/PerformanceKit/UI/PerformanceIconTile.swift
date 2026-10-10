//
//  PerformanceIconTile.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// A solid `darkColor` tile with a white SF Symbol, the anchor MyDay's library
/// rows and StatsKit's exercise rows use. Solid rather than tinted: at 44pt a
/// wash of colour on a `secondarySystemBackground` card barely registers.
struct PerformanceIconTile: View {

    let systemName: String
    var size: CGFloat = 44

    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color.darkColor)
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: systemName)
                    .font(.system(size: size * 0.41, weight: .semibold))
                    .foregroundStyle(Color.white)
            )
    }
}
