//
//  ProfileAvatar.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import SwiftUI

/// The circular profile photo, or a placeholder in the same circle when there
/// is none. The placeholder is the resting state, not an error: most users have
/// not set a photo, and a failed load looks the same on purpose.
struct ProfileAvatar: View {

    let photo: UIImage?
    var size: CGFloat = 88

    var body: some View {
        Group {
            if let photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.42, weight: .medium))
                    .foregroundStyle(Color.darkColor.opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.tertiarySystemBackground))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}
