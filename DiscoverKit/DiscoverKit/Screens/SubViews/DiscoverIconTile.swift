//
//  DiscoverIconTile.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 28/09/2026.
//

import SwiftUI

/// The solid 44pt `darkColor` tile with a white glyph that anchors a row — the
/// same tile the workout library and the stats exercise list use, and for the
/// same reason: a tinted wash barely registers on a card, and rows with nothing
/// on the leading edge do not scan.
struct DiscoverIconTile: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(Color.darkColor, in: RoundedRectangle(cornerRadius: 12))
    }
}
