//
//  ProfilePickerSheet.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//
import SwiftUI

/// The chrome the body pickers share: a title, the wheel, a leading Clear
/// that only appears once there is something to clear, and a trailing action.
/// ProfileKit's copy of AccountCreationKit's `AccountCreationPickerSheet`,
/// **kept in step with it**.
///
/// One addition: `actionTitle`. Height and date of birth bind live, so their
/// trailing button is "Done" and only dismisses, the signup contract. Logging a
/// weight is an action, so that sheet's button says "Log" and does it.
struct ProfilePickerSheet<Content: View>: View {

    let title: String
    let hasValue: Bool
    var actionTitle = "Done"
    var onClear: (() -> Void)?
    var onAction: (() -> Void)?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if hasValue, let onClear {
                    Button(action: onClear) {
                        Text("Clear")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.red)
                    }
                } else {
                    Color.clear.frame(width: 44, height: 20)
                }

                Spacer()

                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.primary)

                Spacer()

                Button {
                    onAction?()
                } label: {
                    Text(actionTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.darkColor)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 8)

            content

            Spacer(minLength: 0)
        }
    }
}
