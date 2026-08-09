//
//  AccountCreationPickerSheet.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// The chrome the three body pickers share: title, the wheel, a Clear that only appears once there
/// is something to clear, and a Done that only dismisses.
///
/// Values bind live, so Done never has anything to commit — the same contract as
/// `SessionSetValueSheet`. Clear is what makes these fields genuinely optional: a wheel always has
/// something under the marker, so without it there is no way back to "not set" once the sheet has
/// been opened.
struct AccountCreationPickerSheet<Content: View>: View {

    let title: String
    let hasValue: Bool
    var onClear: (() -> Void)?
    var onDone: (() -> Void)?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if hasValue {
                    Button {
                        onClear?()
                    } label: {
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
                    onDone?()
                } label: {
                    Text("Done")
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

#Preview {
    AccountCreationPickerSheet(title: "Height", hasValue: true) {
        Text("Wheel")
    }
}
