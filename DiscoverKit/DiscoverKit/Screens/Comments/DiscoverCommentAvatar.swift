//
//  DiscoverCommentAvatar.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import SwiftUI

/// A comment author's initial in a `darkColor` circle. There is no profile
/// photo URL on the `Users` document to show instead — photos live in Storage
/// by uid — so this is the avatar until one is added.
struct DiscoverCommentAvatar: View {
    let initial: String?
    var size: CGFloat = 32

    var body: some View {
        Circle()
            .fill(initial == nil ? Color(.tertiarySystemFill) : Color.darkColor)
            .frame(width: size, height: size)
            .overlay {
                if let initial {
                    Text(initial)
                        .font(.system(size: size * 0.42, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
    }
}
